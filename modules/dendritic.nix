{
  inputs,
  lib,
  pkgs,
  ...
}: {
  flake-file = {
    inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
    inputs.den.url = lib.mkDefault "github:vic/den";

    formatter = pkgs: pkgs.alejandra;
  };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
}
