# WARN: not tested recently
{
  rrsync,
  rsync-bpc,
}:
rrsync.overrideAttrs (finalAttrs: prevAttrs: {
  pname = prevAttrs.pname + "-bpc";

  inherit (rsync-bpc) version src;

  buildInputs =
    prevAttrs.buildInputs
    ++ [
      rsync-bpc
    ];

  postPatch = ''
    substituteInPlace support/rrsync --replace /usr/bin/rsync ${rsync-bpc}/bin/rsync
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp support/rrsync $out/bin
    chmod a+x $out/bin/rrsync
  '';

  meta =
    rsync-bpc.meta
    // {
      description = "A helper to run rsync-only environments from ssh-logins";
      mainProgram = "rrsync";
    };
})
