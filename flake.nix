{
  outputs = { self, nixpkgs }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix  # Your existing config
      ];
    };
  };
}