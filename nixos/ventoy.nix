{pkgs, ...}: {
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.05"
    "ventoy-qt5-1.1.05"
  ];

  environment.systemPackages = with pkgs; [
    (ventoy.override {
      defaultGuiType = "qt5";
      withQt5 = true;
    })
  ];
}
