{
  den.aspects.home-manager = {
    homeManager = {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      manual.manpages.enable = true;
    };
  };
}
