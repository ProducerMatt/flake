{
  pkgs,
  inputs,
  system,
}:
with pkgs; [
  nix-detsys
  nixfmt
  git
  lazygit
  (inputs.disko.packages.${system}.default.override {nix = nix-detsys;})
  sops
  age
  nil
  nixd
]
