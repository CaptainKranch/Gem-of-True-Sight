{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [ dbeaver-bin ];
}
