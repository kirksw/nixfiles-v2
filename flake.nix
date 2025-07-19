{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    homebrew-dagger = {
      url = "github:dagger/homebrew-tap";
      flake = false;
    };
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs@{ self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-nikitabobko, homebrew-dagger, home-manager, nixpkgs, nixpkgs-stable, disko, neovim-nightly-overlay, flake-utils }:
    let
      user = "kisw";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      supportedSystems = linuxSystems ++ darwinSystems;
    in flake-utils.lib.eachDefaultSystem (system: {
      apps = let
        mkApp = scriptName: system: {
          type = "app";
          program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
            #!${nixpkgs.legacyPackages.${system}.runtimeShell}
            PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
            echo "Running ${scriptName} for ${system}"
            exec ${self}/apps/${system}/${scriptName}
          '')}/bin/${scriptName}";
        };
      in {
        build = mkApp "build" system;
        switch = mkApp "switch" system;
        rollback = mkApp "rollback" system;
      };
    }) //
    {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs user; };
          modules = [
            ./hosts/darwin
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./hosts/darwin/home.nix;
                sharedModules = [
                  ./modules/shared
                ];
                # we pass inputs into home-manager so that we can utilize the overlays
                extraSpecialArgs = {
                  inherit inputs;
                  pkgs-stable = import nixpkgs-stable {
                    inherit system;
                    config.allowUnfree = true;
                  };
                };
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
            ./modules/darwin/homebrew.nix
          ];
        }
      );

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: 
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            disko.nixosModules.disko
            ./hosts/nixos
            home-manager.nixosModules.home-manager {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user} = import ./hosts/nixos/home.nix;
                home-manager.sharedModules = [
                    import ./modules/shared
                ];
              };
            }
          ];
        }
      );
  };
}
