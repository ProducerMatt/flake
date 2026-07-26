{
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";

    flake-parts.url = "github:hercules-ci/flake-parts";

    den.url = "github:denful/den";
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";

    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2505";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "https://flakehub.com/f/cachix/git-hooks.nix/*";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    disko.url = "github:nix-community/disko/latest";

    # DeterminateSystems nix branch with extra features
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nix-detsys.follows = "determinate/nix";
    # THIS MAKES nix.detsys SOURCE FROM determinate LOCKFILE
    # yes this is possible :O

    impermanence.url = "github:nix-community/impermanence";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs";

    templates.url = "github:ProducerMatt/nix-templates";

    sops-nix.url = "github:Mic92/sops-nix";

    nixos-wsl.url = "github:ProducerMatt/NixOS-WSL/detsys";
    nixos-wsl.inputs.determinate.follows = "determinate";

    nil.url = "github:oxalica/nil";
    nixd.url = "github:nix-community/nixd";
    # NOTE: if I don't nixpkgs.follows then maybe the rebuild demon won't get me (delusional)
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
