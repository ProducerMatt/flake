{
  den,
  __findFile,
  ...
}: let
  shared = import ./_sharedPkgs.nix;
  sharedPkgs = pkgs:
    builtins.concatMap
    (name: shared.${name} pkgs)
    [
      "base_cli"
      "dev"
      "git"
      "sysadmin"
    ];
in {
  den.aspects.matt = {
    includes = [
      <den/primary-user> # matt is admin always.
      (<den/user-shell> "fish") # default user shell
      den.aspects.home-manager
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = sharedPkgs pkgs;
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.matt = {
        isNormalUser = true;
        extraGroups = ["vboxusers"];
        initialHashedPassword = "$6$cXUmEOPi4lj1p.U8$hhR4ZLi6Nj/jTGBvFhNmWI4fozrtWcgh3tkZ8b93Hb5mMIU9fgTDT0mtdHFQhPNol9HSylwnO69th.Fm4BKYj/";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfK6c9SiwYYRxy10EMVh1sctDgy6JN/fMyzsO1hACnN Matt's private login key"
          ''
            from="192.168.1.3",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0MTVh6Bi82YLKJlpo+4fQRQ3mhZWXFD7VcZEPPWHWA backup@BackupPC
          ''
          #''
          #  from="192.168.1.3",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty,command="rrsync -ro /home/matt" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0MTVh6Bi82YLKJlpo+4fQRQ3mhZWXFD7VcZEPPWHWA backup@BackupPC
          #''
        ];
      };
    };
    homeManager = {pkgs, ...}: {
      home.packages = sharedPkgs pkgs;

      programs.gpg.enable = true;

      home.sessionVariables = {
        REALNAME = "ProducerMatt";
        EMAIL = "ProducerMatt42@gmail.com";
        KEYID = "E6EA80E5CB3E1F9C";
        # NOTE: Nixd generates a large amount of logs (in ~/.local/state/nvim/lsp.log).
        NIXD_FLAGS = "-log=error";
      };

      programs.bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          prettybat
        ];
        config = {
          italic-text = "always";
          map-syntax = [
            "*.ino:C++"
            ".ignore:Git Ignore"
          ];
          pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
          theme = "TwoDark";
        };
      };
    };
  };
}
