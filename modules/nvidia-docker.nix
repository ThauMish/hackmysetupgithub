{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  ];

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    package = pkgs.docker;
  };

  environment.variables = {
    NVIDIA_VISIBLE_DEVICES = "all";
    NVIDIA_DRIVER_CAPABILITIES = "compute,utility,graphics,video";
  };
  # Enable NVIDIA container toolkit
 # services.nvidia-container-runtime.enable = true;
}

