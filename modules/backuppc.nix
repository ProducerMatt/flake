{
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
    services.openssh.authorizedKeys.keys = [
      ''
        from="192.168.1.3",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0MTVh6Bi82YLKJlpo+4fQRQ3mhZWXFD7VcZEPPWHWA backup@BackupPC
      ''
      #''
      #  from="192.168.1.3",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty,command="rrsync -ro /home/matt" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0MTVh6Bi82YLKJlpo+4fQRQ3mhZWXFD7VcZEPPWHWA backup@BackupPC
      #''
    ];
  };
}
