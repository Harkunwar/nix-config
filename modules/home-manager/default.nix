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
    };
    file = {
      ".inputrc".source = ./dotfiles/inputrc;
      ".config/helix/config.toml".source = ./dotfiles/config/helix/config.toml;
    };
  };
  programs = {
    bat = {
      enable = true;
      config.theme = "TwoDark";
    };
    fzf = { 
      enable = true;
      enableZshIntegration = true;
    };
    exa.enable = true;
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
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      prezto.tmux.itermIntegration = true;
      shellAliases = { 
        ls = "ls --color=auto -F";

        cat = "bat";

        nixswitch = "darwin-rebuild switch --flake ~/src/system-config/.#";
        nixup = "pushd ~/src/system-config; nix flake update; nixswitch; popd;";  
      };
    };
    starship = { 
      enable = true;
      enableZshIntegration = true;
    };
  };
})
