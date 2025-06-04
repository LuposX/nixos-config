{pkgs, ...}: let
  # This is a Script that allows in Kitty to preview Images using fzf
  fzfImagePreviewScript = pkgs.writeShellScript "fzf-preview.sh" (
    builtins.readFile (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/junegunn/fzf/bfea9e53a62777a433af25552d440537297a1323/bin/fzf-preview.sh";
      sha256 = "1cvdwbwxbvjklblgx80lgkhnqyrnvh4rn0b60ig440g7qgraapaw"; # To get hash use, nix-prefetch-url.
    })
  );

  # DEPRECATED, use `fzfPreviewScript` instead.
  # previewFZF = pkgs.fetchFromGitHub {
  #   owner = "kidonng";
  #   repo = "preview.fish";
  #   rev = "ba3fbef3a9f23840b25764be2e1c82da5b205d42"; # Pin the latest known good commit
  #   sha256 = "sha256-dxG9Drbmy0M5c4lCzeJ4k7BnkrJwmpI4IpkeRP6CYFk=";
  # };

  #This is my general preview Script for fzf
  fzfPreviewScript = pkgs.writeTextFile {
    name = "preview_fzf.fish";
    text = ''
        #!/usr/bin/env fish
        function preview_fzf
          set mime_type (file --mime-type --brief "$argv")

          # For Video preview, calculate size using mpv.
          # set -l char_width 8
          # set -l char_height 16
          # set -l width (math "$FZF_PREVIEW_COLUMNS * $char_width")
          # set -l height (math "$FZF_PREVIEW_LINES * $char_height")

          if test -d $argv[1]
            ls $argv[1]
            exit
            return
          end

          switch "$mime_type"
              case "image/*"
                  ~/.config/fzf/fzf-preview.sh "$argv"
                  return
              case "video/*"
                  ffmpegthumbnailer -i "$argv" -o /tmp/fzf-preview.png -s 0 -q 5 > /dev/null 2>&1 &&
                  ~/.config/fzf/fzf-preview.sh /tmp/fzf-preview.png
                  return
                  # mpv --no-config --vo=kitty --vo-kitty-use-shm=yes --no-audio --autofit="$width"x"$height" "$argv"
              case "application/pdf" "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                  markitdown "$argv" | bat --language=markdown --style=numbers --color=always
                  return
              case "text/markdown"
                  glow "$argv"
                  return
              case "*"
                  bat --style=numbers --color=always "$argv"
                  return
          end
      end
    '';
  };

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
              --bind "ctrl-o:execute(fish -c 'smart_open_fzf {1} ')+abort"
      end
    '';
  };

  # This allows to open text files in nvim in the current window, while for GUI spawning a new window.
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
                  setsid mimeopen -n "$filepath" > /dev/null 2>&1 &
                  return
          end
      end
    '';
  };

  # We overwrite the function of fzf.fish else the terminal wont close properly after
  # having started a file in a program.
  fzfSearchDirectory = pkgs.writeTextFile {
    name = "_fzf_search_directory.fish";
    text = ''
        #!/usr/bin/env fish
        function _fzf_search_directory --description "Search the current directory. Replace the current token with the selected file paths."
          # Directly use fd binary to avoid output buffering delay caused by a fd alias, if any.
          # Debian-based distros install fd as fdfind and the fd package is something else, so
          # check for fdfind first. Fall back to "fd" for a clear error message.
          set -f fd_cmd (command -v fdfind || command -v fd  || echo "fd")
          set -f --append fd_cmd --color=always $fzf_fd_opts

          set -f fzf_arguments --multi --ansi $fzf_directory_opts
          set -f token (commandline --current-token)
          # expand any variables or leading tilde (~) in the token
          set -f expanded_token (eval echo -- $token)
          # unescape token because it's already quoted so backslashes will mess up the path
          set -f unescaped_exp_token (string unescape -- $expanded_token)

          # If the current token is a directory and has a trailing slash,
          # then use it as fd's base directory.
          if string match --quiet -- "*/" $unescaped_exp_token && test -d "$unescaped_exp_token"
              set --append fd_cmd --base-directory=$unescaped_exp_token
              # use the directory name as fzf's prompt to indicate the search is limited to that directory
              set --prepend fzf_arguments --prompt="Directory $unescaped_exp_token> " --preview="_fzf_preview_file $expanded_token{}"
              set -f file_paths_selected $unescaped_exp_token($fd_cmd 2>/dev/null | _fzf_wrapper $fzf_arguments)
          else
              set --prepend fzf_arguments --prompt="Directory> " --query="$unescaped_exp_token" --preview='_fzf_preview_file {}'
              set -f file_paths_selected ($fd_cmd 2>/dev/null | _fzf_wrapper $fzf_arguments)
          end


          if test $status -eq 0
              commandline --current-token --replace -- (string escape -- $file_paths_selected | string join ' ')
          end

          commandline --function repaint
      end
    '';
  };
in {
  home.packages = [
    pkgs.kitty
    pkgs.chafa
    pkgs.bat
    pkgs.ripgrep-all
    pkgs.perl540Packages.FileMimeInfo # This is used for fzf to open correct program
    pkgs.ffmpegthumbnailer
    pkgs.poppler-utils
    pkgs.python313Packages.markitdown
    pkgs.glow
    pkgs.p7zip
    pkgs.mpv
  ];

  home.file.".config/fzf/fzf-preview.sh" = {
    source = fzfImagePreviewScript;
    executable = true;
  };

  home.file.".config/fish/functions/ripgrep_fzf.fish" = {
    source = ripgrepFzfScript;
    executable = true;
  };

  home.file.".config/fish/functions/preview_fzf.fish" = {
    source = fzfPreviewScript;
    executable = true;
  };

  home.file.".config/fish/functions/smart_open_fzf.fish" = {
    source = smartOpenFZFScript;
    executable = true;
  };

  home.file.".config/fish/functions/_fzf_search_directory.fish" = {
    source = fzfSearchDirectory;
    executable = true;
  };

  # I think, not sure, this replaces the whole function folder, effectively overwriting all your functions.
  # If you want to use this, you should do one `home.file` statement per file you want to import.
  # home.file.".config/fish/functions" = {
  # source = "${previewFZF}/functions";
  #  recursive = true;
  #};
}
