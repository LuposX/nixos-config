{ lib, pkgs, config, ... }:

let
  # GTX 1050 Ti uses Maxwell architecture, only supported up to 580.xx
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.legacy_580;
in {
  # Video drivers configuration for Xorg and Wayland
  services.xserver.videoDrivers =
    [ "modesetting" "nvidia" ]; # Simplified - other modules are loaded automatically

  # Kernel parameters for better Wayland and Hyprland integration
  boot.kernelParams = [
    "nvidia-drm.modeset=1" # Enable mode setting for Wayland
  ];

  # Blacklist nouveau to avoid conflicts
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Environment variables for better compatibility
  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";

    # Let Wayland auto-detect GPU correctly
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Configuration for proprietary packages
  nixpkgs.config = {
    nvidia.acceptLicense = true;
    allowUnfree = true;
  };

  # Nvidia configuration
  hardware = {
    nvidia = {
      package = nvidiaDriverChannel;
      open = false; # Proprietary driver for better performance
      nvidiaSettings = true; # Nvidia settings utility
      powerManagement = {
        enable = true; # Power management
        finegrained = false; # More precise power consumption control
      };
      modesetting.enable = true; # Required for Wayland
        # sync.enable = true;
    };

    # Enhanced graphics support
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        mesa
        egl-wayland
        vulkan-loader
        vulkan-validation-layers
        libva
      ];
    };
  };

  # Nix cache for CUDA
  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  # Additional useful packages
  environment.systemPackages = with pkgs; [
    vulkan-tools
    libva-utils # VA-API debugging tools
  ];
}
