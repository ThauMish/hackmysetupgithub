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
            ./hosts/${host}/common/config.nix

            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager

           {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.users."${username}" = {
              imports = [ ./hosts/${host}/${username}/home.nix ];
            };
           }
         ];
        };
      };
    };
}
