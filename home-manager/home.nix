{ config, pkgs, ... }:

let
  granted-with-fish = pkgs.granted.override {
    withFish = true;
  };
  vscode_settings = {
    files = {
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "files.trimFinalNewlines" = true;
      "files.associations" = {
        "*.hcl" = "terraform";
      };
    };
    editor = {
      "editor.formatOnSave" = false;
      "editor.minimap.enabled" = false;
      "editor.tabSize" = 2;
      "editor.formatOnSaveMode" = "file";
    };
    nix = {
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.formatOnSave" = true;
      };
    };
    terraform = {
      "[terraform]" = {
        "editor.defaultFormatter" = "hashicorp.terraform";
        "editor.formatOnSave" = true;
      };
    };
  };
in
{
  home.username = "quan.hoang";
  home.homeDirectory = "/Users/quan.hoang";
  home.stateVersion = "24.05"; # Please read the comment before changing.
  home.packages = with pkgs; [
    ripgrep
    tmux
    jq
    yq
    gh
    granted-with-fish
    nixpkgs-fmt
    devenv
    stern
    terraform
    kubie
  ];

  home.file = { };

  home.sessionVariables = {
    EDITOR = "code -w";
  };

  programs.home-manager.enable = true;

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions =
      with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        hashicorp.terraform
        github.copilot
        github.copilot-chat
        github.vscode-github-actions
      ];

    userSettings = vscode_settings.editor // vscode_settings.nix // vscode_settings.files // vscode_settings.terraform;
  };

  programs.direnv.enable = false;

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub
          {
            owner = "oh-my-fish";
            repo = "plugin-foreign-env";
            rev = "7f0cf099ae1e1e4ab38f46350ed6757d54471de7";
            hash = "sha256-4+k5rSoxkTtYFh/lEjhRkVYa2S4KEzJ/IJbyJl+rJjQ=";
          };
      }
    ];
    shellInit = ''
      # nix
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fenv source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      end

      alias assume="source ${granted-with-fish}/share/assume.fish"
    '';
  };

  programs.fzf = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = false;
    settings = {
      gcloud = {
        disabled = true;
      };
      kubernetes = {
        disabled = false;
      };
      dotnet = {
        disabled = true;
      };
      cmd_duration = {
        disabled = false;
        format = " 🕙 $duration($style) ";
        style = "bold italic #87A752";
        show_milliseconds = false;
        min_time = 4;
      };
    };
  };
}
