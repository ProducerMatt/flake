{ inputs, ... }: {
  imports = [ inputs.den.flakeModule ];
  flake.inputs = inputs;

  den.hosts.x86_64-linux.unPortable = { };
}
