({ pkgs, ... }: {
  # Here goes the darwin preferences and configurations
  # Guide: https://daiderd.com/nix-darwin/manual/index.html
  programs.zsh.enable = true; # Don't remove this otherwise it will break things
  programs.zsh.shellInit = ''
    NIX_PNPM_PATH="$(which pnpm)"
    alias pnpm="node $NIX_PNPM_PATH"
  '';
  environment.shells = [ pkgs.bash pkgs.zsh ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  environment.systemPackages = with pkgs; [
    # Dev Tools
    coreutils

    # JS tools
    bun
    (yarn.override { nodejs = null; })
    nodejs_22
    (pnpm_10.override { nodejs = nodejs_22; })
    # nodePackages.pnpm

    # Tools
    helix
    p7zip
    p7zip-rar
    rclone

    # LSPs
    marksman # Markdown
    nil
    nixpkgs-fmt
    # nodePackages.bash-language-server
    # nodePackages.typescript-language-server
    # nodePackages.vscode-langservers-extracted # HTML, CSS, JSON
    taplo # TOML
  ];
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.pathsToLink = [ "/Applications" ];
  fonts.packages = with pkgs.nerd-fonts; [ fira-code fira-mono meslo-lg droid-sans-mono ];
  system = {
    # For backwards compatibility, don't change
    stateVersion = 5;
    primaryUser = "harkunwar";
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

  security.pam.services.sudo_local.touchIdAuth = true;
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = { 
      "WireGuard" = 1451685025;
      "Bitwarden" = 1137397744;
    };
    casks = [
      # AI
      "chatbox"
      "ollama"

      # Tools
      "amethyst"
      "iterm2"
      "raycast"
      "vmware-fusion"
      "bambu-studio"
      "keka"
      "obsidian"

      # Proton Apps
      "proton-drive"
      "proton-mail"

      # Entertainment
      "stremio"

      # Browser
      "zen"
      "chromium"
    ];
    taps = [ "fujiapple852/trippy" ];
    brews = [ "trippy" "nvm" ];
  };
})
