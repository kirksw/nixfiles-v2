{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    # NOTE: uncomment one of the following blocks to switch between stable and unstable modes
    # stable mode start
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    # home-manager = {
    #   url = "github:nix-community/home-manager/release-24.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # darwin = {
    #   url = "github:lnl7/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # stable mode end
    # unstable mode start
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # unstable mode end
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-infisical = {
      url = "github:infisical/homebrew-get-cli";
      flake = false;
    };
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    wezterm = {
      url = "github:wez/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-infisical, homebrew-nikitabobko, home-manager, nixpkgs, nixpkgs-stable, nixpkgs-unstable, disko, neovim-nightly-overlay, wezterm } @inputs:
    let
      user = "kirk";
      linuxSystems = ["x86_64-linux" "aarch64-linux"];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      # TODO: create some apps for making installation and management easier
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system: darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            ./hosts/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./hosts/darwin/home.nix;
                sharedModules = [
                  ./modules/home
                ];
                # we pass inputs into home-manager so that we can utilize the overlays
                extraSpecialArgs = {
                  inherit inputs;
                  pkgs-stable = import nixpkgs-stable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                  pkgs-unstable = import nixpkgs-unstable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "infisical/homebrew-get-cli" = homebrew-infisical;
                  "nikitabobko/homebrew-tap" = homebrew-nikitabobko;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
          ];
        }
      );

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./hosts/nixos/home.nix;
              sharedModules = [
                  import ./modules/home
              ];
              # we pass inputs into home-manager so that we can utilize the overlays
              extraSpecialArgs = {
                inherit inputs;
                pkgs-stable = import nixpkgs-stable {
                  inherit system;
                  config.allowUnfree = true;
                };
                pkgs-unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };
              };
            };
          }
        ];
     });
  };
}
