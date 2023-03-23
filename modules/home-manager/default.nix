({ pkgs, ... }: {
  # Specify my home-manager configs
  # Guide: https://nix-community.github.io/home-manager/options.html
  home.stateVersion = "22.11"; # Don't change this, leave it alone
  home.packages = with pkgs; [ ripgrep fd curl less ];
  home.sessionVariables = {
    PAGER = "less";
    CLICOLOR = 1;
    EDITOR = "hx";
  };
  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.exa.enable = true;
  programs.git = {
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
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableSyntaxHighlighting = true;
  programs.zsh.prezto.tmux.itermIntegration = true;
  programs.zsh.shellAliases = { 
    ls = "ls --color=auto -F";

    nixswitch = "darwin-rebuild switch --flake ~/src/system-config/.#";
    nixup = "pushd ~/src/system-config; nix flake update; nixswitch; popd;";  
  };
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  home.file.".inputrc".source = ./dotfiles/inputrc;
  home.file.".config/helix/config.toml".source = ./dotfiles/config/helix/config.toml;
})
