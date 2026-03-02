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
    (inputs.flake-parts.flakeModules.modules or {})
  ];

  # NixOS hosts with home-manager have global packages
  den.ctx.hm-host.nixos.home-manager.useGlobalPkgs = true;

  # this line enables den angle brackets syntax in modules.
  # in pure eval, __findFile must be imported in the flake module args to take effect
  _module.args.__findFile = den.lib.__findFile;
}
