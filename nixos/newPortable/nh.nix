{self, ...}: {
  programs.nh = {
    enable = true;
    flake = self;
    clean = {
      enable = true;
      dates = "daily";
      # NOTE: keep 5 last generations or 3 days, whichever is greater
      extraArgs = "-k 5 -K 3d";
    };
  };
}
