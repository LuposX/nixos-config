{ pkgs, ... }:
{
  # If you get error when creating new session try to delte the cahce
  # $HOME/.cache/zellij
  # See https://github.com/NixOS/nixpkgs/issues/216961
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # default_layout = "compact";
      on_force_close = "quit";
      default_layout = "welcome";
      show_startup_tips = false;
      show_release_notes = false;
      session_serialization = false;
    };
  };


home.file.".config/zellij/layouts/notes.kdl".text = ''
  layout {
    cwd "~/Notes"
    pane command="nvim"
  }
'';

home.file.".config/zellij/layouts/university.kdl".text = ''
  layout {
    cwd "~/Notes/University/Bachelor/Semester_8"
    pane command="nvim"
  }
'';

home.file.".config/zellij/layouts/website.kdl".text = ''
  layout {
    pane split_direction="vertical" {
      pane {
        command "nvim"
        cwd "~/Website_MonkeMan"
      }
      pane {
        cwd "~/Website_MonkeMan"
        size "30%"
      }
    }
  }
'';

home.file.".config/zellij/layouts/nixos_config.kdl".text = ''
  layout {
    pane split_direction="vertical" {
      pane {
        command "nvim"
        cwd "~/nixos-config"
      }
      pane {
        cwd "~/nixos-config"
        size "30%"
      }
    }
  }
'';
}
