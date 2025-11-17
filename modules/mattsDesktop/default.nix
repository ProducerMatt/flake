{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.matt.desktop;
in {
  options.matt.desktop = with lib; {
    enable = mkEnableOption "Use Matt's Desktop settings";
    sound = mkEnableOption "Enable sound systems";
    printing = mkEnableOption "Enable printing systems";
    displayLink = mkEnableOption "Enable DisplayLink support";
    autoStart = mkEnableOption "Start the GUI on boot";
    autoLogin = mkEnableOption "Autologin to the Desktop";
    windowManager = mkOption {
      description = "Which type of window manager to use.";
      type = with types;
        uniq (enum [
          "plasma6"
        ]);
      default = "plasma6";
    };
    remote = {
      enable = mkEnableOption "Enable remote desktop server";
      type = mkOption {
        description = "Which type of remote desktop service to use.";
        type = with types;
          uniq (enum [
            "RDP"
            "RDP-builtin"
            "rustdesk"
          ]);
        default = "RDP";
      };
      port = mkOption {
        description = "RDP port to listen on.";
        type = with types; uniq port;
        default = 3389;
      };
    };
  };
  config = with lib;
    mkIf cfg.enable (mkMerge [
      {
        ### DEFAULTS ###

        programs.firefox = {
          enable = true;
          package = pkgs.firefox-bin; # avoid compiling
        };

        ### ASSERTIONS ###
        assertions = [
          {
            assertion =
              (
                (cfg.remote.type == "rustdesk")
                && (cfg.windowManager == "plasma6")
              )
              -> (config.services.xserver.enable == true);
            message = "Rustdesk on Plasma6 needs X11 for unattended access. August 2025";
          }
        ];
      }
      {
        # Enable plasma
        services.xserver.enable = true;
        services.displayManager.sddm.enable = true;
        services.displayManager.sddm.wayland.enable = false;
        services.desktopManager.plasma6.enable = true;
        services.displayManager.defaultSession = "plasmax11";

        services.displayManager.autoLogin =
          if cfg.autoLogin
          then {
            enable = true;
            user = "matt";
          }
          else {enable = false;};

        # Configure keymap in X11
        services.xserver = {
          xkb.layout = "us";
          xkb.variant = "";
        };

        environment.systemPackages = with pkgs; [
          # graphics debug tools
          xorg.xdpyinfo
          glxinfo
          vulkan-tools
          libsForQt5.qt5.qttools.bin # qdbus

          kitty
        ];
        # Enable touchpad support (enabled default in most desktopManager).
        services.libinput.enable = true;
      }
      (mkIf cfg.displayLink {
        boot.extraModulePackages = with config.boot.kernelPackages; [
          evdi
        ];
        services.xserver.videoDrivers = [
          "modesetting"
          "displaylink"
          "evdi"
        ];
        services.xserver.displayManager.setupCommands = "${pkgs.displaylink}/bin/DisplayLinkManager &";
        environment.systemPackages = with pkgs; [
          displaylink
        ];
      })
      (
        mkIf cfg.remote.enable
        (mkMerge [
          (mkIf (cfg.remote.type == "RDP-builtin")
            {
              networking.firewall.allowedTCPPorts = [3389];
              networking.firewall.allowedUDPPorts = [3389];
            })
          (mkIf (cfg.remote.type == "RDP")
            {
              services.xrdp = {
                enable = true;
                audio.enable = true;
                openFirewall = true;
                inherit (cfg.remote) port;
                # FIXME:
                # defaultWindowManager = "startplasma-x11";
              };
            })
          (mkIf (cfg.remote.type == "rustdesk")
            {
              environment.systemPackages = [
                # rustdesk-flutter is supposedly more recent than rustdesk
                pkgs._unstable.rustdesk-flutter
              ];
              networking.firewall.allowedTCPPorts = [21118];
              networking.firewall.allowedUDPPorts = [21118];
            })
        ])
      )
      (mkIf cfg.sound {
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          # If you want to use JACK applications, uncomment this
          #jack.enable = true;

          # use the example session manager (no others are packaged yet so this is enabled by default,
          # no need to redefine it in your config for now)
          #media-session.enable = true;

          extraConfig.pipewire = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.quantum" = 2048;
              "default.clock.min-quantum" = 2048;
              "default.clock.max-quantum" = 8192;
            };
          };
        };
      })
      (mkIf cfg.printing {
        # Enable CUPS to print documents.
        services.printing.enable = true;
      })
    ]);
}
