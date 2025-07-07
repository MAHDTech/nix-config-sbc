{
  lib,
  config,
  modulesPath,
  ...
}:
let
  uuid = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
in
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot = {
    kernelParams = [
      "root=UUID=${uuid}"
      "rootfstype=ext4"
    ];

    loader = {
      grub.enable = lib.mkForce false;
      grub.device = "nodev";
      generic-extlinux-compatible.enable = lib.mkForce true;
    };
  };

  sdImage = {
    rootPartitionUUID = uuid;
    compressImage = true;

    # Set the firmware partition name to match hardware-configuration.nix
    firmwarePartitionName = "ESP";

    # install firmware into a separate partition: /boot/firmware
    populateFirmwareCommands = ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    # Gap in front of the /boot/firmware partition, in mebibytes (1024×1024 bytes).
    # Can be increased to make more space for boards requiring to dd u-boot SPL before actual partitions.
    firmwarePartitionOffset = 32;
    firmwareSize = 200; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
      mkdir -p ./files/boot/firmware
    '';
  };

  # Override the rootfs image to use custom volume label
  system.build.rootfsImage = lib.mkForce (
    config.pkgs.callPackage "${config.pkgs.path}/nixos/lib/make-ext4-fs.nix" {
      inherit (config.sdImage) storePaths;
      inherit uuid;
      inherit (config.sdImage) compressImage;
      populateImageCommands = config.sdImage.populateRootCommands;
      volumeLabel = "nixos"; # Custom label instead of default "NIXOS_SD"
    }
  );
}
