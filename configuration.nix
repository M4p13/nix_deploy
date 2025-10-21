{ config, pkgs, ... }:
{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/host.nix
      ./modules/printing.nix
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
    hashedPassword = "$y$j9T$iWI/Xzoi8ef7GD5SeUuZu.$zPR4fIftnM9s/PCTPhk9KjbTNCD.ciGwedSZ6AFhw1A";
  };
  users.users.gert = {
    isNormalUser = true;
    description = "gert";
    hashedPassword = null;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
  users.users."gert".openssh.authorizedKeys.keys = [
    (builtins.readFile ./ssh-keys/gert.pub)
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim git chromium x11vnc
  ];
  systemd.user.services.x11vnc = {
    description = "X11 VNC server";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -nopw -localhost -forever";
      Restart = "on-failure";
    };
  };
  systemd.user.targets.default.wants = [ "x11vnc.service" ];
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
