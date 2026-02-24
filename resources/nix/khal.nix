# overlays/khal-no-docs.nix
final: prev: {
  khal = prev.khal.overrideAttrs (old: {
    # 🔑 Remove the doc output completely
    outputs = builtins.filter (o: o != "doc") (old.outputs or [ "out" ]);

    # Safety: ensure no doc phases run
    doCheck = false;
    doInstallCheck = false;
  });
}
