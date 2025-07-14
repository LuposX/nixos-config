# Fish is a Bash Replacement
{pkgs, config, ...}: let
  configDirectory = config.var.configDirectory;
  hostname = config.var.hostname;
in {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # disable fish greeting
      set fish_greeting

      # Customize “Search Directory” (fzf_directory_opts) to preview images → kitty, else bat.
      # in config.fish (or wherever you set it):
      # Deprecated
      # set -Ux fzf_preview_file_cmd preview_fzf # DEPRECATED: preview

      # set fzf_directory_opts \
      #  --bind "ctrl-o:execute(smart_open_fzf {} )+abort"

      # Press CTRL+G to activate ripgrep with fzf, to fuzzy search content within files.
      bind \cg ripgrep_fzf

      # For NN to cd on quit
      # Rename this file to match the name of the function
      # e.g. ~/.config/fish/functions/n.fish
      # or, add the lines to the 'config.fish' file.
      function n --wraps nnn --description 'support nnn quit and change directory'
        # Block nesting of nnn in subshells
        if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
            echo "nnn is already running"
            return
        end

        # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
        # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
        # see. To cd on quit only on ^G, remove the "-x" from both lines below,
        # without changing the paths.
        if test -n "$XDG_CONFIG_HOME"
            set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
        else
            set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
        end

        # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
        # stty start undef
        # stty stop undef
        # stty lwrap undef
        # stty lnext undef

        # The command function allows one to alias this function to `nnn` without
        # making an infinitely recursive alias
        command nnn $argv

        if test -e $NNN_TMPFILE
            source $NNN_TMPFILE
            rm -- $NNN_TMPFILE
        end
      end
    '';

    shellAliases = {
      # Navigation
      cd = "z";
      ls = "eza --icons=always --no-quotes";
      tree = "eza --icons=always --tree --no-quotes";

      # Git
      gc = "git commit -m";
      ga = "git add";
      gl = "git log";
      lg = "lazygit";


      # General
      c = "clear";
      cat = "bat";
      find = "fd";

      n = "nnn";

      # Editor
      v = "nvim";

      # NixOS related
      rb = "sudo nixos-rebuild switch --flake ${configDirectory}#${hostname}"; # Stands for rebuild
      rbr = "sudo nix build .#nixosConfigurations.prohairesis.config.system.build.toplevel; sleep 1; sudo nixos-rebuild switch --flake .#prohairesis --target-host monkeman@192.168.12.100 --sudo --ask-sudo-password"; # If I only do the latetr command, I get a sandbox error.
    };

    plugins = [
      # Automatically receive notifications when long processes finish.
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      # Fuzzy Finder, efficiently find what you need using.
      # Keybindings:
      # - Search File: Ctrl+Alt+F
      # - Search Command History: Ctrl+R
      # - Search Variables: Ctrl+v
      # - Search Processes: Ctrl+P
      # - Search Git Log: Ctrl+Alt+L
      # - Search Git Status: Ctrl+Alt+S
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      # Automatically insert, erase, and skip matching pairs as you type in the command-line.
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      # Keeps shell history clean from typos and incorrectly used commands.
      # {
      #   name = "sponge";
      #   src = pkgs.fishPlugins.sponge.src;
      # }
      # Typing consecutive dots after .. will automatically expand to ../.., then ../../.. and so on.
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      # Color-enabled man plugin for fish-shell..
      {
        name = "colored man";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
    ];
  };

  # Sets fish as your shell
  # Write a .bashrc that drops into fish (only if bash starts interactively, For more see: https://nixos.wiki/wiki/Fish)
  home.file.".bashrc".text = ''
    # Automatically launch fish from bash (unless already in fish)
    if [[ $- == *i* ]] && [[ -z "$BASH_EXECUTION_STRING" ]] && [[ "$(basename -- "$SHELL")" != "fish" ]]; then
      exec fish
    fi
  '';
}
