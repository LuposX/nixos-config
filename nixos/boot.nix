{ pkgs, ... }: {
  boot = {
    # Makes boot entries (in /efi/loader/entries/) structured and discoverable by other tools.
    bootspec.enable = true;
    loader = {
      # Allows NixOS to write directly to EFI variables in your motherboard's NVRAM.
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # Controls the resolution of the bootloader console.
        consoleMode = "auto";
        # Keeps only the 10 most recent boot configurations.
        configurationLimit = 10;
      };
    };
    # Cleans /tmp at boot.
    tmp.cleanOnBoot = true;
    # Uses the most recent mainline Linux kernel.
    # Alternatives: _zen, _hardened, _rt, _rt_latest, etc.
    # kernelPackages = pkgs.linuxPackages_latest; # Kernel 6.15 has currently a nvidia bug.
    # kernelPackages = pkgs.linuxPackages_6_14;

    # Silent boot
    kernelParams = [
      "quiet"
      "splash"
      "vga=current"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Shows only emergency messages when booting;
    consoleLogLevel = 0;
    # No logs during early boot.
    initrd.verbose = false;
  };
}
