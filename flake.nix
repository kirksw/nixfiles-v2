{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    #nixpkgs-edge.url = "github:nixos/nixpkgs/release-25.05";
    #nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
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
      url = "git+ssh://git@github.com/lunarway/lw-nix?ref=feat/add-rds-access";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
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
                sshKey = "kirksw";
                dirs = [
                  "~/git/github.com/lunarway/**"
                ];
              };
              kirksw = {
                sshKey = "lunarway";
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
              "kirksw"
              "lunarway"
              "default"
            ];
          };
          overlays = [
            lunar-tools.overlays.default
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
          user = "k8s";
          hostModule = ./hosts/nixos/ry6a;
          homeModule = null;
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
