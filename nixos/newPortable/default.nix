# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  inputs,
  pkgs,
  ...
}: let
  globals = import ../../globals.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./intel-powersaving.nix
    ../../home-network.nix
  ];

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

  services.udev.extraRules = ''
    # Disable autosuspend for RME Babyface
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0424", ATTR{idProduct}=="*", TEST=="power/control", ATTR{power/control}="on"
  '';
  # # Create a service that holds the latency constraint open
  # systemd.services.rme-low-latency = {
  #   description = "CPU latency constraint for RME Babyface";
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'exec 3>/dev/cpu_dma_latency; echo 0 >&3; sleep infinity'";
  #     Restart = "no";
  #   };
  # };

  # # udev rule to start/stop the service
  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2a39", TAG+="systemd", ENV{SYSTEMD_WANTS}="rme-low-latency.service"
  #   ACTION=="remove", SUBSYSTEM=="usb", ATTR{idVendor}=="2a39", RUN+="${pkgs.systemd}/bin/systemctl stop rme-low-latency.service"
  # '';
}
