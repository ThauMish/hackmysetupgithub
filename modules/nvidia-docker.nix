{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nvidia-container-runtime
    nvidia-container-toolkit
  ];

  virtualisation.docker = {
    enable = true;
    extraOptions = ''
      --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
    '';
  };

  systemd.services.docker = {
    environment = {
      DOCKER_CLI_PLUGIN="/run/current-system/sw/bin/docker-cli";
      NVIDIA_VISIBLE_DEVICES="all";
      NVIDIA_DRIVER_CAPABILITIES="compute,utility";
    };
  };

  # Enable NVIDIA drivers
  hardware.nvidia = {
    modesetting.enable = true;
    package = pkgs.linuxPackages.nvidia_x11;
  };

  # Enable NVIDIA container toolkit
  services.nvidia-container-runtime.enable = true;
}
