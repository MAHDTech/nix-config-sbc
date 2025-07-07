{
  lib,
  pkgs,
  globalStateVersion,
  ...
}:
{

  system.stateVersion = globalStateVersion;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    git

    btop
    htop
    lm_sensors # `sensors`
    neofetch

    # Peripherals
    i2c-tools
    minicom
    mtdutils
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      X11Forwarding = lib.mkDefault true;
      PasswordAuthentication = lib.mkDefault true;
    };
    openFirewall = lib.mkDefault true;
  };
}
