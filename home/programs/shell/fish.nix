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
 
      # General
      c = "clear";
      cat = "bat";
    };
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
