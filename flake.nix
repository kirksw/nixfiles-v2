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
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lunar-tools = {
      url = "git+ssh://git@github.com/lunarway/lw-nix?ref=feat/zsh-plugin";
    };
  };

  outputs =
    inputs@{
      self,
      darwin,
      nix-homebrew,
      home-manager,
      nixpkgs,
      nixpkgs-stable,
      disko,
      flake-utils,
      lunar-tools,
    }:
    let
      user = "kisw";
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [ "aarch64-darwin" ];
      nixfiles = ./.;
    in
    flake-utils.lib.eachDefaultSystem (system: {
      apps =
        let
          mkApp = scriptName: system: {
            type = "app";
            program = "${
              (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
                #!${nixpkgs.legacyPackages.${system}.runtimeShell}
                PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
                echo "Running ${scriptName} for ${system}"
                exec ${self}/apps/${system}/${scriptName}
              '')
            }/bin/${scriptName}";
          };
        in
        {
          build = mkApp "build" system;
          switch = mkApp "switch" system;
          rollback = mkApp "rollback" system;
        };
    })
    // {
      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
        system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs user nixfiles; };
          modules = [
            { nixpkgs.overlays = [ lunar-tools.overlays.default ]; }
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            ./hosts/darwin/work
            (import ./modules/shared/homemanager.nix {
              inherit user nixfiles;
              homeModule = ./hosts/darwin/work/home.nix;
              inputs = inputs;
              nixpkgsStable = inputs.nixpkgs-stable;
            })
          ];
        }
      );

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            disko.nixosModules.disko
            ./hosts/nixos/desktop
            (import ./modules/shared/homemanager.nix {
              inherit user;
              homeModule = ./hosts/nixos/desktop/home.nix;
              inputs = inputs;
              nixpkgsStable = inputs.nixpkgs-stable;
            })
          ];
        }
      );
    };
}
