#!/usr/bin/env python3
"""
Simple systemd service metrics exporter for Prometheus
Exports CPU, Memory, and Tasks metrics for systemd services
"""

import subprocess
import time
import re
from http.server import HTTPServer, BaseHTTPRequestHandler

class SystemdExporter:
    def __init__(self):
        self.podman_services = []
        self.refresh_services()
    
    def refresh_services(self):
        """Get list of podman services"""
        try:
            result = subprocess.run(['systemctl', 'list-units', '--type=service', '--state=active', '--no-legend'], 
                                  capture_output=True, text=True)
            self.podman_services = [line.split()[0] for line in result.stdout.strip().split('\n') 
                                  if line.strip() and 'podman-' in line and '.service' in line]
        except Exception as e:
            print(f"Error getting services: {e}")
            self.podman_services = []
    
    def get_service_metrics(self, service_name):
        """Get resource metrics for a specific service"""
        try:
            result = subprocess.run(['systemctl', 'show', service_name, 
                                   '--property=CPUUsageNSec,MemoryCurrent,TasksCurrent,ActiveState'], 
                                  capture_output=True, text=True)
            
            metrics = {}
            for line in result.stdout.strip().split('\n'):
                if '=' in line:
                    key, value = line.split('=', 1)
                    metrics[key] = value
            
            return metrics
        except Exception as e:
            print(f"Error getting metrics for {service_name}: {e}")
            return {}
    
    def generate_metrics(self):
        """Generate Prometheus metrics"""
        self.refresh_services()
        
        metrics = []
        metrics.append("# HELP systemd_service_cpu_usage_nanoseconds_total Total CPU usage in nanoseconds")
        metrics.append("# TYPE systemd_service_cpu_usage_nanoseconds_total counter")
        
        metrics.append("# HELP systemd_service_memory_current_bytes Current memory usage in bytes")
        metrics.append("# TYPE systemd_service_memory_current_bytes gauge")
        
        metrics.append("# HELP systemd_service_tasks_current Number of current tasks")
        metrics.append("# TYPE systemd_service_tasks_current gauge")
        
        metrics.append("# HELP systemd_service_active Service active state (1=active, 0=inactive)")
        metrics.append("# TYPE systemd_service_active gauge")
        
        for service in self.podman_services:
            service_metrics = self.get_service_metrics(service)
            
            # Clean service name for labels
            service_label = service.replace('-', '_').replace('.service', '')
            
            # CPU usage
            cpu_usage = service_metrics.get('CPUUsageNSec', '0')
            if cpu_usage.isdigit():
                metrics.append(f'systemd_service_cpu_usage_nanoseconds_total{{service="{service}"}} {cpu_usage}')
            
            # Memory usage
            memory = service_metrics.get('MemoryCurrent', '0')
            if memory.isdigit():
                metrics.append(f'systemd_service_memory_current_bytes{{service="{service}"}} {memory}')
            
            # Tasks
            tasks = service_metrics.get('TasksCurrent', '0')
            if tasks.isdigit():
                metrics.append(f'systemd_service_tasks_current{{service="{service}"}} {tasks}')
            
            # Active state
            active_state = service_metrics.get('ActiveState', 'inactive')
            active_value = 1 if active_state == 'active' else 0
            metrics.append(f'systemd_service_active{{service="{service}"}} {active_value}')
        
        return '\n'.join(metrics) + '\n'

class MetricsHandler(BaseHTTPRequestHandler):
    def __init__(self, exporter, *args, **kwargs):
        self.exporter = exporter
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        if self.path == '/metrics':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(self.exporter.generate_metrics().encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

def main():
    exporter = SystemdExporter()
    
    def handler(*args, **kwargs):
        return MetricsHandler(exporter, *args, **kwargs)
    
    server = HTTPServer(('0.0.0.0', 9034), handler)
    print("Systemd exporter listening on port 9034")
    server.serve_forever()

if __name__ == '__main__':
    main()