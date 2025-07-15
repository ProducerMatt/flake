{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.types) listOf pathInStore;
  first = x: builtins.elemAt x 0;
  second = x: builtins.elemAt x 1;

  cfg = config.matt.extra-substituters;
in {
  options.matt.extra-substituters.list = {
    description = "list of Nix files with extra substituters to trust";
    type = listOf pathInStore;
    default = [];
  };
  config = mkIf (cfg.list != []) (let
    sources = builtins.concatMap import cfg.list;
    names = map first sources;
    keys = map second sources;
  in {
    nix.settings = {
      extra-substituters = names;
      extra-trusted-substituters = names;
      extra-trusted-public-keys = keys;
    };
  });
}
