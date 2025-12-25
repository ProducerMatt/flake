{
  pkgs,
  inputs,
  system,
}:
with pkgs; [
  nix-detsys
  alejandra
  git
  lazygit
  (inputs.disko.packages.${system}.default.override {nix = nix-detsys;})
  sops
  age
  nil
  nixd
]
