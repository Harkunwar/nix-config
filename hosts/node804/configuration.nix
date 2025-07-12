# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./services/immich.nix
      ./services/openssh.nix
    ];

  environment.systemPackages = with pkgs; [ git vim ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportAll = true;

  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

  users.groups = {
    # Storage access groups
    storage-admin = {
      gid = 3001;
      members = [ "harkunwar" ];
    };
    storage-users = {
      gid = 3002;
      members = [ "harkunwar" ]; # Add other users here later
    };
    timemachine-users = {
      gid = 3003;
      members = [ "harkunwar" ]; # Users allowed to use Time Machine
    };
    private-media-users = {
      gid = 3004;
      members = [ "immich" "harkunwar" ]; # For photos and videos
    };

    # Future groups
    backup-operators = {
      gid = 3005;
      members = [ ]; # For backup management
    };
  };


  users.users.harkunwar = {
    isNormalUser = true;
    description = "Harkunwar";
    extraGroups = [
      "wheel" # Enable 'sudo' for the user
      "storage-admin" # Joining NAS groups
      "storage-users"
      "timemachine-users"
      "networkmanager"
      "audio"
      "video"
      "docker" # If you use Docker
    ];

    # Set up SSH key for the user (same as your initrd key)
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1H9FyV6MmS/rxDMvUS5Ot/vYpXAsVxQaBEME0cgmI0 10580591+Harkunwar@users.noreply.github.com"
    ];

    # Set a password hash (see below for how to generate)
    hashedPassword = "$6$VUX42OyBWi3l7vWt$M7X2P3BvSojRMvccpK.Ye3Lw7zPTtLbtbmu9O8sVTwklQJiSe/RSK2VMXvOgt1b6jSYjrjl9g3UuHdFeFR2h70"; # Replace with actual hash
  };

  # Enable Samba services with group-based access
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      # Global settings - only truly global stuff
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Node 804 Server";
        "netbios name" = "node804-server";
        security = "user";

        # Performance optimizations (these are fine globally)
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288";
        "use sendfile" = "yes";
        "aio read size" = 16384;
        "aio write size" = 16384;

        # Logging (global is appropriate)
        "log level" = 1;
        "max log size" = 1000;
      };

      # Time Machine share - Mac-specific settings HERE
      time-machine = {
        path = "/mnt/molasses/time-machine";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0660";
        "directory mask" = "0770";
        "valid users" = "@timemachine-users";
        "write list" = "@timemachine-users";

        # Mac/Time Machine specific settings - ONLY for this share
        "fruit:time machine" = "yes";
        "fruit:time machine max size" = "1T";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
        comment = "Time Machine Backups (1TB limit)";
      };

      # Regular storage shares - no Mac-specific bloat
      espresso = {
        path = "/mnt/espresso";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "valid users" = "@storage-users @storage-admin";
        "write list" = "@storage-users @storage-admin";
        "admin users" = "@storage-admin";
        "vfs objects" = "acl_xattr"; # No fruit here
        comment = "Espresso SSD Storage (Fast Access)";
      };

      molasses = {
        path = "/mnt/molasses";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "valid users" = "@storage-users @storage-admin";
        "write list" = "@storage-users @storage-admin";
        "admin users" = "@storage-admin";
        "vfs objects" = "acl_xattr"; # No fruit here either
        comment = "Molasses HDD Storage (Bulk Storage)";
      };

      private-media = {
        path = "/mnt/molasses/private-media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0664";
        "directory mask" = "0775";
        "valid users" = "@private-media-users @storage-admin";
        "write list" = "@private-media-users @storage-admin";
        "admin users" = "@storage-admin";
        # Use acl_xattr for permissions
        "vfs objects" = "acl_xattr";
        comment = "Private Media Storage (Photos and Videos)";
      };

      # Future Mac-friendly media share example
      # media = {
      #   path = "/mnt/molasses/media";
      #   browseable = "yes";
      #   "read only" = "no";
      #   "guest ok" = "no";
      #   "create mask" = "0664";
      #   "directory mask" = "0775";
      #   "valid users" = "@media-users @storage-admin";
      #   "write list" = "@media-users @storage-admin";
      #   "admin users" = "@storage-admin";
      #   # Mac-friendly for media files
      #   "fruit:metadata" = "stream";
      #   "fruit:posix_rename" = "yes";
      #   "vfs objects" = "catia fruit streams_xattr acl_xattr";
      #   comment = "Media Library";
      # };
    };
  };

  # Avahi configuration (same as before)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    reflector = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };

    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
          <service>
            <type>_device-info._tcp</type>
            <port>0</port>
            <txt-record>model=TimeCapsule8,119</txt-record>
          </service>
          <service>
            <type>_adisk._tcp</type>
            <port>9</port>
            <txt-record>dk0=adVN=time-machine,adVF=0x82</txt-record>
            <txt-record>sys=waMa=0,adVF=0x100</txt-record>
          </service>
        </service-group>
      '';
    };
  };

  # Set proper ownership and permissions using groups
  systemd.tmpfiles.rules = [
    # Time Machine - only timemachine-users group access
    "d /mnt/molasses/time-machine 0770 root timemachine-users -"

    # Storage directories - storage groups access
    "d /mnt/espresso 0775 root storage-users -"
    "d /mnt/molasses 0775 root storage-users -"

    # Private media - private-media-users group access
    "d /mnt/molasses/private-media 0775 root private-media-users -"

    # Future directory structure examples
    # "d /mnt/molasses/media 0775 root media-users -"
    # "d /mnt/molasses/backup 0770 root backup-operators -"
  ];


  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true; # Set to false if you need passwordless sudo

  networking = {
    hostName = "node804"; # Define your hostname

    # Disable NetworkManager if you want to use static configuration
    networkmanager.enable = false;

    # Configure static IP on enp1s0 interface
    interfaces.enp1s0 = {
      ipv4.addresses = [{
        address = "192.168.2.101";
        prefixLength = 24; # This is /24 or 255.255.255.0
      }];
    };

    # Set default gateway
    defaultGateway = "192.168.2.5";

    # Set DNS servers
    nameservers = [ "192.168.2.5" ];

    # Optional: Enable firewall and open SSH port
    firewall = {
      enable = true;
      allowedTCPPorts = [
      ];
      allowedUDPPorts = [
      ];
    };
  };

  boot = {
    kernelParams = [
      # Static IP configuration for initrd
      # Format: ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns0-ip>:<dns1-ip>
      "ip=192.168.2.101::192.168.2.5:255.255.255.0:nixos:enp1s0:off:192.168.2.5"
    ];
    initrd.availableKernelModules = [
      "mlx4_core" # Core driver (what you're currently using)
      "mlx4_en" # Ethernet driver for ConnectX-3
    ];
    initrd.network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`, 
      # so your initrd can load it!
      # Static ip addresses might be configured using the ip argument in kernel command line:
      # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
      enable = true;
      udhcpc.enable = false;
      ssh = {
        enable = true;
        # To prevent ssh clients from freaking out because a different host key is used,
        # a different port for ssh is useful (assuming the same host has also a regular sshd running)
        port = 2222;
        # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
        # the keys are copied to initrd from the path specified; multiple keys can be set
        # you can generate any number of host keys using 
        # `ssh-keygen -t ed25519 -N "" -f /path/to/ssh_host_ed25519_key`
        shell = "/bin/cryptsetup-askpass";
        hostKeys = [ /root/.ssh/id_ed25519_initrd ];
        # public ssh key used for login
        authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1H9FyV6MmS/rxDMvUS5Ot/vYpXAsVxQaBEME0cgmI0 10580591+Harkunwar@users.noreply.github.com" ];
      };
    };
  };
  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

