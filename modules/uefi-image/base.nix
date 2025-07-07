{
  lib,
  ...
}:
{
  # Basic UEFI boot configuration
  boot = {
    initrd.availableKernelModules = [ "ext4" ];
    supportedFilesystems = [ "ext4" ];
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
      grub.device = "nodev";
    };
  };

  # Basic filesystem configuration for UEFI images
  fileSystems = lib.mkDefault {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };
}
