{
  nixpkgs,
  inputs,
  globalStateVersion,
  aarch64System,
  self,
  sops-nix,
  ...
}:
let
  # Configuration helper function
  configNixOS =
    {
      username ? "nixos",
      hostname,
      board,
      system ? aarch64System,
      extraModules ? [ ],
      ...
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit username;
        inherit hostname;
        inherit globalStateVersion;
        inherit nixpkgs;
      };
      modules = [
        # Board-specific configuration
        self.nixosModules.boards.${board}.core

        # System-specific configuration
        ./hosts/${hostname}

        sops-nix.nixosModules.sops
      ] ++ extraModules;
    };
in
{
  # Export the configuration function
  inherit configNixOS;

  # Host-specific configurations
  hosts = {
    # Native configurations
    opi-001 = configNixOS {
      hostname = "opi-001";
      board = "orangepi5pro";
      extraModules = [
        self.nixosModules.boards.orangepi5pro.sd-image
        #nixos-hardware.nixosModules.orange-pi-5-pro
      ];
    };

    opi-002 = configNixOS {
      hostname = "opi-002";
      board = "orangepi5pro";
      extraModules = [
        self.nixosModules.boards.orangepi5pro.sd-image
        #nixos-hardware.nixosModules.orange-pi-5-pro
      ];
    };

    # UEFI configurations
    opi-001-uefi = configNixOS {
      hostname = "opi-001";
      board = "orangepi5pro";
      extraModules = [
        self.nixosModules.formats
        #nixos-hardware.nixosModules.orange-pi-5-pro
      ];
    };

    opi-002-uefi = configNixOS {
      username = "rk";
      hostname = "opi-002";
      board = "orangepi5pro";
      extraModules = [
        self.nixosModules.formats
        #nixos-hardware.nixosModules.orange-pi-5-pro
      ];
    };
  };
}
