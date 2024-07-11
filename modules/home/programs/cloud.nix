{ pkgs, lib, config, ... }:

{
  options = {
    cloud.enable = lib.mkEnableOption "enables cloud";
  };

  config = lib.mkIf config.cloud.enable {
    # gcp
    # environment.systemPackages = with pkgs; [
    #   (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    # ];
    # aws
    # azure
    # linode
  };
}

