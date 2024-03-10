{ config, pkgs, lib, ... }:
let
  cfg = config.services.hash;
in
{
  options.services.hash = {
    enable = lib.mkEnableOption "Hash as a Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port to listen on";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hash = {
      description = "Friendly Hashing as a Service Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = ''${pkgs.socat}/bin/socat \
        TCP4-LISTEN:${builtins.toString cfg.port},reuseaddr,fork \
        EXEC:${pkgs.minisha256sum}/bin/minisha256sum
      '';
    };
  };
}
