{
  ...
}:

{
  programs.ghostty = {
    enable = true;
    settings = {
      window-decoration = false;

      # Disables ligatures
      font-feature = [
        "-liga"
        "-dlig"
        "-calt"
      ];
    };
  };
}
