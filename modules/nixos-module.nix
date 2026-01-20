{
  den.aspects.nixos-module.nixos = {config, lib, ...}: let
    cfg = config.nixos-module;
    in {
      options.nixos-module = {
        enable = lib.mkEnableOption "test";
      };
      config = lib.mkIf cfg.enable {
        programs.fish.enable = true;
      };
    };
}
