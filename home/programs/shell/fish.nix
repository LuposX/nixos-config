# Fish is a Bash Replacement
{ pkgs, ... }: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # disable fish greeting
      set fish_greeting
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

      # NixOS related
      rb = "sudo nixos-rebuild switch --flake ."; # Stands for rebuild
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
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
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
