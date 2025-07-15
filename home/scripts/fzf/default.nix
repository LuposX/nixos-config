{pkgs, ...}: let
  # So I can execute it from hyprland directly
  fzf_search_files = pkgs.writeTextFile {
    name = "fzf_search_files.fish";
    text = ''
        #!/usr/bin/env fish
        function fzf_search_files
            set -f fd_cmd (command -v fdfind || command -v fd || echo "fd")
            set -f --append fd_cmd --color=always --exclude Games $fzf_fd_opts
            # Alternatively, use --exclude ~/Games for explicit home directory reference

            set -f fzf_arguments --multi --ansi $fzf_directory_opts
            set -f token (commandline --current-token)
            set -f expanded_token (eval echo -- $token)
            set -f unescaped_exp_token (string unescape -- $expanded_token)

            if string match --quiet -- "*/" $unescaped_exp_token && test -d "$unescaped_exp_token"
                set --append fd_cmd --base-directory=$unescaped_exp_token
                set --prepend fzf_arguments --prompt="Directory $unescaped_exp_token> " --preview="exa --color=always -l --icons $expanded_token{}"
                set -f file_paths_selected $unescaped_exp_token($fd_cmd 2>/dev/null | _fzf_wrapper $fzf_arguments)
            else
                set --prepend fzf_arguments --prompt="Directory> " --query="$unescaped_exp_token" --preview='exa --color=always -l --icons {}'
                set -f file_paths_selected ($fd_cmd 2>/dev/null | _fzf_wrapper $fzf_arguments)
            end

            if test $status -eq 0
                for f in $file_paths_selected
                    # Open each file with default app, detach, ignore output
                    xdg-open $f &>/dev/null & disown
                end

                # If not running from keybinding, update commandline for interactive shell
                if not set -q HYPRLAND_FZF
                    commandline --current-token --replace -- (string escape -- $file_paths_selected | string join ' ')
                    commandline --function repaint
                else
                    # When run from keybinding, wait a bit then exit so terminal closes gracefully
                    sleep 0.2
                    exit
                end
            end
        end
   '';
  };

  # To execute fzf grep directly from hyprland
  fzf_search_rga = pkgs.writeTextFile {
    name = "fzf_search_rga.fish";
    text = ''
        #!/usr/bin/env fish
        function fzf_search_rga
            if not type -q rga
                echo "ripgrep-all (rga) not found in PATH." >&2
                exit 1
            end

            # Exclude the ~/Games directory
            set -l RG_PREFIX "rga --column --line-number --no-heading --color=always --smart-case --glob '!Games/**'"
            set -l INITIAL_QUERY $argv

            set -l preview_cmd 'bat --style=plain --color=always --highlight-line {2} {1}'

            set -l result (fzf --ansi --disabled --query="$INITIAL_QUERY" \
                --bind "start:reload:$RG_PREFIX {q}" \
                --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
                --bind "ctrl-o:execute(fish -c 'smart_open_fzf {1}')+abort" \
                --delimiter : \
                --preview "$preview_cmd" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --prompt 'rga> ')

            if test -n "$result"
                set -l file (echo $result | cut -d':' -f1)
                if not set -q HYPRLAND_FZF
                    commandline --current-token --replace -- (string escape -- $file)
                    commandline --function repaint
                else
                    xdg-open $file &>/dev/null & disown
                    sleep 0.2
                    exit
                end
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

in {
  home.packages = [
    pkgs.kitty
    pkgs.bat
    pkgs.eza
    pkgs.ripgrep-all
    pkgs.perl540Packages.FileMimeInfo # This is used for fzf to open correct program
    pkgs.poppler
  ];

  home.file.".config/fish/functions/ripgrep_fzf.fish" = {
    source = ripgrepFzfScript;
    executable = true;
  };

  home.file.".config/fish/functions/fzf_search_files.fish" = {
    source = fzf_search_files;
    executable = true;
  };


  home.file.".config/fish/functions/fzf_search_rga.fish" = {
    source = fzf_search_rga;
    executable = true;
  };
}
