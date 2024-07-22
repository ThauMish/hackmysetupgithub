{ config, pkgs, ... }:

let
  tmuxConfig = pkgs.writeTextFile {
    name = "tmux.conf";
    text = builtins.readFile ./tmux/.tmux.conf;
  };

  tmuxConfigLocal = pkgs.writeTextFile {
    name = "tmux.conf.local";
    text = builtins.readFile ./tmux/.tmux.conf.local;
  };
in {
  environment.systemPackages = with pkgs; [
    tmux
  ];

  home.file.".tmux.conf".source = tmuxConfig;
  home.file.".tmux.conf.local".source = tmuxConfigLocal;
}
