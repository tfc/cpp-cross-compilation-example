{ config, pkgs, ... }:

{
  imports = [
    ./service.nix
  ];

  nixpkgs.overlays = [ (import ./overlay.nix) ];

  environment.systemPackages = with pkgs; [
    minisha256sum
  ];

  services.hash.enable = true;

  networking.firewall.allowedTCPPorts = [
    config.services.hash.port
  ];
}
