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
    helix

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
  fonts.packages = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "Meslo" "DroidSansMono" ]; }) ];
  services.nix-daemon.enable = true;
  system = {
    # For backwards compatibility, don't change
    stateVersion = 4;
    defaults = {
      controlcenter.Bluetooth = true;
      dock.autohide = true;
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 1;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  security.pam.enableSudoTouchIdAuth = true;
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = { };
    casks = [ 
      # AI
      "chatbox"
      "ollama"

      # Tools
      "amethyst"
      "iterm2"
      "raycast"
      "vmware-fusion"

      # Proton Apps
      "proton-drive"
      "proton-mail"

      # Entertainment
      "stremio"

      # Browser
      "zen-browser"
    ];
    taps = [ "fujiapple852/trippy" ];
    brews = [ "trippy" ];
  };
})
