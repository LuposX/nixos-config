# Enable Wake-on-LAN (magic packet) on the wired NIC.
# Requires "PCIE Devices Power On" enabled in the ASRock UEFI
# (Advanced -> ACPI Configuration). Note: a BIOS update can reset it.
# Also make sure ErP / Deep Sx are disabled in UEFI if present,
# otherwise the NIC loses power when the PC is off.
{
  lib,
  ...
}: {
  networking.interfaces.enp129s0.wakeOnLan.enable = true;
}
