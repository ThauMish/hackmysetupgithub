{ config, ...}:

let
  pkgs = config.pkgs;
  lib = pkgs.lib;
  username = "thomas";
  host = "pc-thomas";
  inherit (import ../common/variables.nix) gitUsername gitEmail;
  sharedHome = import ../common/home.nix {
    inherit pkgs lib username host config;
  };
in
{
  imports = [ sharedHome ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    discord
    spotify
  ] ++ sharedHome.home.packages;

  programs = sharedHome.programs // { };
}
