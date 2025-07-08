{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    (chromium.override {
      enableWideVine = true;
    })
  ];
}
