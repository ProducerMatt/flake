{
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";

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
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nix-detsys.follows = "determinate/nix"; # yes this is possible

    impermanence.url = "github:nix-community/impermanence";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";

    templates.url = "github:ProducerMatt/nix-templates";

    sops-nix.url = "github:Mic92/sops-nix";

    nixos-wsl.url = "github:ProducerMatt/NixOS-WSL/detsys";
    nixos-wsl.inputs.determinate.follows = "determinate";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";
    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs-stable,
    flake-parts,
    nixpkgs-lib,
    ...
  } @ inputs: let
    inherit (nixpkgs-lib) lib;
    myLib = import ./my-lib.nix {inherit lib;};
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

      flake = let
        hm-hosts = import ./hm/default.nix;
      in {
        inherit flakeInfo myLib; # make available on self

        nixosModules =
          {
            inherit flakeInfoModule;
          }
          // myLib.rakeLeaves ./modules;

        # FIXME: defining hostnames in ./hm/default.nix
        homeConfigurations =
          lib.mapAttrs (
            _name: value:
              inputs.home-manager-stable.lib.homeManagerConfiguration value
          )
          hm-hosts;

        nixosConfigurations = let
          defaultSystem = {
            system,
            hostname,
          }:
            nixpkgs-stable.lib.nixosSystem {
              specialArgs = {
                inherit self inputs globals system myLib;
                modules = self.nixosModules;
              };
              modules = [
                ({modules, ...}: {imports = builtins.attrValues modules;})
                {nixpkgs.hostPlatform = system;}
                (let
                  f = ./pkg-options.nix;
                in {
                  _file = f;
                  config.nixpkgs = import f {inherit system inputs;};
                })
                ./nixos/${hostname}
                inputs.home-manager-stable.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.matt = hm-hosts.${hostname};
                    extraSpecialArgs = {inherit self inputs myLib;};
                  };
                }
              ];
            };
        in
          # TODO: make this all more sane
          builtins.listToAttrs (map (
              sys @ {hostname, ...}: {
                name = hostname;
                value = defaultSystem sys;
              }
            ) [
              {
                hostname = "newPortable";
                system = "x86_64-linux";
              }
              {
                hostname = "MattsDesktop2025-wsl";
                system = "x86_64-linux";
              }
            ]);
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
