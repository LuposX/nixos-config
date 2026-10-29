# Builds the monkeman/mirror-mirror Noctalia v5 plugin as a static plugin
# directory, suitable for a `path` plugin source (Noctalia treats those as
# immutable, which matches a read-only nix store path).
{
  stdenvNoCC,
  ffmpeg,
}:
stdenvNoCC.mkDerivation {
  name = "noctalia-plugin-mirror-mirror";
  src = ./.;

  nativeBuildInputs = [ ffmpeg ];

  buildPhase = ''
    # v5 wants a thumbnail.webp per plugin; render a simple placeholder card.
    ${ffmpeg}/bin/ffmpeg -y -hide_banner -loglevel error \
      -f lavfi -i "color=c=0x15151f:s=960x540" \
      -vf "drawbox=x=0:y=0:w=960:h=540:color=0x2a2a3d@0.35:t=fill" \
      -frames:v 1 -c:v libwebp thumbnail.webp
  '';

  # The plugin must sit in a subdirectory: a plugin source (path or git) is a
  # directory of plugins, each subdir containing its own plugin.toml.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/mirror-mirror
    cp plugin.toml main.luau panel.luau widget.luau README.md thumbnail.webp $out/mirror-mirror/
    cp -r translations $out/mirror-mirror/
    runHook postInstall
  '';
}
