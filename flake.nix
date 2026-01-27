{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = { self, nixpkgs, quickshell, spicetify-nix }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit spicetify-nix; };
        
        modules = [
          ./configuration.nix
          spicetify-nix.nixosModules.default
          
          # Make quickshell available
          ({ pkgs, ... }: {
            environment.systemPackages = [
              quickshell.packages.${pkgs.system}.default
            ];
          })
        ];
      };
    };
  };
}