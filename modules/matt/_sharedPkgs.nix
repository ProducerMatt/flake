pkgs: {
  base-cli = with pkgs; [
    coreutils
    croc
    eza
    fish
    htop # top alternative
    #bottom # top alternative
    p7zip
    tmux
    vim
    helix
    bat
    wget
    fd
    ripgrep
    aria2
    #libressl
    parallel # xargs but multi-core
    #tere
    bind.dnsutils
    lsof # list files and sockets in use
    fzf
    dua # disk space usage analyser
  ];
  dev = with pkgs; [
    nixos-generators
    #nox
    niv
    nixpkgs-review
    nixpkgs-hammering
    #nix-init # useful but too hefty to be in your env
    nix-diff
    nix-output-monitor
    nix-du
    nix-melt
    alejandra
    nix-btm
    nix-inspect
    nh

    resolve-march-native # find appropriate compiler flags for your cpu
    remarshal # convert between config file formats
    rtx # https://github.com/jdxcode/rtx
    #diffoscope # extensive diff tool -- directories, PDF files, ISOs, etc

    #ansible
    #ansible-lint
    #ansible-later
    #ansible-language-server

    editorconfig-core-c
    editorconfig-checker
  ];
  git = with pkgs; [
    git-crypt
    lazygit
    git-ignore
    ripsecrets
  ];
  sysadmin = with pkgs; [
    ethtool
    smartmontools
    lsof # list files and sockets in use
    dua # disk space usage analyser
    #(nur.repos.ProducerMatt.cosmo.override {
    #    appList = ["pledge"];
    #    distRepo = false;
    #  })
  ];
}
