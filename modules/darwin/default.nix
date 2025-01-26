({ pkgs, ... }: {
  # Here goes the darwin preferences and configurations
  # Guide: https://daiderd.com/nix-darwin/manual/index.html
  programs.zsh.enable = true; # Don't remove this otherwise it will break things
  environment.shells = [ pkgs.bash pkgs.zsh ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  environment.systemPackages = with pkgs; [
    # Dev Tools
    coreutils

    # JS tools
    bun
    nodejs_23
    yarn
    nodePackages.pnpm

    # Tools
    iterm2
    helix

    # Browser
    # arc-browser

    # LSPs
    marksman # Markdown
    nil
    nixpkgs-fmt
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # HTML, CSS, JSON
    taplo # TOML
  ];
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.pathsToLink = [ "/Applications" ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  fonts.packages = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "Meslo" "DroidSansMono" ]; }) ];
  services.nix-daemon.enable = true;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.dock.autohide = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;

  security.pam.enableSudoTouchIdAuth = true;
  # For backwards compatibility, don't change
  system.stateVersion = 4;
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = { };
    casks = [ "amethyst" "raycast" ];
    taps = [ "fujiapple852/trippy" ];
    brews = [ "trippy" ];
  };
})
