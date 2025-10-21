{ config, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      /etc/nixos/host.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;

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
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "ee";
    variant = "";
  };

  console.keyMap = "et";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.gert = {
    isNormalUser = true;
    description = "gert";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim git
  ];
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
  users.users."gert".openssh.authorizedKeys.keys = [
    (builtins.readFile ./ssh-keys/gert.pub)
  ];
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "25.05";
  # disable powermanagement
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}

