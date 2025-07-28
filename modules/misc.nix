{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.matt.misc;
in {
  options.matt.misc.enable = lib.mkEnableOption "misc tweaks that I'd want on all systems";

  config = lib.mkIf cfg.enable {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    programs.nix-index-database.comma.enable = true;

    programs.nh = {
      enable = true;
      flake = "/home/matt/src/new_flake";
      clean = {
        enable = true;
        dates = "daily";
        # NOTE: keep 5 last generations or 3 days, whichever is greater
        extraArgs = "-k 5 -K 3d";
      };
    };

    # Set your time zone.
    time.timeZone = "America/Chicago";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };

    # Configure keymap in X11
    services.xserver.xkb.layout = "us";

    programs.fish.enable = true; # required for vendor distributions of autocomplete, etc.

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs;
      [
        neovim
        wget
        helix
        yazi
      ]
      ++ (import ../shell-packages.nix {inherit system inputs pkgs;});

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    security.sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = lib.mkForce false;
    };
    security.pam.sshAgentAuth.enable = true;

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  };
}
