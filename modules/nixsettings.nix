{inputs, ...}: {
  den.default = {
    nixos = {
    lib,
    config,
    ...
  }: let
    inherit (lib) mkIf mkEnableOption;
    cfg = config.matt.nix-settings;
  in {
    imports = [
      inputs.determinate.nixosModules.default
    ];

    options.matt.nix-settings.enable = mkEnableOption "enable my Nix settings";

    config = mkIf cfg.enable {
      # https://github.com/DeterminateSystems/determinate/pull/88
      environment.etc."nix/nix.conf".target = "nix/nix.custom.conf";

      # NOTE: these are set in ../pkg-options.nix
      # nixpkgs.config.allowUnfree = true;
      nix = {
        extraOptions = ''
          experimental-features = nix-command flakes ca-derivations recursive-nix
          keep-outputs = true
          keep-derivations = true
          # When only 1Gig free, try to free up to 5 gigs
          min-free = ${toString (1024 * 1024 * 1024)}
          max-free = ${toString (1024 * 1024 * 1024 * 5)}
        '';
        # on my local network, builders-use-substitutes slows it down
        # # NOTE: handled by nh
        #gc = {
        #  automatic = true;
        #  dates = "weekly";
        #  options = "--delete-older-than 14d";
        #};
        optimise = {
          automatic = true;
          dates = ["weekly"];
        };
        settings = {
          # slows performance of writes, let weekly optimize get it
          auto-optimise-store = false;
          trusted-users = ["root" "matt" "nixremote"];
          # extra-trusted-public-keys = [
          #   "cache.PherigoNAS.local-1:an8uYbjcJQKUvSdBEe/hlAbbHGDFH+sZZK6PpAQlSn8="
          # ];
          lazy-trees = true; # Determinate Systems Nix required
          eval-cores = 0;
        };
        registry = let
          # NOTE: determinate already sets this
          filtered = lib.filterAttrs (name: _value: name != "nixpkgs") inputs;
        in
          builtins.mapAttrs (name: flake: {
            from = {
              id = name;
              type = "indirect";
            };
            inherit flake;
          })
          filtered;
      };
    };
  };
};}
