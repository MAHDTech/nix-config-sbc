# =========================================================================
#      Orange Pi 5 Pro Specific Configuration
# =========================================================================
{
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
    # TODO: Add DTB when default kernel includes it.
    #./dtb-install.nix
  ];

  hardware = {
    deviceTree = {
      # Use the new Orange Pi 5 Pro DTB from our custom kernel
      name = "rockchip/rk3588s-orangepi-5-pro.dtb";
      overlays = [ ];
    };

    firmware = [
      (pkgs.callPackage ../../pkgs/orangepi-firmware { })
    ];
  };

  # Orange Pi 5 Pro specific kernel parameters for HDMI/Display
  boot = {

    # Use a custom kernel with Orange Pi 5 Pro DTS
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ../../pkgs/kernel/vendor.nix { });

    kernelParams = [
      "rootwait"

      # Console and early boot
      "earlycon"
      "consoleblank=0"
      "console=ttyS2,1500000"
      "console=tty1"

      # Graphics and HDMI specific for RK3588S
      "video=HDMI-A-1:1920x1080@60"
      "drm.debug=0"

      # Ensure proper device tree loading
      "initcall_debug"
    ];

    kernelModules = [
      "rockchip_drm"
      "dw_hdmi"
      "dw_mipi_dsi"
      "panfrost"
    ];

    initrd = {
      kernelModules = [
        "rockchipdrm"
        "dw_hdmi"
        "panfrost"
      ];
    };
  };
}
