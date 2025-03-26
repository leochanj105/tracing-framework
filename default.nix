{ pkgs ? import <nixpkgs> {}
}:

let
  inherit (pkgs)
    stdenv
    fetchFromGitHub
    callPackage
    lib
    jdk8
    maven
    aspectj;

  cherrypiejamNurPackages = callPackage (fetchFromGitHub {
    owner = "cherrypiejam";
    repo = "nur-packages";
    rev = "81742efc8375ffe23f854f0ec938f5bb736483fb";
    hash = "sha256-SfLMDb8+mv9eeXhESPITAsWzl3aTo4Q3ldijrUah0+4=";
  }) { };
in
maven.buildMavenPackage {
  pname = "tracing-framework";
  version = "0.0.1";

  src = ./.;

  mvnHash = "sha256-PDEZGUFVsZfh1y9U8J7vIvy+3WmYvLteugFw1byrWS4=";

  mvnParameters = lib.escapeShellArgs [
    "clean"
    "install"
    "-U"
    "-DskipTests"
  ];

  nativeBuildInputs = [
    cherrypiejamNurPackages.protobuf_2_5_0
    jdk8
    aspectj
  ];

  mvnJdk = jdk8;

  postInstall = ''
    mv dist $out
  '';
}
