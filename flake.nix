{
  description = "Starter Configuration for MacOS and NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    flake-utils.url = "github:numtide/flake-utils";

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

    llm-agents.url = "github:numtide/llm-agents.nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    yazi.url = "github:sxyazi/yazi";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      deploy-rs,
      lunar-tools,
      llm-agents,
      yazi,
      ...
    }:
    let
      mylibs = import ./lib {
        inherit (nixpkgs) lib;
        inherit inputs self;
      };

      defaultOverlays = import ./flake/overlays.nix { };

      darwinSystems =
        let
          raw = import ./flake/hosts/darwin {
            inherit
              lunar-tools
              llm-agents
              yazi
              ;
          };
        in
        builtins.mapAttrs (_: cfg: cfg // { overlays = defaultOverlays ++ (cfg.overlays or [ ]); }) raw;

      nixosSystems =
        let
          raw = import ./flake/hosts/nixos;
        in
        builtins.mapAttrs (_: cfg: cfg // { overlays = defaultOverlays ++ (cfg.overlays or [ ]); }) raw;

      mkPackageData = import ./flake/packages.nix { inherit nixpkgs; };
      mkApps = import ./flake/apps.nix {
        inherit nixpkgs mylibs;
      };

      deploy = import ./flake/deploy.nix {
        inherit self deploy-rs;
      };

      checks = import ./flake/checks.nix {
        inherit deploy-rs deploy;
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        packageData = mkPackageData system;
      in
      {
        packages = packageData.packages;

        apps = mkApps {
          inherit system;
          inherit (packageData) packageNames packages;
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
      inherit deploy checks;
    };
}
