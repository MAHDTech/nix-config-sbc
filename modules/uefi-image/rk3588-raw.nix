{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  formatAttr = "rk3588-raw-efi";
  fileExtension = ".img";

  system.build.rk3588-raw-efi = lib.mkForce (
    import "${toString pkgs.path}/nixos/lib/make-disk-image.nix" {
      inherit lib config pkgs;
      bootSize = "512M"; # 512MB
      copyChannel = false;
      deterministic = true;
      diskSize = 16384; # 16GB
      format = "raw";
      fsType = "ext4";
      installBootLoader = true;
      label = "nixos";
      partitionTableType = "efi";
    }
  );
}
