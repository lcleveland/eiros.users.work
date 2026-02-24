final: prev:
let
  lib = prev.lib;

  # Remove anything whose pname contains "sphinx"
  dropSphinx =
    xs:
    lib.filter (
      x:
      let
        n = lib.getName x;
      in
      !(lib.hasInfix "sphinx" (lib.toLower n))
    ) xs;

  # Remove explicit sphinx phases if they were injected
  dropSphinxPhases =
    phases:
    lib.filter (
      p: !(lib.hasInfix "Sphinx" p) && p != "buildSphinxPhase" && p != "installSphinxPhase"
    ) phases;

in
{
  khal = prev.khal.overrideAttrs (old: {
    # Keep only outputs we actually need
    outputs = builtins.filter (
      o:
      !(builtins.elem o [
        "doc"
        "man"
      ])
    ) (old.outputs or [ "out" ]);

    # Strip sphinx from every common input bucket
    nativeBuildInputs = dropSphinx (old.nativeBuildInputs or [ ]);
    buildInputs = dropSphinx (old.buildInputs or [ ]);
    propagatedBuildInputs = dropSphinx (old.propagatedBuildInputs or [ ]);
    nativeCheckInputs = dropSphinx (old.nativeCheckInputs or [ ]);
    checkInputs = dropSphinx (old.checkInputs or [ ]);

    # If phases were explicitly set, remove sphinx phases
    phases = if old ? phases then dropSphinxPhases old.phases else null;

    doCheck = false;
    doInstallCheck = false;
  });
}
