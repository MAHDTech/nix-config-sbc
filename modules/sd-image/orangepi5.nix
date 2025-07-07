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

  # add some missing deviceTree in armbian/linux-rockchip:
  # orange pi 5's deviceTree in armbian/linux-rockchip:
  #    https://github.com/armbian/linux-rockchip/blob/rk-5.10-rkr4/arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dts
  hardware = {
    deviceTree = {
      name = "rockchip/rk3588s-orangepi-5.dtb";
      overlays = [
        {
          # enable pcie2x1l2 (NVMe), disable sata0
          name = "orangepi5-sata-overlay";
          dtsText = ''
            // Orange Pi 5 Pcie M.2 to sata
            /dts-v1/;
            /plugin/;

            / {
              compatible = "rockchip,rk3588s-orangepi-5";

              fragment@0 {
                target = <&sata0>;

                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@1 {
                target = <&pcie2x1l2>;

                __overlay__ {
                  status = "okay";
                };
              };
            };
          '';
        }

        # enable i2c1
        {
          name = "orangepi5-i2c-overlay";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "rockchip,rk3588s-orangepi-5";

              fragment@0 {
                target = <&i2c1>;

                __overlay__ {
                  status = "okay";
                  pinctrl-names = "default";
                  pinctrl-0 = <&i2c1m2_xfer>;
                };
              };
            };
          '';
        }
      ];
    };

    firmware = [ ];
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
      inherit (config.sdImage) compressImage;
      inherit (config.sdImage) storePaths;
      inherit uuid;
      populateImageCommands = config.sdImage.populateRootCommands;
      volumeLabel = "nixos"; # Custom label instead of default "NIXOS_SD"
    }
  );
}
