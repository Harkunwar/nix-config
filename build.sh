export HOSTNAME=$(hostname -s)
nix build .#darwinConfigurations.${HOSTNAME}.system --extra-experimental-features flakes --extra-experimental-features nix-command
