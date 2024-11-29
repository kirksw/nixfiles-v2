{ pkgs, lib, config, ... }:

{
  options = {
    cloud.enable = lib.mkEnableOption "enables cloud";
  };

  config = lib.mkIf config.cloud.enable {
    # gcp
    home.packages = with pkgs; [
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.managed-flink-client
      ])
    ];
    # aws
    # azure
    # linode
  };
}
