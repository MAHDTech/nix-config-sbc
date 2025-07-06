{
  config,
  lib,
  pkgs,
  ...
}:
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

    # NOTE: Do NOT set nomodeset with Intel GPU as they require kernel mode-setting.
    kernelParams = [
      "acpi_osi=Linux"
      "acpi_backlight=native"

      "nohibernate"

      "usbcore.autosuspend=-1"

      "quiet"
    ];

    # Increase file watcher limit for all users
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

      # systemd-boot is only for UEFI systems, not SD images
      systemd-boot = {
        enable = lib.mkDefault true;

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
