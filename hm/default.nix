{
  newPortable = {
    imports = [
      ./matt.nix
    ];

    home.username = "matt";
    home.homeDirectory = "/home/matt";
    home.stateVersion = "25.05";
  };
  MattsDesktop2025 = {
    imports = [
      ./matt.nix
    ];

    # TODO: double check
    home.username = "matt";
    home.homeDirectory = "/home/matt";
    home.stateVersion = "25.05";
  };
}
