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
  programs.git.enable = true;
  programs.git.userName = "Harkunwar Kochar";
  programs.git.userEmail = "10580591+Harkunwar@users.noreply.github.com";
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableSyntaxHighlighting = true;
  programs.zsh.shellAliases = { 
    ls = "ls --color=auto -F";


    nixswitch = "darwin-rebuild switch --flake ~/src/system-config/.#";
    nixup = "pushd ~/src/system-config; nix flake update; nixswitch; popd;";  
  };
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  home.file.".inputrc".source = ./dotfiles/inputrc;
})
