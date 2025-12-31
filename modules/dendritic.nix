{
  inputs,
  lib,
  den,
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

  # this line enables den angle brackets syntax in modules.
  # in pure eval, __findFile must be imported in the flake module args to take effect
  _module.args.__findFile = den.lib.__findFile;
}
