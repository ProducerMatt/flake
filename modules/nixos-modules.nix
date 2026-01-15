{lib, ...} @ args:
builtins.trace (builtins.attrNames args) (let
  mods = (import ../my-lib.nix lib).rakeLeaves ../nixos-modules;
in {
  flake.modules.nixosModules = mods;
  den.default.nixos.imports = builtins.attrValues mods;
})
