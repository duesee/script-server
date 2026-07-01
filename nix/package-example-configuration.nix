{
  pkgs,
  lib,
}:
pkgs.stdenv.mkDerivation {
  pname = "script-server-example-configuration";
  version = "1.0.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = ./example-configuration;
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mv example-configuration "$out"

    # Script-server requires these folders.
    mkdir $out/{deleted,runners,schedules}
  '';

  meta = with pkgs.lib; {
    description = "Script-server example configuration";
    platforms = platforms.all;
  };
}
