{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.nvix.packages.${pkgs.system}.full
  ];
}
