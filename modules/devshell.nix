{ inputs, ... }:
{
  imports = [inputs.git-hooks.flakeModule];
  perSystem = { config, system, pkgs, ... }: {
    pre-commit = {
      check.enable = true;
      settings = {
        src = ./../.;
        default_stages = ["manual" "pre-push" "pre-merge-commit" "pre-commit"];
        hooks = let
          manual_only = {
            enable = true;
            stages = ["manual"];
          };
        in {
          alejandra.enable = true;
          check-added-large-files.enable = true;
          check-json.enable = true;
          check-merge-conflicts.enable = true;
          check-symlinks.enable = true;
          check-toml.enable = true;
          check-vcs-permalinks.enable = true;
          check-xml.enable = true;
          check-yaml.enable = true;
          detect-private-keys.enable = true;
          flake-checker.enable = true;
          pre-commit-hook-ensure-sops.enable = true;
          ripsecrets.enable = true;

          lychee = manual_only;
        };
      };
    };
    devShells = {
      default = let
        inherit (config.pre-commit.settings) shellHook enabledPackages;
      in
        pkgs.mkShell {
          packages =
            import ./../shell-packages.nix {inherit system inputs pkgs;};
          inputsFrom = enabledPackages;
          shellHook = shellHook;
        };
      };
  };
}
