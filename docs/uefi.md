# UEFI

## 1. Flash [edk2-rk3588] to SPI NOR flash or SD Card

1. Download the prebuilt UEFI firmware from [edk2-rk3588/releases](https://github.com/edk2-porting/edk2-rk3588/releases).

1. Flash the UEFI firmware to the SPI NOR flash or SD Card.

- For SD Card, use `dd` to flash the UEFI firmware to the SD Card.

- For SPI NOR flash, boot the board with a Linux distro that supports your SBC, such as [armbian](https://www.armbian.com/download/) or your SBC's official image, then use `dd` to flash the UEFI firmware to the SPI NOR flash from the live running system.

1. Reboot the board, and you should see the UEFI boot menu.

1. Change the following settings in the UEFI boot menu:

   - Enter [Device Manager] => [Rockchip Platform Configuration] => [ACPI / Device Tree]
   - Change [Config Table Mode] to `Both`.
   - Change [Support DTB override & overlays] to `Enabled`.(see <https://github.com/ryan4yin/nixos-rk3588/issues/22> for more details)

## 2. Flash NixOS to a USB drive

- Build the raw efi image:

```bash
nix build .#rawEfiImage-orangepi5pro --show-trace -L --verbose --system aarch64-linux
```

- Flash the raw efi image to a USB drive.

```bash
cat result | sudo dd status=progress bs=8M of=/dev/sdX
```

- If you want to flash the raw efi image to an EMMC, you need to first live boot the board with a Linux distro that supports your SBC, such as [armbian](https://www.armbian.com/download/) or your SBC's official image, then use `dd` to flash the raw efi image to the EMMC from the live running system.

## 3. Install NixOS to the board

- Boot the board with the NixOS UEFI image.

- Follow the [NixOS installation guide](https://nixos.org/manual/nixos/stable/index.html#sec-installation) to install NixOS to the EMMC.
