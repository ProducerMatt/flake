{self, ...}: {
  imports = [
    ./core.nix
    ./nix-index.nix
    ./git-settings.nix
    ./helix.nix
    ./shell-usability.nix
  ];

  programs.gpg.enable = true;

  home.sessionVariables = {
    FLAKE = self.flakeInfo.rootDir;
    REALNAME = "ProducerMatt";
    EMAIL = "ProducerMatt42@gmail.com";
    KEYID = "E6EA80E5CB3E1F9C";
    # NOTE: Nixd generates a large amount of logs (in ~/.local/state/nvim/lsp.log).
    NIXD_FLAGS = "-log=error";
  };

  home.username = "matt";
  home.homeDirectory = "/home/matt";
  home.stateVersion = "25.05";
  # TODO: define this by system rather than in hm
}
