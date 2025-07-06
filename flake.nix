{
  description = "NixOS configuration for single board computers.";

  nixConfig = {
    extra-substituters = "https://devenv.cachix.org https://salt-labs.cachix.org https://cosmic.cachix.org/";
    extra-trusted-public-keys = "
      devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
      salt-labs.cachix.org-1:9lBlhm9rPAHrb1GXnclFomAHsnj3kV+4DyJspy/nQlw=
      cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=
    ";
    extra-experimental-features = "nix-command flakes";
    warn-dirty = true;
  };

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      #ref = "release-25.05";
      ref = "nixos-unstable";
      flake = true;
    };

    nixpkgs-unstable = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
      flake = true;
    };

    nixos-hardware = {
      type = "github";
      owner = "NixOS";
      repo = "nixos-hardware";
      ref = "master";
      flake = true;
    };

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default";
      ref = "main";
      flake = true;
    };

    cachix = {
      type = "github";
      owner = "cachix";
      repo = "cachix";
      ref = "master";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      type = "github";
      owner = "cachix";
      repo = "devenv";
      ref = "main";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";
      ref = "master";
      flake = true;
    };

    nixos-generators = {
      type = "github";
      owner = "nix-community";
      repo = "nixos-generators";
      ref = "master";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
      flake = true;
    };

    sops-nix = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      ref = "master";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      flake-utils,
      nixos-generators,
      nixpkgs,
      pre-commit-hooks,
      sops-nix,
      self,
      ...
    }@inputs:
    let
      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It's perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      globalStateVersion = "25.05";

      #########################
      # Systems
      #########################

      # Local system.
      #localSystem = "x86_64-linux";

      # SBC system.
      aarch64System = "aarch64-linux";

      #########################
      # Configuration Functions
      #########################

      configurations = import ./config {
        inherit aarch64System;
        inherit globalStateVersion;
        inherit inputs;
        inherit nixpkgs;
        inherit self;
        inherit sops-nix;
      };
    in
    {
      #########################
      # NixOS Modules
      #########################

      nixosModules = {
        boards = {
          # Orange Pi 5 SBC
          orangepi5 = {
            core = import ./modules/boards/orangepi5.nix;
            sd-image = ./modules/sd-image/orangepi5.nix;
          };

          # Orange Pi 5b SBC
          orangepi5b = {
            core = import ./modules/boards/orangepi5b.nix;
            sd-image = ./modules/sd-image/orangepi5b.nix;
          };

          # Orange Pi 5 Plus SBC
          orangepi5plus = {
            core = import ./modules/boards/orangepi5plus.nix;
            sd-image = ./modules/sd-image/orangepi5plus.nix;
          };

          # Orange Pi 5 Pro SBC
          orangepi5pro = {
            core = import ./modules/boards/orangepi5pro.nix;
            sd-image = ./modules/sd-image/orangepi5pro.nix;
          };
        };

        formats =
          { ... }:
          {
            imports = [
              nixos-generators.nixosModules.all-formats
            ];

            nixpkgs.hostPlatform = aarch64System;
            formatConfigs.rk3588-raw-efi = ./modules/rk3588-raw-efi.nix;
          };
      };

      #########################
      # NixOS Configurations
      #########################

      nixosConfigurations =

        # SD Image
        (builtins.mapAttrs (
          name: board:
          nixpkgs.lib.nixosSystem {
            system = aarch64System;
            specialArgs = {
              inherit globalStateVersion;
            };
            modules = [
              ./modules/configuration.nix

              board.core
              board.sd-image

              {
                # Enable unfree packages for firmware
                nixpkgs.config.allowUnfree = true;
                sdImage.imageBaseName = "${name}-sd-image";
              }
            ];
          }
        ) self.nixosModules.boards)

        # UEFI system
        // (nixpkgs.lib.mapAttrs' (
          name: board:
          nixpkgs.lib.nameValuePair (name + "-uefi") (
            nixpkgs.lib.nixosSystem {
              system = aarch64System;
              specialArgs = {
                inherit globalStateVersion;
              };
              modules = [
                ./modules/configuration.nix

                board.core
                self.nixosModules.formats

                {
                  # Enable unfree packages for firmware
                  nixpkgs.config.allowUnfree = true;
                }
              ];
            }
          )
        ) self.nixosModules.boards)

        # System-specific configurations
        // configurations.hosts;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          # SD Image (native)
          sdImage-opi5 = self.nixosConfigurations.orangepi5.config.system.build.sdImage;
          sdImage-opi5b = self.nixosConfigurations.orangepi5b.config.system.build.sdImage;
          sdImage-opi5plus = self.nixosConfigurations.orangepi5plus.config.system.build.sdImage;
          sdImage-orangepi5pro = self.nixosConfigurations.orangepi5pro.config.system.build.sdImage;

          # UEFI raw image (native)
          rawEfiImage-opi5 = self.nixosConfigurations.orangepi5-uefi.config.formats.rk3588-raw-efi;
          rawEfiImage-opi5plus = self.nixosConfigurations.orangepi5plus-uefi.config.formats.rk3588-raw-efi;
          rawEfiImage-orangepi5pro = self.nixosConfigurations.orangepi5pro-uefi.config.formats.rk3588-raw-efi;

          # System-specific packages

          # SD Images (native)
          sdImage-opi-001 = self.nixosConfigurations.opi-001.config.system.build.sdImage;
          sdImage-opi-002 = self.nixosConfigurations.opi-002.config.system.build.sdImage;

          # UEFI raw images (native)
          rawEfiImage-opi-001 = self.nixosConfigurations.opi-001-uefi.config.formats.rk3588-raw-efi;
          rawEfiImage-opi-002 = self.nixosConfigurations.opi-002-uefi.config.formats.rk3588-raw-efi;
        };

        #########################
        # DevShells
        #########################

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        #########################
        # Checks
        #########################

        checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            actionlint.enable = true;
            check-json.enable = true;
            check-merge-conflicts.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-symlinks.enable = true;
            check-yaml.enable = true;
            commitizen.enable = true;
            convco.enable = true;
            deadnix = {
              enable = true;
              settings = {
                noUnderscore = true;
              };
            };
            dialyzer.enable = true;
            editorconfig-checker.enable = true;
            mixed-line-endings.enable = true;
            nixfmt-rfc-style.enable = true;
            prettier = {
              enable = true;
              settings = {
                configPath = ".prettierrc.yaml";
              };
            };
            pretty-format-json = {
              enable = true;
              args = [
                "--autofix"
              ];
            };
            ripsecrets.enable = true;
            shellcheck = {
              enable = true;
              args = [
                "--external-sources"
              ];
            };
            shfmt.enable = true;
            staticcheck.enable = true;
            statix.enable = true;
            trim-trailing-whitespace.enable = true;
            typos.enable = true;
          };
        };
      }
    );
}
