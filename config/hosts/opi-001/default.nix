{
  hostname,
  ...
}:
{
  # =========================================================================
  #      OPI-001 Specific Configuration
  # =========================================================================

  imports = [
    # Import hardware configuration.
    ./hardware-configuration.nix

    # Import standard-operating-environment.
    ../../soe
  ];

  # Host-specific networking configuration
  networking = {
    hostName = hostname;
    hostId = "def90001";
  };
}
