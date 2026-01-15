{inputs, ...}: let
  inherit (inputs.nixpkgs-stable) lib;
  mods = (import ../my-lib.nix lib).rakeLeavesF (p: p) ../nixos-modules;
in {
  flake.modules.nixos = builtins.mapAttrs (_: p: import p) mods;
  den.default.nixos.imports =
    builtins.attrValues mods;
}
