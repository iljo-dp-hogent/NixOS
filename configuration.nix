# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
    ];
  nix = {
    # use unstable nix so we can access flakes
  #  package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # public binary cache that I use for all my derivations. You can keep
    # this, use your own, or toss it. Its typically safe to use a binary cache
    # since the data inside is checksummed.
    settings = {
      substituters = ["https://mitchellh-nixos-config.cachix.org"];
      trusted-public-keys = ["mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="];
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowAliases = false;
      permittedInsecurePackages = [
                      "electron-25.9.0"
      ];
      packageOverrides = pkgs: {
        intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
    };
  };
nixpkgs.overlays = [
  (final: prev: {
    gnome = prev.gnome.overrideScope' (gnomeFinal: gnomePrev: {
      mutter = gnomePrev.mutter.overrideAttrs ( old: {
        src = pkgs.fetchgit {
          url = "https://gitlab.gnome.org/vanvugt/mutter.git";
          # GNOME 45: triple-buffering-v4-45
          rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
          sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
        };
      } );
    });
  })
];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "G16"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  #NVIM STYLE
  environment.shellInit = ''
    if [ ! -d ~/.config/nvim.bak ]; then
      # Clone the GitHub repository into ~/.config/nvim.bak
      git clone https://github.com/theprimeagen/neovimrc ~/.config/nvim.bak
    fi
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.35
  '';
  # Configure keymap in X11
  services.xserver = {
    layout = "be";
    xkbVariant = "oss_latin9";
  };

  # Configure console keymap
  console.keyMap = "be-latin1";
 # consoleFont = "berkeley-mono";
 # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iljo = {
    isNormalUser = true;
    description = "iljo";
    extraGroups = [ "networkmanager" "wheel" "video" "disk" "qemu" ];
    packages = with pkgs; [
      floorp
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "iljo";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
	neovim
	curl
	kitty
	obsidian
	vesktop
	git
	neofetch
	gcc
	gnumake
	ripgrep
	steam
	steam-run
	alejandra
	rofi
	zoxide
	ffmpeg
	mpv
	unzip
	fzf
	jetbrains.idea-ultimate
	fish
	powertop
	tmux
	acpi
	nvtop
	eza
	mesa
	vscode
	fontconfig
	btop
	
  ];

 # fonts
programs.steam.enable = true;

fonts.packages = with pkgs; [
	noto-fonts
        dejavu_fonts
        iosevka-bin
#	noto-fonts-cjk
	#noto-fonts-emoji
	liberation_ttf
	font-awesome
	jetbrains-mono
	material-icons
        material-design-icons
        roboto
        work-sans
        comic-neue
        source-sans
]; 

#    fontconfig = {
#      defaultFonts = {
#        monospace = [
#          "Berkeley Mono"
#	  "Jetbrains Mono"
#          "Iosevka Term Nerd Font Complete Mono"
#          "Iosevka Nerd Font"
#          "Noto Color Emoji"
#        ];
#        sansSerif = ["Lexend" "Noto Color Emoji"];
#        serif = ["Noto Serif" "Noto Color Emoji"];
#        emoji = ["Noto Color Emoji"];
#      };
#    };

environment.gnome.excludePackages = with pkgs.gnome; [
    baobab      # disk usage analyzer
    cheese      # photo booth
    epiphany    # web browser
    #gedit       # text editor
    #gnome-tour
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer
    evince      # document viewer
    geary       # email client
    seahorse    # password manager

    # these should be self explanatory
    gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    gnome-maps gnome-music gnome-weather
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "nvidia"; }; # Force intel-media-driver
  # List services that you want to enable:
powerManagement.powertop.enable = true;
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
# Edit this configuration file to define what should be installed on

# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
#    enableAllFirmware = true;
    bluetooth.enable = false;
  };

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

   nix = {
     gc = {
       automatic = true;
       dates = "weekly";
       options = "--delete-older-than 10d";
     };
     autoOptimiseStore= true;
     optimise = {
       automatic = true;
       dates = [ "weekly" ];
     };
   };

}


