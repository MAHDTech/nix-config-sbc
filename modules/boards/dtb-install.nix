{
  config,
  pkgs,
  ...
}:
let
  extraInstallCommands = ''
    ${pkgs.coreutils}/bin/mkdir -p /boot/dtb/base
    ${pkgs.coreutils}/bin/cp -r ${config.hardware.deviceTree.package}/rockchip/* /boot/dtb/base/
    ${pkgs.coreutils}/bin/sync
  '';
in
{

  # NOTE: To see what DTBs are available, run:
  # ls /nix/store/*linux*/dtbs/rockchip/*orange*

  # Note that this is only needed on UEFI systems, even though we set it
  # everywhere. It will have no effect unless `boot.loader.grub.enable = true`.
  boot.loader = {
    systemd-boot.extraInstallCommands = extraInstallCommands;
    grub.extraInstallCommands = extraInstallCommands;
  };
}
