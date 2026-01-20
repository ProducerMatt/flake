# DO-NOT-CHANGE. Keep your reproduction minimalistic!
#
# try not adding new inputs
# but if you have no options (pun intended)
# here's the place.
#
# IF you make any change to this file, use:
#   `nix run .#write-flake`
#
# We provide nix-darwin and home-manager for common usage.
{
  # change "main" with a commit where bug is present
  flake-file.inputs.den.url = "github:vic/den/main";

  # included so we can test HM integrations.
  flake-file.inputs.home-manager = {
    url = "https://flakehub.com/f/nix-community/home-manager/0.2505";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";

  # included for testing darwin hosts.
  flake-file.inputs.darwin = {
    url = "github:nix-darwin/nix-darwin";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
