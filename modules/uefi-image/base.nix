{
  lib,
  ...
}:
{
  # Basic UEFI boot configuration
  boot = {
    supportedFilesystems = [
      "btrfs"
      "cifs"
      "ext4"
      "f2fs"
      "nfs"
      "ntfs"
      "vfat"
      "xfs"
    ];

    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "phy_rockchip_naneng_combphy"
        "sd_mod"
        "uas"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
    };

    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
      grub.enable = lib.mkDefault false;
      grub.device = "nodev";
    };
  };

  # Hardware configuration
  hardware = {
    graphics = {
      enable = true;
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
