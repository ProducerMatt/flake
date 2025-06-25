{
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";

    clan-core.url = "git+https://git.clan.lol/clan/clan-core";

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

  outputs = { self, nixpkgs-stable, clan-core, ... }@inputs:
    let
      globals.publicSSH = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfK6c9SiwYYRxy10EMVh1sctDgy6JN/fMyzsO1hACnN Matt's private login key";
      flakeInfo = {
        inherit (self) lastModified lastModifiedDate narHash;
        rev = self.rev or "dirty";
        shortRev = self.shortRev or "dirty";
        revCount = self.revCount or "dirty";
        rootDir = builtins.path {path = ./.; name= "flakeRootDir";};
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
      clan = clan-core.lib.buildClan {
        inherit self;
        specialArgs = {};
        meta.name = "Deltarune";

        machines = {
          newPortable = let
            system = "x86_64-linux";
            specialArgs = {inherit self inputs system globals;};
          in {
            inherit specialArgs;
            nixpkgs.hostPlatform = system;
            imports = [
              flakeInfoModule
              {nixpkgs = (import ./pkg-options.nix {inherit system inputs;});}
              inputs.home-manager-stable.nixosModules.home-manager
              inputs.determinate.nixosModules.default
              inputs.disko.nixosModules.disko
              inputs.impermanence.nixosModules.impermanence
              ./impermanence.nix
              ./nixos/newPortable/configuration.nix
              {users.users.root.openssh.authorizedKeys.keys = [ globals.publicSSH ];}
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.matt = ./hm/matt.nix;
                home-manager.extraSpecialArgs = specialArgs;
              }
            ];
          };

        };
      };
    in {
      devShells = eachSystem (system: let
        pkgs = defaultPkgs system;
      in {
        default = pkgs.mkShell {
          packages =
            import ./shell-packages.nix {inherit system inputs pkgs;};
        };
      });

      inherit flakeInfo; # make available on self
      inherit (clan) nixosConfigurations clanInternals;

      clan = {
        inherit (clan) templates;
      };

      homeConfigurations.matt = inputs.home-manager-stable.lib.homeManagerConfiguration (import ./hm/matt.nix);
    };
}
