{
  fetchFromGitHub,
  rsync,
  autoconf,
}: let
  rev = "ed6c77370ebd6e2bbd986606757146941ada6857";
in
  rsync.overrideAttrs (finalAttrs: prevAttrs: {
    pname = prevAttrs.pname + "-bpc";
    date = "2023-11-27";
    version = "3.1.3.0";

    src = fetchFromGitHub {
      owner = "backuppc";
      repo = "rsync-bpc";
      inherit rev;
      fetchSubmodules = false;
      sha256 = "sha256-mSYaE5ldYw6Ckv+/ABEGzhuhxK+WM7BHc7hOWGfdNJc=";
    };

    # FIXME: Python commonmark dependency not being found. Give up on docs
    configureFlags =
      prevAttrs.configureFlags
      ++ [
        "--disable-md2man"
      ];

    buildInputs =
      prevAttrs.buildInputs
      ++ [
        autoconf
      ];
  })
