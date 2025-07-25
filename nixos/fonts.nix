{ pkgs, ... }: {

  fonts = {
    packages = with pkgs; [
      roboto
      inter
      lato
      lexend
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg
      openmoji-color
      twemoji-color-font
    ];

    enableDefaultPackages = false;
  };
}
