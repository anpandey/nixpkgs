{ lib, buildGoModule, fetchFromSourcehut, }:

buildGoModule rec {
  pname = "dotool";
  version = "1.2";
  vendorSha256 = "sha256-v0uoG9mNaemzhQAiG85RequGjkSllPd4UK2SrLjfm7A=";

  src = fetchFromSourcehut {
    owner = "~geb";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-HWJo9cYOkAXZtqrAUKM4o9Ix46KH9HCbB4eiWnky1x4=";
  };

  postInstall = ''
    install -m 644 -D 80-dotool.rules $out/rules/80-dotool.rules
  '';

}
