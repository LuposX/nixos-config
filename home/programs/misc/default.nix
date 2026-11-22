# Add here programs that you want to be sytlized by stylix but don't want to configure further.
# calibre comes from stable (26.05): its unstable build pulls torch with ROCm
# support, and aotriton 0.12b (torch's AMD Triton kernels) was broken in
# unstable. Stable's calibre -> piper-tts 1.4 -> torch 2.11 has no aotriton.
{
  pkgs,
  pkgsStable,
  ...
}: {
  programs.mpv.enable = true;
  programs.calibre.enable = true;
  programs.calibre.package = pkgsStable.calibre;
  programs.btop.enable = true;
  programs.anki.enable = true;

  home.packages = [
    pkgs.pferd
    # Markdown notes editor (open source), used on the Syncthing-synced
    # ~/Projects/research-notes space. Has Zotero integration.
    pkgs.zettlr
    # Renders the research-notes space as a local wiki site
    # (olivine theme): `zola serve` in ~/Projects/research-notes.
    pkgs.zola
  ];
}