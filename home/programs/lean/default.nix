# Lean 4 + mathlib development setup.
#
# elan manages per-project toolchains: mathlib pins its own Lean version,
# so elan downloads it automatically when entering a project
# (the version is declared in the project's lean-toolchain file).
{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    elan
  ];

  # VS Code lean4 extension finds lean/lake through elan's proxies in PATH.
  # Nothing else to configure; projects are created with:
  #   lake +mathlib new myproject
  #   cd myproject && lake exe cache get
}