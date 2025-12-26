{
  inputs,
  lib,
  pkgs,
  system,
  ...
}: {
  flake-file = {
    inputs.flake-file.url = lib.mkDefault "github:vic/flake-file";
    inputs.den.url = lib.mkDefault "github:vic/den";

    formatter = pkgs.alejandra;
    nixConfig = {
      nixpkgs = import ../pkg-options.nix {inherit system inputs;};
    };
  };
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];
}
