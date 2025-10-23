{ config, pkgs, ... }:
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/host.nix
      ./modules/printing.nix
      ./networking.nix
    ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0; # dont show boot options
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "breeze";  # or "spinner", "script", "solar", etc.
  };
  time.timeZone = "Europe/Tallinn";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "et_EE.UTF-8";
    LC_IDENTIFICATION = "et_EE.UTF-8";
    LC_MEASUREMENT = "et_EE.UTF-8";
    LC_MONETARY = "et_EE.UTF-8";
    LC_NAME = "et_EE.UTF-8";
    LC_NUMERIC = "et_EE.UTF-8";
    LC_PAPER = "et_EE.UTF-8";
    LC_TELEPHONE = "et_EE.UTF-8";
    LC_TIME = "et_EE.UTF-8";
  };
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasmax11";
  services.desktopManager.plasma6.enableQt5Integration = true;
  services.xserver.xkb = {
    layout = "ee";
    variant = "";
  };
  console.keyMap = "et";
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  users.mutableUsers = false;
  users.users.kasutaja = {
    isNormalUser = true;
    description = "kasutaja";
    hashedPassword = "";
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "kasutaja";
  };
  users.users.gert = {
    isNormalUser = true;
    description = "gert";
    hashedPassword = "$y$j9T$OLvh8ErbyvQGkU/bhP7JJ.$tCYqHvdo6tDHFuVVV1VefeQkYYCtrxRY8BnLDviCt29";
    extraGroups = [ "networkmanager" "wheel" "lp" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
  users.users."gert".openssh.authorizedKeys.keys = [
    (builtins.readFile ./ssh-keys/gert.pub)
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim git chromium libreoffice usbutils libusb1 x11vnc wayvnc
  ];
    systemd.services.x11vnc = {
    description = "X11 VNC Server";
    after = [ "display-manager.service" "graphical.target" ];
    wantedBy = [ "graphical.target" ];
    
    path = with pkgs; [ gawk nettools xorg.xauth ];  # Add missing utilities
    
    serviceConfig = {
      Type = "simple";
      # Run as your user instead of root
      User = "kasutaja";  # or "gert" - whichever user runs the X session
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -auth guess -forever -shared -noxdamage -repeat -rfbport 5900";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.openFirewall = false;

  services.openssh = {
          enable = true;
          ports = [ 22 ];
          settings = {
                  PasswordAuthentication = false;
                  AllowUsers = ["gert"];
                          UseDns = true;
                  X11Forwarding = false;
                  PermitRootLogin = "no";
        };
  };

  security.sudo.wheelNeedsPassword = false;
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "25.05";
  # disable powermanagement
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";
}
