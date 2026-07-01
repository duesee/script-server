{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.script-server;
  json = pkgs.formats.json { };
in
{
  options.services.script-server = {
    enable = lib.mkEnableOption "Whether to enable script-server.";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.script-server;
      description = "Script-server package to use.";
    };

    package-web = lib.mkOption {
      type = lib.types.package;
      default = pkgs.script-server-web;
      description = "Script-server-web package to use.";
    };

    settings = lib.mkOption {
      type = json.type;
      default = { };
      description = "Server configuration, see <https://github.com/bugy/script-server/wiki/Server-configuration>.";
    };

    configuration = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/script-server/conf";
      description = "Script configuration, see <https://github.com/bugy/script-server/wiki/Script-config>.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # See <https://github.com/bugy/script-server/wiki/Running-as-a-linux-service#systemd>
    systemd.services.script-server = {
      enable = true;

      description = "Script Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Restart = "always";
        RestartSec = "1s";
        ExecStart = ''
          ${cfg.package}/bin/script-server \
            --config-file "${json.generate "script-server-config" cfg.settings}" \
            --config-dir "${cfg.configuration}" \
            --web-folder "${cfg.package-web}" \
            --log-folder /var/log/script-server \
            --tmp-folder /tmp
        '';

        StateDirectory = "script-server";
        LogsDirectory = "script-server";

        DynamicUser = true;
        PrivateTmp = true;
      };
    };
  };
}
