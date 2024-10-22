{ pkgs, config, lib, ... }:

let
  username = "stagiaire";
  inherit (import ../common/variables.nix) gitUsername gitEmail;
  sharedHome = import ../common/home.nix { inherit pkgs config lib; };
in
{
  imports = [ sharedHome ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
  ] ++ sharedHome.home.packages;

  programs = sharedHome.programs // {
  };
}
