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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      flake-utils,
      sops-nix,
    }:
    let
      mylibs = import ./lib {
        lib = nixpkgs.lib;
        inherit inputs self;
      };

      darwinSystems = {
        "lunar" = {
          system = "aarch64-darwin";
          user = "kisw";
          hostModule = ./hosts/darwin/work;
          homeModule = ./hosts/darwin/work/home.nix;
          nixDirectory = "/Users/kisw/nixfiles-v2";
          git = {
            fallback = "personal"; # applies to all other directories
            profiles = {
              lunar = {
                sshKey = "default";
                dirs = [
                  "~/git/github.com/lunarway/**"
                ];
              };
              personal = {
                sshKey = "default";
                dirs = [
                  "~/git/github.com/kirksw/**"
                  "~/git/github.com/cntd-io/**"
                  "~/nixfiles-v2/**"
                ];
              };
            };
          };
          ssh = {
            keys = [
              "default"
            ];
          };
          overlays = [];
          enableHomebrew = true;
          enableLunar = true;
        };
      };

      nixosSystems = {
        "home-desktop" = {
          system = "x86_64-linux";
          user = "kirk";
          hostModule = ./hosts/nixos/desktop;
          homeModule = ./hosts/nixos/desktop/home.nix;
          nixDirectory = "/Home/kirksw/nixfiles-v2";
          git = {
            fallback = "personal"; # applies to all other directories
            profiles = {
              personal = {
                sshKey = "default";
                dirs = [
                  "~/git/github.com/kirksw/**"
                  "~/git/github.com/cntd-io/**"
                  "~/nixfiles-v2/**"
                ];
              };
            };
          };
          ssh = {
            keys = [
              "default"
            ];
          };
          enableLunar = false;
          enableHomebrew = false;
        };
      };
    in
    flake-utils.lib.eachDefaultSystem (system: {
      apps = {
        build = mylibs.app.mkApp "build" system;
        switch = mylibs.app.mkApp "switch" system;
        rollback = mylibs.app.mkApp "rollback" system;
      };
    })
    // {
      darwinConfigurations = builtins.mapAttrs mylibs.darwin.mkDarwinSystem darwinSystems;
    }
    // {
      nixosConfigurations = builtins.mapAttrs mylibs.nixos.mkNixosSystem nixosSystems;
    };
}
