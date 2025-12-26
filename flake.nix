# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    den.url = "github:vic/den";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    disko.url = "github:nix-community/disko/latest";
    emacs-overlay = {
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
      url = "github:nix-community/emacs-overlay";
    };
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    git-hooks-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://flakehub.com/f/cachix/git-hooks.nix/*";
    };
    home-manager-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "https://flakehub.com/f/nix-community/home-manager/0.2505";
    };
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    nil.url = "github:oxalica/nil";
    nix-detsys.follows = "determinate/nix";
    nix-index-database = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-index-database";
    };
    nixd.url = "github:nix-community/nixd";
    nixos-wsl = {
      inputs.determinate.follows = "determinate";
      url = "github:ProducerMatt/NixOS-WSL/detsys";
    };
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";
    nixpkgs-lib.follows = "nixpkgs";
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    sops-nix.url = "github:Mic92/sops-nix";
    systems.url = "github:nix-systems/x86_64-linux";
    templates.url = "github:ProducerMatt/nix-templates";
  };
}
