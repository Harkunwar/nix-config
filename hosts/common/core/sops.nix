{ inputs, config, ...}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/keys.txt";
        generateKey = true;
    };
  };

}