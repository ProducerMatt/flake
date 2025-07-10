{
  inputs,
  self,
  pkgs,
  lib,
  ...
}: let
  start_emacs = "emacsclient -c -a 'emacs'";

  myAliases = {
    l = "eza";
    ll = "eza -la";
    la = "eza -a";
    e = start_emacs;
    er = "systemctl --user restart emacs.service";
    v = "nvim";

    # quick cd
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    # internet ip
    # TODO: explain this hard-coded IP address
    myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

    # nix
    n = "nix";
    #np = "n profile";
    #ni = "np install";
    #nr = "np remove";
    #ns = "n search --no-update-lock-file";
    #nf = "n flake";
    #nepl = "n repl '<nixpkgs>'";
    #srch = "ns nixos";
    #orch = "ns override";
    mn = ''
      manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
    '';

    ## sudo
    #s = "sudo -E ";
    #si = "sudo -i";
    #se = "sudoedit";

    # nix
    nrb = "sudo nixos-rebuild";

    # fix nixos-option for flake compat
    nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

    ## systemd
    #ctl = "systemctl";
    #stl = "s systemctl";
    #utl = "systemctl --user";
    #ut = "systemctl --user start";
    #un = "systemctl --user stop";
    #up = "s systemctl start";
    #dn = "s systemctl stop";
    #jtl = "journalctl";

    # git
    gs = "git status";
    gcm = "git commit -m";
    gca = "git commit --amend";
    gcan = "git diff-index --quiet HEAD -- && git commit --amend --no-edit || begin; echo \"Error: Repository has uncommitted changes\"; false; end;";
  };
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
    # NOTE: Nixd generates a large amount of logs (in ~/.local/state/nvim/lsp.log).
    NIXD_FLAGS = "-log=error";

    EDITOR = "hx";
    VISUAL = "hx";
  };

  programs.fish = {
    enable = true;
    shellAliases = myAliases;
  };
  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ./bash_prompt.sh;
    shellAliases = myAliases;
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

  programs.helix = {
    enable = true;
    languages = {
      language-server = {
        nil = {
          command = lib.getExe pkgs.nil;
        };
        nixd = {
          command = lib.getExe pkgs.nixd;
        };
      };
      language = [
        {
          name = "nix";
          language-servers = ["nixd" "nil"];
          formatter.command = lib.getExe pkgs.alejandra;
        }
      ];
    };
    settings = {
      theme = "kanabox";

      editor = {
        color-modes = true;
        cursorline = true;
        bufferline = "multiple";

        soft-wrap.enable = true;

        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
          ignore = false;
        };

        indent-guides = {
          character = "┊";
          render = true;
          skip-levels = 1;
        };

        end-of-line-diagnostics = "hint";
        inline-diagnostics.cursor-line = "warning";

        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };

        statusline = {
          left = ["mode" "file-name" "spinner" "read-only-indicator" "file-modification-indicator"];
          right = ["diagnostics" "selections" "register" "file-type" "file-line-ending" "position"];
          mode.normal = "";
          mode.insert = "I";
          mode.select = "S";
        };
      };
    };
  };

  programs.pay-respects = {
    enable = true;
  };

  home.shell.enableShellIntegration = true;

  home.username = "matt";
  home.homeDirectory = "/home/matt";
  home.stateVersion = "25.05";
  # TODO: define this by system rather than in hm

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
