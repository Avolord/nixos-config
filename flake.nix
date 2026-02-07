{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, quickshell }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        modules = [
          ./configuration.nix
          
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