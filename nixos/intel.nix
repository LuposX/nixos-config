{ pkgs, ...} :
{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
    ];
   };
}
