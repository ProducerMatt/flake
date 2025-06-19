{
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";

    flake-parts.url = "github:hercules-ci/flake-parts";

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

    impermanence.url = "github:nix-community/impermanence";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    templates.url = "github:ProducerMatt/nix-templates";
  };

  outputs = { self, nixpkgs-stable, flake-parts, ... }@inputs:
    let
      importApply = flake-parts.lib.importApply;
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
      defaultPkgs = system:
        import nixpkgs-stable (import ./pkg-options.nix {inherit system inputs;});
      systems = (import inputs.systems);
      eachSystem = nixpkgs-stable.lib.genAttrs systems;
    in {
      devShells = eachSystem (system: let
        pkgs = defaultPkgs system;
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nix-detsys
            alejandra
            git
            (inputs.disko.packages.${system}.default.override {nix = nix-detsys;})
          ];
        };
      });
      inherit flakeInfo; # make available on self

      nixosConfigurations.newPortable = let
        system = "x86_64-linux";
        specialArgs = {inherit self inputs;};
      in nixpkgs-stable.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          flakeInfoModule
          {nixpkgs = (import ./pkg-options.nix {inherit system inputs;});}
          inputs.home-manager-stable.nixosModules.home-manager
          inputs.determinate.nixosModules.default
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          ./impermanence.nix
          ./nixos/newPortable/configuration.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.matt = ./hm/matt.nix;
            home-manager.extraSpecialArgs = specialArgs;
          }
        ];
      };

      homeConfigurations.matt = inputs.home-manager-stable.lib.homeManagerConfiguration (import ./hm/matt.nix);
    };
}
