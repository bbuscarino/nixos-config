{ config, pkgs, ... }:

let
  pubkey = import ../../services/pubkey.nix;
in
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ../../profiles/server.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    cleanTmpDir = true;
  };

  services.smartd = {
    enable = true;
    notifications = {
      mail.enable = true;
      wall.enable = false;
      #test = true;
    };
  };

  networking = {
    hostName = "nas";
    domain = "lan";

    interfaces = {
      enp6s0.ip4 = [ { address = "10.0.0.4"; prefixLength = 8; } ];
      #enp7s0.ip4 = [ { address = "10.0.0.4"; prefixLength = 8; } ];
    };

    nameservers = [ "10.0.0.1" ];
    defaultGateway = "10.0.0.1";

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 139 443 445 6001 8384 31416 19999 ];
      allowedTCPPortRanges = [ { from = 4000; to = 4007; } ];
      allowedUDPPorts = [ 137 138 ];
    };

    useDHCP = false;
  };

  time.timeZone = "Europe/Berlin";
  i18n = {
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Monitoring
  services.netdata = {
    enable = true;
    configText = ''
      [global]
      default port = 19999
      bind to = *
      # 7 days
      history = 604800
      error log = syslog
      debug log = syslog
    '';
  };
  services.vnstat.enable = true;

  systemd.extraConfig = ''
    DefaultCPUAccounting=yes
    DefaultIOAccounting=yes
    DefaultBlockIOAccounting=yes
    DefaultMemoryAccounting=yes
    DefaultTasksAccounting=yes
  '';

  # SMB Shares
  services.samba = {
    enable = true;
    syncPasswordsByPam = true;
    shares = {
      Archiv = {
        path = "/data/archiv";
        public = false;
        writable = true;
      };
      Backup = {
        path = "/data/backup";
        public = false;
        writable = true;
      };
      Media = {
        path = "/data/media";
        public = false;
        writable = true;
      };
      Upload = {
        path = "/data/upload";
        public = true;
        writable = true;
      };
    };
    extraConfig = ''
      # login to guest if login fails
      map to guest = Bad User
      # fix error with no printers
      load printers = no
      printcap name = /dev/null
      printing = bsd
    '';
  };

  # fix error in service log
  security.pam.services.samba-smbd.limits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = 16384; }
    { domain = "*"; type = "hard"; item = "nofile"; value = 32768; }
  ];

  users.extraUsers.davidak = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ pubkey.davidak ];
  };

  virtualisation.docker.enable = true;

  services.syncthing = {
    enable = true;
    user = "syncthing";
  };

  services.ipfs = {
    enable = true;
    autoMount = true;
  };

  services.boinc = {
    enable = true;
    allowRemoteGuiRpc = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [ btrfs-progs xfsprogs vnstat samba lm_sensors ];

  nix.useSandbox = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";
}