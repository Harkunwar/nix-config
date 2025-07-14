{ pkgs, config, ... }:

{
  users.users.harkunwar = {
    isNormalUser = true;
    description = "Harkunwar";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1H9FyV6MmS/rxDMvUS5Ot/vYpXAsVxQaBEME0cgmI0 10580591+Harkunwar@users.noreply.github.com"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "harkunwar" ];
      commands = [
        {
          command = "ALL";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ];
}
