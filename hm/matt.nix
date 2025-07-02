{
  inputs,
  self,
  pkgs,
  lib,
  ...
}: let
  start_emacs = "emacsclient -c -a 'emacs'";
in {
  imports = [
    ./core.nix
    inputs.nix-index-database.hmModules.nix-index
  ];

  programs.nix-index-database.comma.enable = true;

  programs.gpg.enable = true;

  home.sessionVariables = {
    FLAKE = self.flakeInfo.rootDir;
    REALNAME = "ProducerMatt";
    EMAIL = "ProducerMatt42@gmail.com";
    KEYID = "E6EA80E5CB3E1F9C";
    TERM = "xterm-direct";
    COLORTERM = "truecolor";

    EDITOR = start_emacs;
    VISUAL = start_emacs;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userEmail = "58014742+ProducerMatt@users.noreply.github.com";
    userName = "Producer Matt";
    lfs.enable = true;
    extraConfig = {
      init = {defaultBranch = "main";};
      pull = {rebase = false;}; # setting to true was a mistake
    };
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
  };

  languages = {
    language-server = {
      nil = {
        command = lib.getExe pkgs.nil;
      };
      nixd = {
        command = lib.getExe pkgs.nixd;
      };
      language = [
        {
          name = "nix";
          language-servers = ["nixd" "nil"];
          formatter.command = lib.getExe pkgs.alejandra;
        }
      ];
    };
  };

  programs.pay-respects = {
    enable = true;
  };

  home.shell.enableShellIntegration = true;

  home.username = "matt";
  home.homeDirectory = "/home/matt";
  home.stateVersion = "25.05";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
