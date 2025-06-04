{pkgs, ...}: let
  # This is a Script that allows in Kitty to preview Images using fzf
  fzfPreviewScript = pkgs.writeShellScript "fzf-preview.sh" (
    builtins.readFile (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/fzf/bfea9e53a62777a433af25552d440537297a1323/bin/fzf-preview.sh";
      sha256 = "1cvdwbwxbvjklblgx80lgkhnqyrnvh4rn0b60ig440g7qgraapaw"; # To get hash use, nix-prefetch-url.
    })
  );

  # This integrates ripgrep-all +FZF, to search for content in files.
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
  # This allows to open text files in nvim in the current window, whiel for GUI spawning a new window.
  smartOpenFZFScript = pkgs.writeTextFile {
    name = "smart_open_fzf.fish";
    text = ''
        #!/usr/bin/env fish
        function smart_open_fzf
          # Arg 1 is the full path of the file that fzf returned
          set -l filepath $argv

          # 1) Figure out the MIME type of the file:
          #    xdg-mime query filetype prints something like "text/plain" or "application/pdf"
          set -l mime_type (xdg-mime query filetype "$filepath")

          # 2) Find the default .desktop file associated with that MIME type:
          #    e.g. for "text/plain" you might get "gvim.desktop" or "org.gnome.gedit.desktop"
          set -l desktop_file (xdg-mime query default "$mime_type")

          # 3) Decide if this .desktop entry corresponds to a terminal‐based editor.
          #    We’ll check common patterns like “vim.desktop” or “nvim.desktop”.
          #    If you use other terminal editors, add their desktop filenames here.
          switch $desktop_file
              case '*vim.desktop*' '*nvim.desktop*'
                  vim "$filepath"
                  return
              case '*'
                  # Otherwise, launch the GUI/default program in a new window/tab and detach.
                  # mimeopen -n will open in the associated app (e.g. evince, gnome-text-editor, etc.)
                  # “> /dev/null 2>&1 & disown” makes it asynchronous.
                  mimeopen -n "$filepath" > /dev/null 2>&1 & disown
                  return
          end
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

  home.file.".config/fish/functions/smart_open_fzf.fish" = {
    source = smartOpenFZFScript;
    executable = true;
  };
}
