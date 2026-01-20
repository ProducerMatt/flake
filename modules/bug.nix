{ inputs, ... }:
{
  den.hosts.x86_64-linux.igloo.users.tux = { };
  den.hosts.aarch64-darwin.apple.users.tim = { };

  # Use aspects to create a **minimal** bug reproduction
  den.aspects.igloo = {
    nixos = {
      nixos-module.enable = true;
    };
  };

  # rename "it works", evidently it has bugs
  flake.tests."test it works" =
    let
      tux = inputs.self.nixosConfigurations.igloo.config.users.users.tux;

      expr = inputs.self.nixosConfigurations.igloo.config.programs.fish.enable;

      expected = true;
    in
    {
      inherit expr expected;
    };
}
