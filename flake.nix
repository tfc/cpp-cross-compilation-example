{
  description = "C++ Crosscompilation Example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, pkgs, system, ... }: {
        packages = {
          minisha256sum = pkgs.callPackage ./package.nix { };
          default = config.packages.minisha256sum;

          static = pkgs.pkgsStatic.callPackage ./package.nix { };
          x86 = pkgs.pkgsCross.gnu64.callPackage ./package.nix { };
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
        };
      };
      flake = { };
    };
}
