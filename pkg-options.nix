{
  system,
  inputs,
}: {
  inherit system;
  config = {
    allowUnfree = true;
    checkMeta = true;
    warnUndeclaredOptions = true;
  };
  overlays = let
    gimme = title: name: (_final: _prev: {
      ${name} = inputs.${name}.packages.${system}.${title};
    });
  in [
    #(gimme "default" "nixpkgs-hammering")
    #(gimme "nix-btm" "nix-btm")
    inputs.nix-detsys.overlays.default
    (gimme "nix" "nix-detsys")
    #(gimme "nil" "nil")
    #(gimme "nixd" "nixd")
    inputs.emacs-overlay.overlays.default
  ];
}
