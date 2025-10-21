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
  };
}
