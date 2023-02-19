{ lib, stdenv, dotool }:

stdenv.mkDerivation {
  pname = "dotool-udev-rules";
  inherit (dotool) version;

  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    install -D -m 644 ${dotool.out}/rules/80-dotool.rules $out/lib/udev/rules.d/80-dotool.rules
  '';

  meta = {
    description = "udev rules for dotool";
    inherit (dotool.meta) license;
    maintainers = [ lib.maintainers.anpandey ];
  };
}
