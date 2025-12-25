{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "sshdo";
  version = "f15ee8ec33fcdfc2fc637de03806201741e2c78f";
  date = "2021-09-14";

  src = fetchFromGitHub {
    owner = "raforg";
    repo = "sshdo";
    rev = version;
    sha256 = "sha256-wtjXpscTlaiU8FZxlTZjPkypkn4dvhtCuycw/zQWP8o=";
  };

  patches = [
    ./test.diff
  ];
  buildInputs = with pkgs; [
    which
    python310
    coreutils
  ];
  preCheck = ''
    export BIN=$out/bin/sshdo
    find . -type f -exec sed -i "s/\.\/sshdo/\$BIN/g" {} +
  '';
  doCheck = true;

  makeFlags = [
    "DESTDIR=$out"
    "PREFIX=$out/bin"
  ];
  postPatch = ''
    substituteInPlace test_sshdo --replace /usr/bin/env ${pkgs.coreutils}/bin/env
  '';

  meta = with lib; {
    homepage = "https://raf.org/sshdo/";
    changelog = "https://github.com/raforg/sshdo/commit/f15ee8ec33fcdfc2fc637de03806201741e2c78f";
    description = "Easily configure which commands an SSH login can call.";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with lib.maintainers; [ProducerMatt];
  };
}
