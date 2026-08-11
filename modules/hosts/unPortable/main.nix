{
  den,
  lib,
  inputs,
  ...
}:
{
  den.aspects.unPortable = {
    nixos = { pkgs, ... }: {
      imports = [
        ./_hardware-configuration.nix
        inputs.disko.nixosModules.disko
      ];

      boot.loader.systemd-boot.enable = true;

      disko.devices =
        let
          username = "matt";
          dev = "nvme0n1";
          swapSize = "16G";
          btrfsRootName = "unPortable";
        in
        {
          disk = {
            ${btrfsRootName} = {
              type = "disk";
              device = "/dev/${dev}";
              content = {
                type = "gpt";
                partitions = {
                  ESP = {
                    priority = 1;
                    name = "ESP";
                    start = "1M";
                    end = "512M";
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [ "umask=0077" ];
                    };
                  };
                  root = {
                    size = "100%";
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ]; # Override existing partition
                      # Subvolumes must set a mountpoint in order to be mounted,
                      # unless their parent is mounted
                      subvolumes = {
                        # Subvolume name is different from mountpoint
                        "/root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "subvol=root"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        # Subvolume name is the same as the mountpoint
                        "/home" = {
                          mountOptions = [
                            "subvol=home"
                            "compress=zstd"
                            "noatime"
                          ];
                          mountpoint = "/home";
                        };
                        # Sub(sub)volume doesn't need a mountpoint as its parent is mounted
                        "/home/${username}" = { };
                        # Parent is not mounted so the mountpoint must be set
                        "/nix" = {
                          mountOptions = [
                            "subvol=nix"
                            "compress=zstd"
                            "noatime"
                          ];
                          mountpoint = "/nix";
                        };
                        "/nix/persist" = {
                          mountpoint = "/nix/persist";
                          mountOptions = [
                            "subvol=persist"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/log" = {
                          mountpoint = "/var/log";
                          mountOptions = [
                            "subvol=log"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/lib" = {
                          mountpoint = "/var/lib";
                          mountOptions = [
                            "subvol=lib"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/persist/swap" = {
                          mountpoint = "/swap";
                          swap.swapfile.size = swapSize;
                          # resumeDevice = true; # NOTE: works fine without it
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      fileSystems."/nix/persist".neededForBoot = true;
      fileSystems."/var/log".neededForBoot = true;
      fileSystems."/var/lib".neededForBoot = true;
    };
  };
}
