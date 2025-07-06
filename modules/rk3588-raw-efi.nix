{
  lib,
  pkgs,
  config,
  ...
}:
{
  formatAttr = "rk3588-raw-efi";
  fileExtension = ".img";

  boot = {
    initrd.availableKernelModules = [ "ext4" ];
    supportedFilesystems = [ "ext4" ];
    loader = {
      systemd-boot.enable = lib.mkForce true;
      efi.canTouchEfiVariables = lib.mkForce true;
      grub.enable = lib.mkForce false;
      grub.device = "nodev";
    };
  };

  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };

  system.build.rk3588-raw-efi = lib.mkForce (
    import "${toString pkgs.path}/nixos/lib/make-disk-image.nix" {
      inherit lib config pkgs;
      diskSize = 16384; # 16GB
      format = "raw";
      partitionTableType = "efi";
      installBootLoader = true;
      fsType = "ext4";
    }
  );
}
