{
  lib,
  config,
  ...
}: let
  cfg = config.matt.syncthing;
in {
  options.matt.syncthing.enable = lib.mkEnableOption "run Syncthing";
  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [8384];
    services = {
      syncthing = {
        enable = true;
        user = "matt";
        group = "users";
        dataDir = "/home/matt/Sync";
        configDir = "/home/matt/.config/syncthing";
        overrideDevices = false; # overrides any devices added or deleted through the WebUI
        overrideFolders = false; # overrides any folders added or deleted through the WebUI
        guiAddress = "0.0.0.0:8384";
        openDefaultPorts = true;
      };
    };
  };
}
