{
  lib,
  pkgs,
  ...
}: {
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
      theme = "iroaseta";

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
          left = ["mode" "spinner" "selections" "register"];
          center = ["file-name" "position" "read-only-indicator" "file-modification-indicator" "version-control"];
          right = ["diagnostics" "file-type" "file-line-ending"];
          mode.normal = "";
          mode.insert = "I";
          mode.select = "S";
        };
      };
    };
  };
}
