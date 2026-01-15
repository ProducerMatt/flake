{lib, ...}: let
  mods = (import ../my-lib.nix lib).rakeLeaves ../nixos-modules;
in {
  flake.modules.nixos = mods;
  den.default.nixos.imports = builtins.attrValues mods;
}
