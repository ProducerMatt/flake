{
  lib,
  pkgs,
  config,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  manual.manpages.enable = true;

  systemd.user = {
    services = {
      expire-hm-profiles = {
        Unit.Description = "Clean up HM user profiles.";

        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "expire-hm-profiles-start-script";
            text = ''
              ${lib.getExe config.nix.package} profile wipe-history \
                --profile "${config.xdg.stateHome}/nix/profiles/home-manager" \
                --older-than '14d'
            '';
          });
        };
      };
    };
    timers.expire-hm-profiles = {
      Unit.Description = "Clean up HM user profiles.";

      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
      };

      Install.WantedBy = ["timers.target"];
    };
  };
}
