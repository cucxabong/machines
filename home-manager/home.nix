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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;[
    ripgrep
    tmux
    jq
    yq
    gh
    granted-with-fish
    nixpkgs-fmt
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/quan.hoang/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "code -w";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.vscode = {
    enable = true;
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
