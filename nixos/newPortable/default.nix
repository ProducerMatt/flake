# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  inputs,
  lib,
  pkgs,
  system,
  ...
}: let
  globals = import ../../globals.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nh.nix
    # ./intel-powersaving.nix
    ../../home-network.nix
    inputs.nix-index-database.nixosModules.nix-index
  ];

  matt.impermanence = {
    enable = true;
    swapsize = "16G";
  };
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

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "vboxusers"];
    initialHashedPassword = "$6$cXUmEOPi4lj1p.U8$hhR4ZLi6Nj/jTGBvFhNmWI4fozrtWcgh3tkZ8b93Hb5mMIU9fgTDT0mtdHFQhPNol9HSylwnO69th.Fm4BKYj/";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      globals.publicSSH
      ''
        from="192.168.1.4",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0MTVh6Bi82YLKJlpo+4fQRQ3mhZWXFD7VcZEPPWHWA backup@BackupPC
      ''
      #''
      #  from="192.168.1.4",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty,command="rrsync -ro /home/matt" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0MTVh6Bi82YLKJlpo+4fQRQ3mhZWXFD7VcZEPPWHWA backup@BackupPC
      #''
    ];
  };

  programs.fish.enable = true; # required for vendor distributions of autocomplete, etc.

  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs;
    [
      neovim
      wget
      helix
      yazi
    ]
    ++ (import ../../shell-packages.nix {inherit system inputs pkgs;});

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
  programs.nix-index-database.comma.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
