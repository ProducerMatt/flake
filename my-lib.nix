{lib}:
with builtins;
with lib; let
  recursiveMap = f:
    mapAttrs (_name: value: (
      if builtins.isAttrs value
      then (recursiveMap f value)
      else (f value)
    ));
  flattenTree =
    /*
      from divnix/digga, under the MIT license
    *
    Synopsis: flattenTree _tree_

    Flattens a _tree_ of the shape that is produced by rakeLeaves.

    Output Format:
    An attrset with names in the spirit of the Reverse DNS Notation form
    that fully preserve information about grouping from nesting.

    Example input:
    ```
    {
    a = {
    b = {
    c = <path>;
    };
    };
    }
    ```

    Example output:
    ```
    {
    "a.b.c" = <path>;
    }
    ```
    *
    */
    tree: let
      op = sum: path: val: let
        pathStr = builtins.concatStringsSep "." path; # dot-based reverse DNS notation
      in
        if builtins.isPath val
        then
          # builtins.trace "${toString val} is a path"
          (sum
            // {
              "${pathStr}" = val;
            })
        else if builtins.isAttrs val
        then
          # builtins.trace "${builtins.toJSON val} is an attrset"
          # recurse into that attribute set
          (recurse sum path val)
        else
          # ignore that value
          # builtins.trace "${toString path} is something else"
          sum;

      recurse = sum: path: val:
        builtins.foldl'
        (sum: key: op sum (path ++ [key]) val.${key})
        sum
        (builtins.attrNames val);
    in
      recurse {} [] tree;

  /*
    from divnix/digga, under the MIT license
  *
  Synopsis: rakeLeaves _path_

  Recursively collect the nix files of _path_ into attrs.

  Output Format:
  An attribute set where all `.nix` files and directories with `default.nix` in them
  are mapped to keys that are either the file with .nix stripped or the folder name.
  All other directories are recursed further into nested attribute sets with the same format.

  Example file structure:
  ```
  ./core/default.nix
  ./core/not_default.nix
  ./base.nix
  ./main/dev.nix
  ./main/os/default.nix
  ```

  Example output:
  ```
  {
  core = ./core;
  base = base.nix;
  main = {
  dev = ./main/dev.nix;
  os = ./main/os;
  };
  }
  ```
  *
  */
  rakeLeaves = rakeLeavesF import;
  rakeLeavesF = f: dirPath: let
    seive = file: type:
    # Only rake `.nix` files or directories
      (type == "regular" && hasSuffix ".nix" file) || (type == "directory");

    collect = file: type: {
      name = removeSuffix ".nix" file;
      value = let
        path = dirPath + "/${file}";
      in
        if
          (type == "regular")
          || (type == "directory" && builtins.pathExists (path + "/default.nix"))
        then f path
        # recurse on directories that don't contain a `default.nix`
        else rakeLeavesF f path;
    };

    files = filterAttrs seive (builtins.readDir dirPath);
  in
    filterAttrs (_n: v: v != {}) (mapAttrs' collect files);

  mkSystem = throw "TODO";

  makeProfiles = profileDir: let
    f = path: let
      profile = import path;
    in
      if builtins.isFunction profile
      then profile
      else (_: profile);
  in
    rakeLeavesF f profileDir;

  removeUnwanted = listOfUnwanted: A: (filterAttrsRecursive
    (name: _value: all (item: name != item) listOfUnwanted)
    A);

  keepWanted = listOfWanted: A:
    filterAttrs (name: _value: builtins.elem name listOfWanted) A;
in {
  inherit rakeLeaves rakeLeavesF makeProfiles flattenTree mkSystem removeUnwanted keepWanted;
}
