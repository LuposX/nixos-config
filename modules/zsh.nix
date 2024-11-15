#
#  Shell
#

{ pkgs, vars, ... }:

{

  environment.systemPackages = with pkgs; [
    fzf
    fzf-zsh 
    fd
    zinit
    zsh-completions
    zsh-command-time
    zsh-fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
    bat # better 'cat' command
    eza # better 'ls' command
    chafa # To show images
  ];
  
  programs.starship.enable = true;
 
  programs.zsh.enable = true;

  users.users.${vars.user}.shell = pkgs.zsh;

  home-manager.users.${vars.user} = {
    home.file.".zshrc".source = ./zsh/.zshrc;
    home.file.".zsh_aliases".source = ./zsh/.zsh_aliases;

    programs.zoxide.enable = true; # Smarter 'cd' command   
    programs.starship.enable = true; # Command prompt
    #programs.starship.settings = pkgs.lib.importTOML ./zsh/starship.toml;
  };
}
