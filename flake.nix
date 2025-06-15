{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    home-manager-stable.url = "https://flakehub.com/f/nix-community/home-manager/0.2505";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    git-hooks.url = "https://flakehub.com/f/cachix/git-hooks.nix/*";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";

    # DeterminateSystems nix branch with extra features
    nix-detsys.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs-stable, ... }@inputs:
    let
      flakeInfo = {
        inherit (self) lastModified lastModifiedDate narHash;
        rev = self.rev or "dirty";
        shortRev = self.shortRev or "dirty";
        revCount = self.revCount or "dirty";
        rootDir = builtins.path {path = "./."; name= "flakeRootDir";};
      };
      flakeInfoModule = ({ config, ... }: {
        users.motd = ''
          === ${config.networking.hostName} ===
          Flake revision #${builtins.toString flakeInfo.revCount} from ${flakeInfo.lastModifiedDate}
          Flake commit ${flakeInfo.shortRev}
        '';
        system.configurationRevision = flakeInfo.rev;
      });

    in {
      nixosConfigurations.newPortable = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          flakeInfoModule
          inputs.determinate.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          inputs.disko.nixosModules.disko
          # inputs.impermanence.nixosModules.impermanence
          ./nixos/newPortable/configuration.nix
        ];
      };
    };
}
