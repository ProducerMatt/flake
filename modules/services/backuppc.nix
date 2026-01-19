{
  den.aspects.backuppc.nixos = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.matt.backuppc;
  in {
    options.matt.backuppc = {
      enable = lib.mkEnableOption "my backuppc setup";
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.rsync-bpc
        pkgs.rrsync-bpc
        #pkgs.sshdo
      ];
    };
  };
}
