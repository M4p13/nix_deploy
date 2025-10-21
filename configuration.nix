{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.
  networking.hostName = "nixos-1";
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
    neovim
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
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBcWd2YSlRNey8/5y+Fp351c2p/km77PyTEIFHg2HwJyU0ln9Tl7StnSevKZNWITvTEyDkB1dz23KCGN/M/9dGl6duxw4+fLq6clhQSGFAIsiN7AcvBwv85Lgv0PJx2FgyHUfmFyIFG0e4qd9CvsV04bkagUDntcfBMgt0gyy3VH2Xcq7Aqp0RIgcb7e4MF/oLJJ1j9t5TDBQ8FbzfJc0HRuRjfoGTgX52rcle99Wxv5iPBvF7EZfwmdjoilJwqh/vyaZfiff2MAkGIilrOzwiZnXw7mKqdDiuKEIjh6NYem3aiMSfZgPbYhO3BG7peIoaOVGYgh3bcn07TvBG6g8axakVXwbFhmv5zpqBXQ8bykGMS0+6U8Azt6aQ/5Yo2N7lnWxQ06JsgmG7Q1nBxSJUAnoqZVTsI5KUSHUPryb0G7kcHi4NF+fhA4Ob72omVRODUN+nQg6O2GeUY6ch1HSAilKzaJb6zGbza3ftur3PK81ouQGCSDat3DTanN9z02M= Admin@DESKTOP-GML1E2U"
  ];
  networking.firewall.allowedTCPPorts = [ 22 ];
  system.stateVersion = "25.05";
  # disable powermanagement
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}

