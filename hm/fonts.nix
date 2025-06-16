{pkgs, ...}: {
  home.packages = with pkgs;
    builtins.concatLists [
      (import ../../profiles/font-list.nix pkgs)
      [
        ttfautohint
      ]
    ];
  fonts = {
    fontconfig.enable = true;
  };
}
