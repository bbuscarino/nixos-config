{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/vda";
  };

  networking = {
    hostName = "transmission";
    domain = "lan";

    interfaces = { 
      eth0.ip4 = [ { address = "10.0.0.16"; prefixLength = 8; } ]; 
    };

    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    # route external traffic through vpn gateway
    defaultGateway = "10.0.0.5";

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [];
    };

    useDHCP = false;
    enableIPv6 = false;
  };

  time.timeZone = "Europe/Berlin";
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "de";
    defaultLocale = "de_DE.UTF-8";
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    wget
  ];

  services.postfix.enable = true;
  services.fail2ban.enable = true;
  services.xserver.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0gSy7qdULWLSpGuGM6BAoFztX123g/cbW6x3TfzKo0s59y9OrzHrCSTYg3QN9BY1jLRp5DSMjHvsPS1Z/yp3EIJJS/dDso5/noDqOMBLOQgIdCLKipTudngpFDvnCAAg0IQl6iuVRznQvq9Xww65uYyR3OAv4DMvHFQn0qa5G3ZHCoj7I6FATTwGDKPeuqVF2MtdXC1XXx7v7zsar1sBhibUlbWSWhSvw+vhM+Qtj95wkHzI8O93Xy8Vqb5/OoXQDGyA0MnORCLeE8t7EvUi9ukXGz6QMwRX/T1RTLBP+pvrT5UyPtchzgZigbxvegnAy8HRA7I9TlUSFnTVvN6sg6z7n/F09HX1ETBv1qce/uuDc+npfM6Kdykz93ydro1ZfnPabD6rvie972EK5IVsO6n5066vVVhUt9QxDl2CDa0tLBxnGovvV1nmtcjq2AewOX2vj5qD0U256AiiS8tNA0i9GQLW90x6o1/Ih2xaPagfrRmpQjR1ecbEFYxT34Lp5ZuC9x5Nm67RGb4JvvbMrz3qjR5YARKOiryJ5owrN3TUJmYp75xT7QBGkXBwhQJZwwBFhg5rKC5BJIj5x4PGJXrwHHuk6gpbLRbgoT69NmJYIkKZaPSIt+oOzVmgKBM5LTtI4JI8kPs2CHo2FwuYAnP9XAfGoTuB/Ir9ECkFoEQ== davidak" ];

  services.transmission = {
    enable = true;
    port = 8080;
    settings = {
      rpc-bind-address = "10.0.0.16";
      rpc-whitelist-enabled = true;
      rpc-whitelist = "10.*";
      rpc-enabled = true;
      rpc-username = "davidak";
      rpc-password = "{af2d8c743050f4e563046b35d79558ebb87e8f28Cc/6TW8U";
      download-dir = "/var/lib/transmission/downloads/";
      incomplete-dir = "/var/lib/transmission/.incomplete/";
      incomplete-dir-enabled = true;
      ratio-limit-enabled = true;
      ratio-limit = 2;
      peer-limit-global = 512;
      peer-limit-per-torrent = 128;
      port-forwarding-enabled = false;
      blocklist-enabled = true;
      blocklist-url = "http://john.bitsurge.net/public/biglist.p2p.gz";
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";
}
