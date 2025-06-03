# This is a Script that allows in Kitty to preview Images using fzf
{pkgs, ...}: let
  fzfPreviewScript = pkgs.writeShellScript "fzf-preview.sh" (
    builtins.readFile (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/fzf/bfea9e53a62777a433af25552d440537297a1323/bin/fzf-preview.sh";
      sha256 = "1cvdwbwxbvjklblgx80lgkhnqyrnvh4rn0b60ig440g7qgraapaw"; # To get hash use, nix-prefetch-url.
    })
  );
in {
  home.packages = [pkgs.kitty pkgs.chafa pkgs.bat];

  home.file.".config/fzf/fzf-preview.sh" = {
    source = fzfPreviewScript;
    executable = true;
  };
}
