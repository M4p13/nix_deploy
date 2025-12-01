{ config, pkgs, lib, ... }:
let
  cupsPrinterDriver = pkgs.stdenv.mkDerivation {
    name = "cups-toshiba-tec";
    src = ../addons/toshiba-tec.deb; 
    
    nativeBuildInputs = [ 
      pkgs.dpkg 
      pkgs.autoPatchelfHook
    ];
    
    buildInputs = with pkgs; [
      cups
      libusb1          # <-- This is the missing dependency!
      stdenv.cc.cc.lib
      glibc
    ];
    
    unpackPhase = ''
      dpkg-deb -x $src .
    '';
    
    installPhase = ''
      mkdir -p $out
      cp -r usr/* $out/
      
      # Make backends executable
      if [ -d $out/lib/cups/backend ]; then
        chmod +x $out/lib/cups/backend/*
      fi
      
      # Make filters executable  
      if [ -d $out/lib/cups/filter ]; then
        chmod +x $out/lib/cups/filter/*
      fi
    '';
  };
in
{
  services.printing = {
    enable = true;
    browsing = false;
    drivers = [
      cupsPrinterDriver
      pkgs.cups-filters
      (pkgs.writeTextDir "share/cups/model/cabsquix6p300.ppd" (builtins.readFile ../addons/cabsquix6p300.ppd))
    ];
    webInterface = true;
    logLevel = "debug";
    startWhenNeeded = false;
    extraConf = ''
    <Limit Pause-Printer Resume-Printer Enable-Printer Disable-Printer>
    AuthType None
    Order deny,allow
    Allow from all
    </Limit>
    '';
  };
  services.colord.enable = true;
  services.printing.browsed.enable = false;
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="08a6", ATTR{idProduct}=="b003", MODE="0666", GROUP="lp"
  '';
    security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.opensuse.cupspkhelper.mechanism.printer-enable") {
            return polkit.Result.YES;
        }
    });
  '';
}
