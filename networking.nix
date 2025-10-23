{ config, pkgs, ... }:
{
  networking.networkmanager = {
    enabled = true;
    ensureProfiles = {
      environmentFiles = [ /etc/nixos/wifi.env ];
      profiles = {
        w1 = {
          connection = {
            id = "$W1_WIFI_NAME";
            type = "wifi";
          };
          wifi = {
            ssid = "$W1_WIFI_SSID";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$W1_WIFI_PASSWORD";
          };
        };
      };
    };
  };
}
