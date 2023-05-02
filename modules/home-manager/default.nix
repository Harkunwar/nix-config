({ pkgs, ... }: {
  # Specify my home-manager configs
  # Guide: https://nix-community.github.io/home-manager/options.html
  home = {
    stateVersion = "22.11"; # Don't change this, leave it alone
    packages = with pkgs; [ ripgrep fd curl less ];
    sessionVariables = {
      PAGER = "less";
      CLICOLOR = 1;
      EDITOR = "hx";
      DIRENV_LOG_FORMAT = "";
    };
    file = {
      ".inputrc".source = ./dotfiles/inputrc;

      # Helix Config
      ".config/helix/config.toml".source = ./dotfiles/config/helix/config.toml;
      ".config/helix/languages.toml".source = ./dotfiles/config/helix/languages.toml;
    };
  };
  programs = {
    bat = {
      enable = true;
      config.theme = "TwoDark";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    exa.enable = true;
    htop = {
      enable = true;
    };
    git = {
      enable = true;
      userName = "Harkunwar Kochar";
      userEmail = "10580591+Harkunwar@users.noreply.github.com";
      delta.enable = true;
      aliases = {
        ph = "push origin head";
        au = "add -u";
        cm = "commit -m";
      };
    };
    gh = {
      enable = true;
    };
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix                              # Nix
        esbenp.prettier-vscode                    # Prettier
        vscode-icons-team.vscode-icons            # VSCode Icons
      ];
    };
    zellij = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      prezto.tmux.itermIntegration = true;
      initExtra = ''
        # Mac OS Upgrades break Nix, this will prevent that.
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; 
        then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';
      shellAliases = {
        ls = "ls --color=auto -F";

        cat = "bat";

        nixswitch = "pushd ~/src/system-config; ./switch.sh; popd;";
        nixbuild = "pushd ~/src/system-config; ./build.sh; ./switch.sh; popd;";
        nixupdate = "pushd ~/src/system-config; ./update.sh; ./switch.sh; popd;";
        nixgarbage = "pushd ~/src/system-config; ./garbage.sh; popd;";
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
  };
})
