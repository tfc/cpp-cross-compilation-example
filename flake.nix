{
  description = "C++ Crosscompilation Example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { config, pkgs, system, ... }: {
      packages = {
        minisha256sum = pkgs.callPackage ./nix/package.nix { };
        default = config.packages.minisha256sum;
        clang = config.packages.minisha256sum.override {
          stdenv = pkgs.clangStdenv;
        };
        static = pkgs.pkgsStatic.callPackage ./nix/package.nix { };

        x86 = pkgs.pkgsCross.gnu64.callPackage ./nix/package.nix { };
        x86-static = pkgs.pkgsCross.gnu64.pkgsStatic.callPackage ./nix/package.nix { };
        aarch64 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./nix/package.nix { };
        aarch64-static = pkgs.pkgsCross.aarch64-multiplatform.pkgsStatic.callPackage ./nix/package.nix { };

        windows = pkgs.pkgsCross.mingwW64.callPackage ./nix/package.nix { };

        inherit ((pkgs.nixos [ ./nix/config-app.nix ./nix/config-vm.nix ]).config.system.build) vm;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.packages.default ];
        inherit (config.checks.pre-commit-check) shellHook;
      };

      checks = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            clang-format.enable = true;
            cmake-format.enable = true;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        };
      } // config.packages;
    };
  };
}
