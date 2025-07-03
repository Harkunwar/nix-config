({ pkgs, ... }: {
  # Specify my home-manager configs
  # Guide: https://nix-community.github.io/home-manager/options.html
  home = {
    stateVersion = "24.11";
    packages = with pkgs; [ 
      ripgrep
      fd
      curl
      less
      gnupg
      pinentry_mac
    ];
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

      # ASCII Hello Art
      ".config/zsh/hello_ascii.txt".source = ./dotfiles/config/zsh/hello_ascii.txt;
    };
  };
  programs = {
    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
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
    eza.enable = true;
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
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519.pub";
      };
    };
    gh = {
      enable = true;
    };
    gpg = {
      enable = false;
    };
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      mutableExtensionsDir = true;
      userSettings = {
        "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";
        "workbench.colorTheme" = "Default Dark+ Experimental";
        "workbench.iconTheme" = "vscode-icons";
      };
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix # Nix
        unifiedjs.vscode-mdx # MDX
        esbenp.prettier-vscode # Prettier
        dbaeumer.vscode-eslint # ESLint
        vscode-icons-team.vscode-icons # VSCode Icons
      ];
    };
    zellij = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      prezto.tmux.itermIntegration = true;
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.8.0";
            sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
          };
        }
      ];
      initExtra = ''
        # Mac OS Upgrades break Nix, this will prevent that.
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; 
        then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi

        echo "$(cat $HOME/.config/zsh/hello_ascii.txt)"
      '';
      shellAliases = {
        ls = "ls --color=auto -F";

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
