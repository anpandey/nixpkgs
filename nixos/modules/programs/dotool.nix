{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.dotool;
in
{
  options.programs.dotool = {
    enable = mkEnableOption (lib.mdDoc ''
      Whether to enable dotool program without needing root access. Users still
      need to be a member of the 'input' group to use it.
    '');
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ dotool ];
    services.udev.packages = [ pkgs.dotool-udev-rules ];
  };
}
