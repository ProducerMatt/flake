{config, ...} @ args:
builtins.trace (builtins.attrNames args) (let
  mods = config.myLib.rakeLeaves ../nixos-modules;
in {
  flake.modules.nixosModules = mods;
  den.default.nixos.imports = builtins.attrValues mods;
})
