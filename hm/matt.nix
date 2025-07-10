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
    # NOTE: Nixd generates a large amount of logs (in ~/.local/state/nvim/lsp.log).
    NIXD_FLAGS = "-log=error";

    EDITOR = "hx";
    VISUAL = "hx";
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
