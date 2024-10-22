{
  description = "ZaneyOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = nixpkgs.lib;

      # Variables qui seront remplacées par le script bootstrap.sh
      host = "__HOST__";
      username = "__USERNAME__";
    in
    {
      nixosConfigurations = {
        "${host}" = nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit system inputs pkgs;
            host = "${host}";
            username = "${username}";
          };

          modules = [
            # Importation du fichier config.nix commun
            ./hosts/${host}/common/config.nix

            # Importation des modules nécessaires
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager

            # Configuration Home Manager pour l'utilisateur
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              # Spécification de la configuration Home Manager de l'utilisateur
              home-manager.users."${username}" = import ./hosts/${host}/${username}/home.nix;
            }
          ];
        };
      };
    };
}

