{inputs, ...}: {
  # must declare host and user here to work
  den.hosts.x86_64-linux.newPortable = {
    instantiate = {modules}:
      inputs.nixpkgs-stable.lib.nixosSystem {
        inherit modules;
        specialArgs = {inherit inputs;};
      };
    users.matt = {};
  };
  den.homes.x86_64-linux.matt = {};
}
