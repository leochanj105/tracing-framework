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

  src = lib.cleanSourceWith {
    filter = (path: _type: (builtins.baseNameOf (builtins.toString path)) != "xtrace-data");
    src = ./.;
  };

  mvnHash = "sha256-AuqoNezjLg3JCQodD6PlxMQ5F0USEtyBsTHxCJ7+ZcA=";

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
    cp -r . $out
  '';
}
