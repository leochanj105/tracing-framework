{ pkgs ? import <nixpkgs> {} }:

let
  protobuf_2_5_0 = pkgs.stdenv.mkDerivation {
    pname = "protobuf";
    version = "2.5.0";
    src = builtins.fetchTarball {
      url = "https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.bz2";
      sha256 = "sha256:0p85zh97f35p700v7p7iyfik84cy1p97qkwgy0f566irqiwmb872";
    };

    nativeBuildInputs = with pkgs; [
      gnumake
      autoconf
      curl
      bzip2
      automake
      libtool
    ];

    configurePhase = ''
      ./configure --prefix=$out
    '';

    buildPhase = ''
      make -j
      make check
    '';

    installPhase = ''
      mkdir -p $out
      make install
    '';
  };
in
pkgs.maven.buildMavenPackage {
  pname = "tracing-framework";
  version = "0.0.1";

  src = ./.;

  mvnHash = "sha256-PDEZGUFVsZfh1y9U8J7vIvy+3WmYvLteugFw1byrWS4=";

  mvnParameters = pkgs.lib.escapeShellArgs [
    "clean"
    "install"
    "-U"
    "-DskipTests"
  ];

  nativeBuildInputs = with pkgs; [
    protobuf_2_5_0
    jdk8
    aspectj
  ];

  mvnJdk = pkgs.jdk8;

  postInstall = ''
    mv dist $out
  '';
}
