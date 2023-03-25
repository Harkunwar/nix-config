({ pkgs, ... }: {
  # Here goes the darwin preferences and configurations
  # Guide: https://daiderd.com/nix-darwin/manual/index.html
  programs.zsh.enable = true; # Don't remove this otherwise it will break things
  environment.shells = [ pkgs.bash pkgs.zsh ];
  environment.loginShell = pkgs.zsh;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  environment.systemPackages = [
    pkgs.coreutils

    # Node JS setup
    pkgs.nodejs
    pkgs.yarn
    pkgs.nodePackages.pnpm

    # Tools
    pkgs.iterm2
    pkgs.helix

    # LSPs
    pkgs.nodePackages.typescript-language-server
    pkgs.nodePackages.vscode-langservers-extracted # HTML, CSS, JSON
    pkgs.nodePackages.bash-language-server
    pkgs.marksman # Markdown
    pkgs.nil
    pkgs.nixpkgs-fmt
  ];
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.pathsToLink = [ "/Applications" ];
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  fonts.fontDir.enable = true;
  fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "Meslo" "FiraCode" ]; }) ];
  services.nix-daemon.enable = true;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.dock.autohide = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 14;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
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
