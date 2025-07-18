# Harkunwar's Nix Configuration

A comprehensive Nix configuration for managing NixOS servers and macOS systems using Nix Flakes, Home Manager, and SOPS for secrets management.

## 📁 Repository Structure

```
.
├── flake.nix                 # Main flake configuration
├── hosts/                   # Host-specific configurations
│   ├── common/             # Shared configurations
│   │   ├── core/           # Core system configurations
│   │   └── optional/       # Optional modules
│   ├── dedirock-krypton-tank/  # DediRock server config
│   ├── macbook-pro-14/     # macOS configuration
│   ├── node804/            # Node804 server config
│   └── racknerd/           # Racknerd server config
├── modules/                # Custom Nix modules
│   ├── darwin/            # macOS-specific modules
│   └── home-manager/      # Home Manager configurations
├── secrets/               # SOPS encrypted secrets
└── users/                 # User-specific configurations
```

## 🚀 Features

- **Multi-platform support**: NixOS servers and macOS systems
- **Declarative configuration**: Everything configured as code
- **Secrets management**: SOPS with age encryption
- **Disk management**: Automated partitioning with Disko
- **Remote deployment**: Easy deployment with nixos-anywhere
- **Home Manager**: User environment management
- **Modular design**: Reusable components across hosts

## 📋 Prerequisites

- [Nix](https://nixos.org/download) installed with flakes enabled
- SSH access to target hosts
- Age key for SOPS (if managing secrets)

### Enable Nix Flakes

Add to `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

## 🔧 Quick Start

### Clone the repository
```bash
git clone https://github.com/Harkunwar/nix-config.git
cd nix-config
```

### Local Development
```bash
# Build a specific host configuration
nix build .#nixosConfigurations.node804.config.system.build.toplevel

# Test configuration changes
nixos-rebuild dry-build --flake .#node804
```

## 🌐 Remote Deployment with nixos-anywhere

### Installing NixOS on a Remote System

For a fresh installation on a remote system:

```bash
# Install NixOS on DediRock Stash
nix run github:nix-community/nixos-anywhere -- --flake .#dedirock-krypton-tank --target-host root@dedirock-krypton-tank.clivin.com

# Install NixOS on Node804
nix run github:nix-community/nixos-anywhere -- --flake .#node804 --target-host root@node804.example.com

# Install NixOS on Racknerd
nix run github:nix-community/nixos-anywhere -- --flake .#racknerd --target-host root@racknerd.example.com
```

### Building and Updating Existing Systems

For updating an already configured system:

```bash
# Build and deploy to DediRock Krypton Tank (as user)
nix run github:nix-community/nixos-anywhere -- --flake .#dedirock-krypton-tank --target-host harkunwar@dedirock-krypton-tank.clivin.com

# Build and deploy to Node804 (as user)
nix run github:nix-community/nixos-anywhere -- --flake .#node804 --target-host harkunwar@node804.example.com

# Build and deploy to Racknerd (as user)
nix run github:nix-community/nixos-anywhere -- --flake .#racknerd --target-host harkunwar@racknerd.example.com
```

### Additional nixos-anywhere Options

```bash
# Dry run (don't actually deploy)
nix run github:nix-community/nixos-anywhere -- --flake .#hostname --target-host user@host --dry-run

# Use specific SSH key
nix run github:nix-community/nixos-anywhere -- --flake .#hostname --target-host user@host --ssh-key ~/.ssh/id_ed25519

# Skip disk formatting (for updates)
nix run github:nix-community/nixos-anywhere -- --flake .#hostname --target-host user@host --no-reboot
```

## 🔐 Secrets Management with SOPS and Age

This configuration uses [SOPS](https://github.com/mozilla/sops) with [age](https://age-encryption.org/) for managing secrets.

### Setting up Age Keys

1. **Generate an age key**:
```bash
# Install age
nix shell nixpkgs#age

# Generate a new age key
age-keygen -o ~/.config/sops/age/keys.txt
```

2. **Get the public key**:
```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

3. **Add the public key to `.sops.yaml`** (create if it doesn't exist):
```yaml
keys:
  - &harkunwar age1234567890abcdef... # Your age public key
creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
    - age:
      - *harkunwar
```

### Managing Secrets

#### Creating/Editing Secrets

```bash
# Edit an existing secret file
sops secrets/wireguard.yaml

# Create a new secret file
sops secrets/new-secret.yaml
```

#### Example Secret Structure

```yaml
# secrets/wireguard.yaml
server:
  private_key: "supersecretkey123"
  port: 51820
clients:
  client1:
    private_key: "anothersecretkey456"
    public_key: "publickey789"
```

#### Using Secrets in Configuration

```nix
# In your NixOS configuration
{ config, ... }:
{
  sops.secrets.wireguard-private-key = {
    sopsFile = ../secrets/wireguard.yaml;
    path = "/etc/wireguard/private.key";
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # Reference the secret
  services.wireguard.interfaces.wg0 = {
    privateKeyFile = config.sops.secrets.wireguard-private-key.path;
  };
}
```

### SOPS Commands Reference

```bash
# Encrypt a file
sops -e file.yaml > file.enc.yaml

# Decrypt a file
sops -d file.enc.yaml

# Re-encrypt all files (after adding new keys)
find secrets/ -name "*.yaml" -exec sops updatekeys {} \;

# Rotate keys
sops -r secrets/secret.yaml
```

## 🖥️ macOS Configuration

For macOS systems using nix-darwin:

```bash
# Build Darwin configuration
nix build .#darwinConfigurations.macbook-pro-14.system

# Apply Darwin configuration
./result/sw/bin/darwin-rebuild switch --flake .#macbook-pro-14
```

## 🏠 Home Manager

User-specific configurations are managed with Home Manager:

```bash
# Build home configuration
nix build .#homeConfigurations.harkunwar.activationPackage

# Apply home configuration
./result/activate
```

## 🔧 Maintenance Scripts

The repository includes several maintenance scripts:

- `build.sh` - Build configurations
- `switch.sh` - Apply configurations
- `update.sh` - Update flake inputs
- `garbage.sh` - Clean up old generations

## 📚 Useful Resources

### Nix Documentation
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)

### Tools Used
- [Home Manager](https://github.com/nix-community/home-manager) - User environment management
- [nix-darwin](https://github.com/LnL7/nix-darwin) - macOS system configuration
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) - Remote NixOS deployment
- [Disko](https://github.com/nix-community/disko) - Declarative disk partitioning
- [SOPS](https://github.com/mozilla/sops) - Secrets management
- [sops-nix](https://github.com/Mic92/sops-nix) - SOPS integration for Nix

### Learning Resources
- [Zero to Nix](https://zero-to-nix.com/) - Beginner-friendly introduction
- [Nix.dev](https://nix.dev/) - Practical Nix tutorials
- [Awesome Nix](https://github.com/nix-community/awesome-nix) - Curated list of Nix resources

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test configurations locally
5. Submit a pull request

## 📄 License

This configuration is available under the MIT License. See [LICENSE](LICENSE) for details.

---

*This configuration is continuously evolving. Check the commit history for recent changes and improvements.*