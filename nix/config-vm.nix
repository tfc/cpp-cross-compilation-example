{ config, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  virtualisation.graphics = false;
  users.users.root.initialHashedPassword = "";

  virtualisation.forwardPorts = [
    { from = "host"; host.port = 2222; guest.port = 22; }
    { from = "host"; host.port = 8000; guest.port = config.services.hash.port; }
  ];
}
