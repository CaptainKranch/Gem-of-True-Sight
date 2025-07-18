{ inputs, outputs, ... }: {
  imports = [
    # House - HomeServer
    ../src/immich.nix
    ../src/arr.nix
    ../src/plex.nix
    ../src/hoarder.nix
    #../src/calibre.nix
    ../src/plane.nix
    # DBA & Analytics
    ../src/postgresql.nix
    ../src/minio.nix
    ../src/kestra.nix
    #../src/cdc.nix
    #../src/duckdb.nix
    # Monitoring
    #../src/cadvisor.nix
  ];
}
