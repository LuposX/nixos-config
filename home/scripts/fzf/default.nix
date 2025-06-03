# This is a Script that allows in Kitty to preview Images using fzf
{pkgs, ...}: let
  fzfPreviewScript = pkgs.writeShellScript "fzf-preview.sh" (
    builtins.readFile (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/fzf/bfea9e53a62777a433af25552d440537297a1323/bin/fzf-preview.sh";
      sha256 = "1cvdwbwxbvjklblgx80lgkhnqyrnvh4rn0b60ig440g7qgraapaw"; # To get hash use, nix-prefetch-url.
    })
  );
  ripgrepFzfScript = pkgs.writeTextFile {
    name = "ripgrep_fzf.fish";
    text = ''
      #!/usr/bin/env fish
      function ripgrep_fzf
          set -l RG_PREFIX "rga --column --line-number --no-heading --color=always --smart-case"
          set -l INITIAL_QUERY $argv

          fzf --ansi --disabled --query="$INITIAL_QUERY" \
              --bind "start:reload:$RG_PREFIX {q}" \
              --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
              --bind "alt-enter:unbind(change,alt-enter)+change-prompt(2. fzf> )+enable-search+clear-query" \
              --color "hl:-1:underline,hl+:-1:underline:reverse" \
              --prompt '1. ripgrep> ' \
              --delimiter : \
              --preview 'bat --color=always {1} --highlight-line {2}' \
              --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
              --bind 'enter:become(vim {1} +{2})'
      end
    '';
  };
in {
  home.packages = [
    pkgs.kitty
    pkgs.chafa
    pkgs.bat
    pkgs.ripgrep-all
  ];

  home.file.".config/fzf/fzf-preview.sh" = {
    source = fzfPreviewScript;
    executable = true;
  };

  home.file.".config/fish/functions/ripgrep_fzf.fish" = {
    source = ripgrepFzfScript;
    executable = true;
  };
}
