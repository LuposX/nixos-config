# Fish is a Bash Replacement
{
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
 
      # General
      c = "clear";
      cat = "bat";
    };
  };
}
