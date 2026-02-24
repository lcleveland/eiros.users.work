final: prev:
let
  lib = prev.lib;
in
{
  khal = prev.khal.overrideAttrs (old: {
    # Remove outputs that trigger Sphinx builds
    outputs = builtins.filter (
      o:
      !(builtins.elem o [
        "doc"
        "man"
      ])
    ) (old.outputs or [ "out" ]);

    # In case sphinxHook is what triggers the build phase, remove it if present
    nativeBuildInputs = lib.filter (
      x:
      let
        n = lib.getName x;
      in
      !(lib.hasPrefix "sphinx" n) && n != "sphinx-hook"
    ) (old.nativeBuildInputs or [ ]);

    doCheck = false;
    doInstallCheck = false;
  });
}
