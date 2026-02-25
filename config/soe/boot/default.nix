{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Check if we're building an SD image by looking for sdImage options
  isSDImage = builtins.hasAttr "sdImage" config;
in
{
  boot = {
    consoleLogLevel = 4;

    initrd = {
      enable = true;
      systemd = {
        enable = true;
      };
      kernelModules = [ ];
    };

    extraModulePackages = with config.boot.kernelPackages; [ ];

    kernelModules =
      [
      ];

    kernelParams = [
      "acpi_osi=Linux"
      "acpi_backlight=native"

      "nohibernate"

      "usbcore.autosuspend=-1"

      "quiet"
    ];

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
      "vm.compact_unevictable_allowed" = 1;
      "vm.swappiness" = 10;
    };

    plymouth = {
      enable = true;
      font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
    };

    growPartition = true;

    loader = {
      timeout = 10;

      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };

      generationsDir = {
        copyKernels = true;
      };

      # UEFI images = systemd-boot
      # SD card images = u-boot
      systemd-boot = {
        # Enable systemd-boot for UEFI systems, disable by default for SD card images
        enable = lib.mkDefault (!isSDImage);

        graceful = true;
        memtest86.enable = false;
        netbootxyz.enable = false;

        configurationLimit = 10;

        # Disable bootloader editing for security
        editor = false;
      };

      grub = {
        enable = lib.mkDefault false;
      };
    };
  };
}
