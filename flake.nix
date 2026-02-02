{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    # NOTE: for unstable
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # darwin = {
    #   url = "github:nix-darwin/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
      url = "git+ssh://git@github.com/lunarway/lw-nix?ref=feat/streamline-wrappers";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    yazi.url = "github:sxyazi/yazi";
  };

  outputs =
    inputs@{
      self,
      darwin,
      nix-homebrew,
      home-manager,
      nixpkgs,
      disko,
      flake-utils,
      lunar-tools,
      sops-nix,
      wezterm,
      deploy-rs,
      yazi,
    }:
    let
      mylibs = import ./lib {
        inherit (nixpkgs) lib;
        inherit inputs self;
      };

      darwinSystems = {
        "lunar" = {
          system = "aarch64-darwin";
          user = "kisw";
          hostModule = ./hosts/darwin/work;
          homeModule = ./hosts/darwin/work/home.nix; # set to null to disable hm
          nixDirectory = "/Users/kisw/nixfiles-v2";
          git = {
            fallback = "kirksw"; # set to null to disable
            profiles = {
              lunarway = {
                dirs = [
                  "~/git/github.com/lunarway/**"
                ];
              };
              kirksw = {
                dirs = [
                  "~/git/github.com/kirksw/**"
                  "~/git/github.com/cntd-io/**"
                  "~/nixfiles-v2/**"
                ];
              };
            };
          };
          ssh = {
            # NOTE: git profile expects matching sshs key name
            keys = [
              "kirksw"
              "lunarway"
              "default"
            ];
          };
          overlays = [
            lunar-tools.overlays.default
            yazi.overlays.default
          ];
          enableHomebrew = true;
          enableLunar = true;
        };
      };

      nixosSystems = {
        #"home-desktop" = {
        #  system = "x86_64-linux";
        #  user = "kirksw";
        #  nixDirectory = "/Home/kirksw/nixfiles-v2";
        #  ssh = {
        #    keys = [
        #      "default"
        #    ];
        #  };
        #  git = {
        #    default = "personal";
        #    profiles = [
        #      "personal"
        #    ];
        #  };
        #  hostModule = ./hosts/nixos/desktop;
        #  homeModule = ./hosts/nixos/desktop/home.nix;
        #};
        "nixos-ry6a" = {
          system = "x86_64-linux";
          user = "root";
          hostModule = ./hosts/nixos/ry6a;
          homeModule = null;
        };
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Auto-discover packages from packages/*/default.nix
        packagesDir = ./packages;
        packageNames = builtins.filter (name: builtins.pathExists (packagesDir + "/${name}/default.nix")) (
          builtins.attrNames (builtins.readDir packagesDir)
        );

        packages = builtins.listToAttrs (
          map (name: {
            inherit name;
            value = pkgs.callPackage (packagesDir + "/${name}") { };
          }) packageNames
        );

        # Update script that runs all package updateScripts
        updateAllPackages = pkgs.writeShellScriptBin "update-packages" ''
          set -euo pipefail
          cd ${toString ./.}
          echo "Updating all packages..."
          ${builtins.concatStringsSep "\n" (
            map (name: ''
              echo "→ Updating ${name}..."
              ${packages.${name}.updateScript or "echo 'No updateScript for ${name}'"}
            '') packageNames
          )}
          echo "Done!"
        '';
      in
      {
        inherit packages;

        apps = {
          build = mylibs.app.mkApp "build" system;
          switch = mylibs.app.mkApp "switch" system;
          rollback = mylibs.app.mkApp "rollback" system;
          update-packages = {
            type = "app";
            program = "${updateAllPackages}/bin/update-packages";
          };
        };
      }
    )
    // {
      darwinConfigurations = builtins.mapAttrs mylibs.darwin.mkDarwinSystem darwinSystems;
    }
    // {
      nixosConfigurations = builtins.mapAttrs mylibs.nixos.mkNixosSystem nixosSystems;
    }
    // {
      deploy = {
        nodes.nixos-ry6a = {
          hostname = "nixos-ry6a";
          sshUser = "root";

          remoteBuild = true;
          factConnection = true;

          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-ry6a;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
