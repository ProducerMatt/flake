pkgs:
with pkgs; [
  neovim
  emacs-unstable
  nixos-generators
  #nox
  niv
  nixpkgs-review
  nixpkgs-hammering
  nix-init
  nix-diff
  nix-output-monitor
  nix-du
  nix-melt
  alejandra
  nix-btm
  nix-inspect
  nh

  stdenv
  gnumake
  resolve-march-native # find appropriate compiler flags for your cpu
  remarshal # convert between config file formats
  rtx # https://github.com/jdxcode/rtx
  diffoscope # extensive diff tool -- directories, PDF files, ISOs, etc

  #ansible
  #ansible-lint
  #ansible-later
  #ansible-language-server

  editorconfig-core-c
  editorconfig-checker
]
