# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  self,
  lib,
  config,
  pkgs,
  ...
}:

let
  dashboardHost = "dashboard.cntd.io";
  uptimeHost = "uptime.cntd.io";
  tailscaleCertHost = "nixos-ry6a.tail54de03.ts.net";
  dashboardCertDir = "/var/lib/tailscale/certs/kubernetes-dashboard";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/shared
    ../../../modules/nixos
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-ry6a";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    k8s = {
      isNormalUser = true;
      description = "k8s";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      # packages = with pkgs; [ ];
    };
    kisw = {
      isNormalUser = true;
      description = "my user";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

  };

  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "k8s"
      "kisw"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    neofetch
    htop
    kubectl
  ];

  # List services that you want to enable:

  # Enable vvirtualisation
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [
    "root"
    "k8s"
  ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  #networking.firewall.allowedTCPPorts = [ 6443 ];
  #networking.firewall.allowedUDPPorts = [ 8472 ];
  #networking.firewall.allowedTCPPortRanges = [
  #  {
  #    from = 30000;
  #    to = 32767;
  #  }
  #];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # we use tailscale for managing ssh access
  services.tailscale.enable = true;
  systemd.services.tailscaled.restartIfChanged = false;
  networking.nameservers = [
    "100.100.100.100"
    "8.8.8.8"
    "1.1.1.1"
  ];
  networking.search = [ "tail54de03.ts.net" ];

  # secrets
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets = {
      "k8s/node/secret" = {
        sopsFile = "${self}/secrets/k8s/node.yaml";
        key = "secret";
        mode = "0400";
      };

      "ssh/root/authorizedKey" = {
        sopsFile = "${self}/secrets/ssh/ry6a-root.yaml";
        key = "authorizedKey";
        mode = "0400";
      };

      "cloudflare/tunnel/token" = {
        sopsFile = "${self}/secrets/cloudflare/ry6a-tunnel-token.yaml";
        key = "token";
        mode = "0400";
      };
    };
  };

  system.activationScripts.rootAuthorizedKey = {
    deps = [ "setupSecrets" ];
    text = ''
      install -d -m 0755 /etc/ssh/authorized_keys.d
      install -m 0600 -o root -g root ${
        config.sops.secrets."ssh/root/authorizedKey".path
      } /etc/ssh/authorized_keys.d/root
    '';
  };

  # custom modules
  nixosModules.k3s = {
    enable = true;
    role = "server";
    nodeName = "nixos-ry6a";
    clusterInit = true;
    tokenFile = config.sops.secrets."k8s/node/secret".path;
  };

  services.k3s.manifests = {
    kubernetes-dashboard = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml";
        hash = "sha256-lDrkAlHxumTvASxTJxv2dm0Yg90CQJPoVFZ7VkQ3ZLg=";
      };
    };

    kubernetes-dashboard-admin.content = [
      {
        apiVersion = "v1";
        kind = "ServiceAccount";
        metadata = {
          name = "admin-user";
          namespace = "kubernetes-dashboard";
        };
      }
      {
        apiVersion = "rbac.authorization.k8s.io/v1";
        kind = "ClusterRoleBinding";
        metadata.name = "admin-user";
        roleRef = {
          apiGroup = "rbac.authorization.k8s.io";
          kind = "ClusterRole";
          name = "cluster-admin";
        };
        subjects = [
          {
            kind = "ServiceAccount";
            name = "admin-user";
            namespace = "kubernetes-dashboard";
          }
        ];
      }
    ];

    kubernetes-dashboard-ingress.content = [
      {
        apiVersion = "traefik.io/v1alpha1";
        kind = "ServersTransport";
        metadata = {
          name = "dashboard-insecure";
          namespace = "kubernetes-dashboard";
        };
        spec.insecureSkipVerify = true;
      }
      {
        apiVersion = "traefik.io/v1alpha1";
        kind = "IngressRoute";
        metadata = {
          name = "kubernetes-dashboard";
          namespace = "kubernetes-dashboard";
        };
        spec = {
          entryPoints = [ "websecure" ];
          routes = [
            {
              match = "Host(`${dashboardHost}`)";
              kind = "Rule";
              services = [
                {
                  name = "kubernetes-dashboard";
                  port = 443;
                  scheme = "https";
                  serversTransport = "dashboard-insecure";
                }
              ];
            }
          ];
          tls.secretName = "kubernetes-dashboard-tls";
        };
      }
      {
        apiVersion = "traefik.io/v1alpha1";
        kind = "IngressRoute";
        metadata = {
          name = "kubernetes-dashboard-origin-http";
          namespace = "kubernetes-dashboard";
        };
        spec = {
          entryPoints = [ "web" ];
          routes = [
            {
              match = "Host(`${dashboardHost}`)";
              kind = "Rule";
              services = [
                {
                  name = "kubernetes-dashboard";
                  port = 443;
                  scheme = "https";
                  serversTransport = "dashboard-insecure";
                }
              ];
            }
          ];
        };
      }
    ];

    uptime-kuma.content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = "uptime-kuma";
      }
      {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "uptime-kuma-data";
          namespace = "uptime-kuma";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "5Gi";
        };
      }
      {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "uptime-kuma";
          namespace = "uptime-kuma";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "uptime-kuma";
          template = {
            metadata.labels.app = "uptime-kuma";
            spec = {
              containers = [
                {
                  name = "uptime-kuma";
                  image = "louislam/uptime-kuma:2";
                  imagePullPolicy = "IfNotPresent";
                  ports = [
                    {
                      containerPort = 3001;
                      name = "http";
                    }
                  ];
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/app/data";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "uptime-kuma-data";
                }
              ];
            };
          };
        };
      }
      {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "uptime-kuma";
          namespace = "uptime-kuma";
        };
        spec = {
          selector.app = "uptime-kuma";
          ports = [
            {
              port = 80;
              targetPort = 3001;
            }
          ];
        };
      }
      {
        apiVersion = "traefik.io/v1alpha1";
        kind = "IngressRoute";
        metadata = {
          name = "uptime-kuma";
          namespace = "uptime-kuma";
        };
        spec = {
          entryPoints = [ "websecure" ];
          routes = [
            {
              match = "Host(`${uptimeHost}`)";
              kind = "Rule";
              priority = 100;
              services = [
                {
                  name = "uptime-kuma";
                  port = 80;
                }
              ];
            }
          ];
          tls.secretName = "kubernetes-dashboard-tls";
        };
      }
      {
        apiVersion = "traefik.io/v1alpha1";
        kind = "IngressRoute";
        metadata = {
          name = "uptime-kuma-origin-http";
          namespace = "uptime-kuma";
        };
        spec = {
          entryPoints = [ "web" ];
          routes = [
            {
              match = "Host(`${uptimeHost}`)";
              kind = "Rule";
              services = [
                {
                  name = "uptime-kuma";
                  port = 80;
                }
              ];
            }
          ];
        };
      }
    ];
  };

  systemd.services.kubernetes-dashboard-tailscale-cert = {
    description = "Issue Tailscale cert and sync dashboard TLS secret";
    after = [
      "network-online.target"
      "tailscaled.service"
      "k3s.service"
    ];
    wants = [
      "network-online.target"
      "tailscaled.service"
      "k3s.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    script = ''
      set -euo pipefail
      install -d -m 0700 "${dashboardCertDir}"
      ${pkgs.tailscale}/bin/tailscale cert --cert-file "${dashboardCertDir}/tls.crt" --key-file "${dashboardCertDir}/tls.key" "${tailscaleCertHost}"
      for ns in kubernetes-dashboard uptime-kuma; do
        if ${pkgs.k3s}/bin/k3s kubectl get namespace "$ns" >/dev/null 2>&1; then
          ${pkgs.k3s}/bin/k3s kubectl -n "$ns" create secret tls kubernetes-dashboard-tls --cert="${dashboardCertDir}/tls.crt" --key="${dashboardCertDir}/tls.key" --dry-run=client -o yaml | ${pkgs.k3s}/bin/k3s kubectl apply -f -
        fi
      done
    '';
  };

  systemd.timers.kubernetes-dashboard-tailscale-cert = {
    description = "Rotate Tailscale dashboard TLS cert";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "12h";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
  };

  systemd.services.cloudflaredTunnel = {
    description = "Cloudflare Tunnel for cntd.io ingress";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
      ExecCondition = "${pkgs.bash}/bin/bash -lc '[ -s ${config.sops.secrets."cloudflare/tunnel/token".path} ] && ! grep -q REPLACE_ME ${config.sops.secrets."cloudflare/tunnel/token".path}'";
    };

    script = ''
      set -euo pipefail
      token="$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.sops.secrets."cloudflare/tunnel/token".path})"
      exec ${pkgs.cloudflared}/bin/cloudflared tunnel --config /etc/cloudflared/config.yml --no-autoupdate run --token "$token"
    '';
  };

  environment.etc."cloudflared/config.yml".text = ''
    ingress:
      - hostname: ${dashboardHost}
        service: https://127.0.0.1:443
        originRequest:
          noTLSVerify: true
      - hostname: ${uptimeHost}
        service: https://127.0.0.1:443
        originRequest:
          noTLSVerify: true
      - service: http_status:404
  '';
}
