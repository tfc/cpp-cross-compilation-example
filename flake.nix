{
  description = "C++ Crosscompilation Example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    perSystem = { config, pkgs, ... }: {

      packages = {
        default = pkgs.callPackage ./nix/package.nix { };
      };

      devShells = {
        inherit (config.packages) default;
        clang = config.packages.default.override { stdenv = pkgs.clangStdenv; };

        another-shell = pkgs.mkShell {
          inputsFrom = [ config.packages ];
          buildInputs = with pkgs; [
            pkg-config
            python3Packages.mkdocs
          ];
        };
      };

    };
  };
}
