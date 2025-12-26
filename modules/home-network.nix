{
  flake.modules.nixos.matt-home-network = {
    config,
    lib,
    ...
  }: let
    cfg = config.matt.home-network;
  in {
    config = lib.mkIf cfg.enable {
      networking = {
        defaultGateway = "192.168.1.1";
        nameservers = [
          "192.168.1.16"
          "192.168.1.61"
        ];
        hosts = {
          "192.168.1.3" = ["PherigoNAS.local"];
          "192.168.1.5" = ["PortableNix.local"];
          "192.168.1.10" = ["BabyDell.local"];
        };
      };
      fileSystems = {
        "/media/FamilyNAS" = {
          device = "PherigoNAS.local:/mnt/PherigoRAID/Family";
          fsType = "nfs";
          options = [
            "nfsvers=4"
            "noatime"
            "noexec"
          ];
        };
        "/media/PublicNAS" = {
          device = "PherigoNAS.local:/mnt/PherigoRAID/Public";
          fsType = "nfs";
          options = [
            "nfsvers=4"
            "noatime"
            "noexec"
          ];
        };
        "/media/MattNAS" = {
          device = "PherigoNAS.local:/mnt/PherigoRAID/Matt";
          fsType = "nfs";
          options = [
            "nfsvers=4"
            "noatime"
            "noexec"
          ];
        };
      };
    };
  };
}
