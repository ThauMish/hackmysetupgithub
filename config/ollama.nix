{ config, pkgs, ... }:

{
  systemd.services.ollama = {
    description = "Ollama LLM Container";
    after = [ "network.target" "docker.service" ];
    wants = [ "docker.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.docker}/bin/docker run -d --rm --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama";
      ExecStop = "${pkgs.docker}/bin/docker stop ollama";
      Restart = "always";
    };
    install = {
      WantedBy = [ "multi-user.target" ];
    };
  };
}
