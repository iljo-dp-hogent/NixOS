{ config, lib, pkgs, ... }:
{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"]; # or "nvidiaLegacy470 etc.

  environment.systemPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
    nvidia-vaapi-driver
  ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;
    open = false;
    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  	hardware.nvidia.prime = {
	    sync.enable = true;
	#		offload = {
	#	enable = true;
	#	enableOffloadCmd = true;
	#};
		# Make sure to use the correct Bus ID values for your system!
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:1:0:0";
	};
}
