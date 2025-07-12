{ config, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    ports = [ 649 ];
    settings = {
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
    };
  };

  systemd.services.opensshd.preStart = ''
    ${pkgs.openssh}/bin/ssh-keygen -A
  '';

  services.fail2ban = {
    enable = true;
  };
}
