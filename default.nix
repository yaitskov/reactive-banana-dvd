{ system ? builtins.currentSystem or "x86_64-linux"
, ghc ? "ghc9122"
}:

let
  nix = import ./nix;
  pkgs = nix.pkgSetForSystem system {
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
  };
  inherit (pkgs) lib;
  hsPkgSetOverlay = pkgs.callPackage ./nix/haskell/overlay.nix {
    inherit (nix) sources;
  };

  sources = [
    "^(trace-embrace.yaml|src|test).*$"
    "^changelog[.]md$"
    "^.*\\.cabal$"
  ];

  base = hsPkgs.callCabal2nix "dvd" (lib.sourceByRegex ./. sources) { };
  dvd-overlay = _hf: _hp: { dvd = base; };
  baseHaskellPkgs = pkgs.haskell.packages.${ghc};
  hsOverlays = [ hsPkgSetOverlay dvd-overlay ];
  hsPkgs = baseHaskellPkgs.override (old: {
    overrides =
      builtins.foldl' pkgs.lib.composeExtensions (old.overrides or (_: _: { }))
      hsOverlays;
  });

  hls = pkgs.haskell.lib.overrideCabal hsPkgs.haskell-language-server
    (_: { enableSharedExecutables = true; });

  shell = hsPkgs.shellFor {
    packages = p: [ p.dvd ];
    nativeBuildInputs = (with pkgs; [
      cabal-install
      ghcid
      hlint
      niv
      pandoc
    ]) ++ [ hls hsPkgs.upload-doc-to-hackage ];
    shellHook = ''
      export PS1='$ '
      echo $(dirname $(dirname $(which ghc)))/share/doc > .haddock-ref
    '';
  };

  dvd = hsPkgs.dvd;
in {
  inherit hsPkgs;
  inherit ghc;
  inherit pkgs;
  inherit shell;
  inherit dvd;
}
