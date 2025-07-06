# System Configuration Directory

This directory contains system-specific configurations for individual SBC deployments.

## Structure

Each system has its own directory with the following structure:

```
config/
├── hosts/
│   └── system-name/
│       ├── default.nix                   # Main system configuration
│       └── hardware-configuration.nix    # Hardware-specific settings
├── soe/
│   └── default.nix                       # Common system configuration
└── README.md
```

## Usage

### Building Images

You can build different types of images for each system:

```bash
# SD Card images (native compilation)
nix build .#sdImage-opi-001
nix build .#sdImage-opi-002

# SD Card images (cross-compilation from x86_64)
nix build .#sdImage-opi-001-cross
nix build .#sdImage-opi-002-cross

# UEFI images (native compilation)
nix build .#rawEfiImage-opi-001
nix build .#rawEfiImage-opi-002
```

### Configuration Options

Each system configuration supports:

- **U-Boot**: For SD card booting (default)
- **UEFI**: For UEFI booting with edk2-rk3588
- **Native**: Compilation on aarch64-linux
- **Cross**: Cross-compilation from x86_64-linux

## Adding New Systems

To add a new system:

1. Create a new directory under `config/` with your system name
2. Copy the structure from an existing system (e.g., `opi-001`)
3. Update the configuration files:
   - `default.nix`: System-specific settings
   - `hardware-configuration.nix`: Hardware-specific settings
4. Add the system to the main `flake.nix` in the nixosConfigurations section

## Hardware Configuration

The `hardware-configuration.nix` file should contain:

- File system configurations
- Boot loader settings
- Hardware-specific kernel modules
- Network configuration
- Any board-specific hardware settings

**Note**: You can generate a hardware configuration by running `nixos-generate-config` on the target system.

## User Configuration

The `users.nix` file contains:

- User account definitions
- SSH public keys
- User groups
- Password hashes

**Security Note**: Remember to update the SSH public keys and password hashes for your specific deployment.

## Deployment

This configuration is designed to work with deployment tools like:

- **NixOS Rebuild**: For local builds and updates
- **Custom deployment scripts**: Using the built images

## Board Support

Currently supported boards:

- Orange Pi 5
- Orange Pi 5b
- Orange Pi 5 Plus
- Orange Pi 5 Pro

Board-specific configurations are defined in the `modules/boards/` directory.
