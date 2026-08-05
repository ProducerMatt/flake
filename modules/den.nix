{ inputs, ... }: {
  imports = [ inputs.den.flakeModule ];
  flake.inputs = inputs;
}
