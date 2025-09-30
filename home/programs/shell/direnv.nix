# direnv is an extension for your shell. It augments existing shells with a new feature that can load and unload environment variables depending on the current directory.
#
# TLDR: Automatically activates development shell when enterign a directory
{
  programs = {
    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
