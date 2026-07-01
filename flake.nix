{
  description = "Script-server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=26.05";
  };

  outputs = inputs: {
    formatter = builtins.mapAttrs (_system: pkgs: pkgs.nixfmt-tree) inputs.nixpkgs.legacyPackages;

    packages = builtins.mapAttrs (_system: pkgs: {
      script-server = pkgs.python3Packages.callPackage ./nix/package.nix { };

      script-server-web = pkgs.callPackage ./nix/package-web.nix { };

      script-server-example-configuration = pkgs.callPackage ./nix/package-example-configuration.nix { };

      vm = inputs.self.nixosConfigurations.vm.config.system.build.vm;

      lxc = inputs.self.nixosConfigurations.lxc.config.system.build.images.lxc;
    }) inputs.nixpkgs.legacyPackages;

    overlays.default = final: _prev: {
      script-server = final.python3Packages.callPackage ./nix/package.nix { };

      script-server-web = final.callPackage ./nix/package-web.nix { };
    };

    nixosModules.default = import ./nix/module.nix;

    nixosConfigurations =
      let
        base = {
          imports = [
            inputs.self.nixosModules.default
          ];

          nixpkgs.hostPlatform = "x86_64-linux";
          nixpkgs.overlays = [ inputs.self.overlays.default ];

          # Note: Do not use this in production!
          services.getty.autologinUser = "root";

          networking.firewall.allowedTCPPorts = [ 5000 ];

          services = {
            script-server = {
              enable = true;
              settings = {
                title = "Script Server";
              };
              configuration = "${inputs.self.packages."x86_64-linux".script-server-example-configuration}";
            };
          };

          system.stateVersion = "26.05";
        };
      in
      {
        vm = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            base
            (
              { modulesPath, ... }:
              {
                imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

                virtualisation.forwardPorts = [
                  {
                    from = "host";
                    host.port = 5000;
                    guest.port = 5000;
                  }
                ];
              }
            )
          ];
        };

        lxc = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            base
          ];
        };
      };
  };
}
