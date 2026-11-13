# Java toolchain for standalone / SAT4J projects.
#
# JDK (OpenJDK) for javac/java on the command line, plus Maven and Gradle
# so SAT4J can be declared as a build dependency in pom.xml / build.gradle
# and pulled from Maven Central (org.ow2.sat4j:sat4j-core).
#
# The toolchain jars come from `pkgsStable` (the `nixos-26.05` input) —
# slow-moving dev tooling, same reasoning as the texlive / libreoffice split
# in home.nix. The nvf LSP itself bundles its own JDK separately.
#
# `pkgs.sat4j-core` is a fetched jar for the no-build-tool workflow: for a
# small project you can compile and run directly against it, e.g.
#   javac -cp "$(sat4j-classpath)" *.java
#   java  -cp "$(sat4j-classpath):." Main
#
# `sat4j-classpath` prints the jar path so you never have to fish the store
# path out of .nix-profile by hand.
{
  pkgs,
  pkgsStable,
  lib,
  ...
}: let
  jdk = pkgsStable.jdk; # OpenJDK 21 — javac, java, jshell
  maven = pkgsStable.maven;
  gradle = pkgsStable.gradle;
  # Standalone SAT4J core jar (2.3.6, the latest release on Maven Central).
  # Updated 2020 — SAT4J has not shipped a newer core since. No nixpkgs
  # package exists for it, so it is fetched directly.
  sat4j-core = pkgs.stdenv.mkDerivation {
    pname = "sat4j-core";
    version = "2.3.6";

    src = pkgs.fetchurl {
      url = "https://repo.maven.apache.org/maven2/org/ow2/sat4j/org.ow2.sat4j.core/2.3.6/org.ow2.sat4j.core-2.3.6.jar";
      sha256 = "sha256-Dnqs3Zdt2VgpHmpVmb2uDUAkb+Ene3tjqA2w/JLUadc=";
    };

    # The fetched artifact is already the finished jar; nothing to unpack or
    # build. installPhase just drops it under $out/lib/ and adds a tiny
    # helper that prints the jar path.
    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib" "$out/bin"
      cp "$src" "$out/lib/sat4j-core.jar"
      printf '%s\n' '#!/bin/sh' 'echo "$out/lib/sat4j-core.jar"' \
        > "$out/bin/sat4j-classpath"
      chmod +x "$out/bin/sat4j-classpath"
      runHook postInstall
    '';

    meta = {
      description = "SAT4J core library jar (SAT / SMT solver for Java)";
      homepage = "https://www.sat4j.org/";
      license = lib.licenses.epl10;
      platforms = lib.platforms.all;
    };
  };
in {
  home.packages = [
    jdk # javac, java, jshell on the command line

    # Build tools. Either one fetches SAT4J from Maven Central as a
    # declared dependency; both are wired into nvf (Maven/Gradle commands).
    maven
    gradle

    sat4j-core
  ];
}
