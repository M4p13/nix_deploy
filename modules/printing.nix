{ config, pkgs, ... }:
let
  cupsPrinterDriver = pkgs.stdenv.mkDerivation {
    name = "cups-toshiba-tec";
    src = ../addons/toshiba-tec.deb; 
    nativeBuildInputs = [ pkgs.dpkg ];
    unpackPhase = ''
      dpkg-deb -x $src .
    '';
    installPhase = ''
      mkdir -p $out
      cp -r usr/* $out/
    '';
  };
in
{
  services.printing = {
    enable = true;
    drivers = [ cupsPrinterDriver ];
    webInterface = true;
    startWhenNeeded = false;
  };
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="08a6", ATTR{idProduct}=="b003", MODE="0666", GROUP="lp"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0664", GROUP="lp"
  '';
}
