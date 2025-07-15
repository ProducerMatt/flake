{
  self,
  pkgs,
  myLib,
  ...
}: {
  imports = [
    ./core.nix
    ./nix-index.nix
    ./git-settings.nix
    ./helix.nix
    ./shell-usability.nix
  ];

  home.packages =
    builtins.concatMap
    (name: myLib.getSharedPkgList pkgs name)
    [
      "base_cli"
      "dev"
      "git"
      "sysadmin"
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

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      prettybat
    ];
    config = {
      italic-text = "always";
      map-syntax = [
        "*.ino:C++"
        ".ignore:Git Ignore"
      ];
      pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
      theme = "TwoDark";
    };
  };

  home.username = "matt";
  home.homeDirectory = "/home/matt";
  home.stateVersion = "25.05";
  # TODO: define this by system rather than in hm
}
