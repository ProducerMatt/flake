{
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    home-manager-stable.url = "https://flakehub.com/f/nix-community/home-manager/0.2505";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    git-hooks-nix.url = "https://flakehub.com/f/cachix/git-hooks.nix/*";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

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

    sops-nix.url = "github:Mic92/sops-nix";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";
    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs-stable,
    flake-parts,
    ...
  } @ inputs: let
    globals = import ./globals.nix;
    flakeInfo = {
      inherit (self) lastModified lastModifiedDate narHash;
      rev = self.rev or "dirty";
      shortRev = self.shortRev or "dirty";
      revCount = self.revCount or "dirty";
      rootDir = builtins.path {
        path = ./.;
        name = "flakeRootDir";
      };
    };
    flakeInfoModule = {config, ...}: {
      users.motd = ''
        === ${config.networking.hostName} ===
        Flake revision #${builtins.toString flakeInfo.revCount} from ${flakeInfo.lastModifiedDate}
        Flake commit ${flakeInfo.shortRev}
      '';
      system.configurationRevision = flakeInfo.rev;
    };
    defaultPkgs = system:
      import nixpkgs-stable (import ./pkg-options.nix {inherit system inputs;});
    systems = import inputs.systems;
  in
    flake-parts.lib.mkFlake {
      inherit inputs;
    } ({
      withSystem,
      inputs,
      ...
    }: {
      debug = true; # DEBUG

      imports = [
        inputs.git-hooks-nix.flakeModule
      ];

      inherit systems;

      flake = {
        inherit flakeInfo; # make available on self

        homeConfigurations.matt = inputs.home-manager-stable.lib.homeManagerConfiguration (import ./hm/matt.nix);

        nixosConfigurations = {
          newPortable = let
            system = "x86_64-linux";
          in
            nixpkgs-stable.lib.nixosSystem {
              specialArgs = {inherit self inputs globals system;};
              modules = [
                {nixpkgs.hostPlatform = system;}
                flakeInfoModule
                (let
                  f = ./pkg-options.nix;
                in {
                  _file = f;
                  config.nixpkgs = import ./pkg-options.nix {inherit system inputs;};
                })
                inputs.home-manager-stable.nixosModules.home-manager
                inputs.determinate.nixosModules.default
                inputs.disko.nixosModules.disko
                inputs.sops-nix.nixosModules.sops
                inputs.impermanence.nixosModules.impermanence
                ./impermanence.nix
                ./nixos/newPortable/configuration.nix
                {
                  users.users.root.openssh.authorizedKeys.keys = [
                    globals.publicSSH
                  ];
                }
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.matt = ./hm/matt.nix;
                    extraSpecialArgs = {inherit self inputs;};
                  };
                }
              ];
            };
        };
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        _module.args.pkgs = defaultPkgs system;
        pre-commit = {
          settings = {
            default_stages = ["manual" "pre-push" "pre-merge-commit" "pre-commit"];
            hooks = let
              manual_only = {
                enable = true;
                stages = ["manual"];
              };
            in {
              alejandra.enable = true;
              check-added-large-files.enable = true;
              check-json.enable = true;
              check-merge-conflicts.enable = true;
              check-symlinks.enable = true;
              check-toml.enable = true;
              check-vcs-permalinks.enable = true;
              check-xml.enable = true;
              check-yaml.enable = true;
              detect-private-keys.enable = true;
              flake-checker.enable = true;
              pre-commit-hook-ensure-sops.enable = true;
              ripsecrets.enable = true;

              lychee = manual_only;
            };
          };
        };
        devShells = {
          default = pkgs.mkShell {
            packages =
              import ./shell-packages.nix {inherit system inputs pkgs;};
            inputsFrom = [config.pre-commit.devShell];
            shellHook = config.pre-commit.installationScript;
          };
        };
      };
    });
}
