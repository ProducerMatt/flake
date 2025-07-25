{
  system,
  inputs,
}: let
  config = {
    allowUnfree = true;
    checkMeta = true;
    warnUndeclaredOptions = true;
    # allow NixOS system config cross compilation
    allowUnsupportedSystem = true;
  };
in {
  inherit system config;
  overlays = let
    gimme = title: name: (_final: _prev: {
      ${name} = inputs.${name}.packages.${system}.${title};
    });
  in [
    #(gimme "default" "nixpkgs-hammering")
    #(gimme "nix-btm" "nix-btm")
    inputs.nix-detsys.overlays.default
    (gimme "nix" "nix-detsys")
    (gimme "nil" "nil")
    (gimme "nixd" "nixd")

    inputs.emacs-overlay.overlays.default
    (_: _: {
      _unstable = import inputs.nixpkgs {inherit system config;};
    })
  ];
}
