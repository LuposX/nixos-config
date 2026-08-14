{
  pkgs,
  pkgsStable,
  ...
}: {
  fonts = {
    packages =
      (with pkgs; [
        roboto
        inter
        lato
        lexend
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.fira-code
        nerd-fonts.meslo-lg
        twemoji-color-font
      ])
      # STABLE (big / heavy / slow-moving GUI apps)
      ++ (with pkgsStable; [
        openmoji-color
      ]);

    enableDefaultPackages = false;
  };
}
