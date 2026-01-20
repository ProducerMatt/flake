# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{den, ...}: {
  den.aspects.newPortable = {
    includes = [
      den.aspects.matt
      den.aspects.backuppc
      den.aspects.syncthing
      den.aspects.misc
      den.aspects.mattsDesktop
      den.aspects.home-network
    ];
    homeManager.home.stateVersion = "25.05";
    nixos = {
      imports = [
        # Include the results of the hardware scan.
        ./_newPortable/hardware-configuration.nix
        # ./intel-powersaving.nix
      ];

      matt.home-network.enable = true;

      matt.impermanence = {
        enable = true;
        swapsize = "16G";
      };
      matt.misc.enable = true;
      matt.misc.flake-location = "/home/matt/src/new_flake";
      matt.nix-settings.enable = true;
      matt.extra-substituters.list = [../../substituters.nix];
      matt.desktop = {
        enable = true;
        sound = true;
        printing = true;
        autoStart = true;
        autoLogin = true;
        remote = {
          enable = true;
          type = "rustdesk";
        };
      };
      matt.syncthing.enable = true;
      matt.backuppc.enable = true;

      boot.loader.systemd-boot.enable = true;

      networking = {
        hostName = "newPortable";
        useDHCP = false;
        interfaces = {
          "enp112s0" = {
            useDHCP = false;
            ipv4.addresses = [
              {
                address = "192.168.1.5";
                prefixLength = 16;
              }
            ];
          };
        };
      };

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;

      nixpkgs.config.allowUnfree = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # power.ups = {
      #   enable = true;
      #   ups."APCBackUPS1500" = {
      #     driver = "apcupsd";
      #   };
      # };
      # services.apcupsd.enable = true;

      services.pipewire.extraConfig = {
        pipewire = {
          "0-force-buffer" = {
            "context.properties" = {
              "default.clock.min-quantum" = "1024";
            };
          };
        };
        pipewire-pulse = {
          "0-force-buffer" = {
            "pulse.properties" = {
              "pulse.min.req" = "1024/48000";
              "pulse.min.frag" = "1024/48000";
              "pulse.min.quantum" = "1024/48000";
            };
          };
        };
      };
    };
  };
}
