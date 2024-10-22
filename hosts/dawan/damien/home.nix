{ pkgs, config, lib, ... }:

let
  username = "damien";
  inherit (import ../common/variables.nix) gitUsername gitEmail;
  sharedHome = import ../common/home.nix { inherit pkgs config lib; };
in
{
  imports = [ sharedHome ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # Ajouts spécifiques à Damien
  home.packages = with pkgs; [
  ] ++ sharedHome.home.packages;

  programs = sharedHome.programs // {
  };
}
