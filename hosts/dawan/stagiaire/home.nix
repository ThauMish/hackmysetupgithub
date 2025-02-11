{ config, lib, ...}:

let
  pkgs = config._module.args.pkgs;
  username = "stagiaire";
  host = "pc-stagiaire";
  #inherit (import ../common/variables.nix) gitUsername gitEmail;
  sharedHome = import ../common/home.nix {
    inherit pkgs lib username host config;
  };
in
{
  imports = [ sharedHome ];

  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
  ] ++ sharedHome.home.packages;

  programs = sharedHome.programs // { };
}
