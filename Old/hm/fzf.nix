{
  myLib,
  mySources,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  programs.fish = {
    enable = true;
    plugins =
      map (plugin: (myLib.cleanForFish mySources."${plugin}"))
      [
        "fzf"
      ];
  };
}
