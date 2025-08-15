{ haskell, lib, sources }:
let
  inherit (haskell.lib) dontCheck  overrideCabal;
  inherit (lib) fakeSha256 nameValuePair listToAttrs;
in hfinal: hprev:
(listToAttrs (map (a:
  nameValuePair a.name
    (dontCheck (hfinal.callCabal2nix a.name a.source { }))) [
      ## { name = "reactive-banana"; source = sources.reactive-banana + "/reactive-banana"; }
      { name = "pqueue"; source = sources.pqueue; }
    ])) // {
      "upload-doc-to-hackage" = hfinal.callPackage sources.upload-doc-to-hackage {};
      "th-utilities" = hfinal.callHackageDirect
        { pkg = "th-utilities";
          ver = "0.2.5.2";
          sha256 = "sha256-IEl2Uzsv/fr+546jCIDqUvcRZA/QRm6Xe0cmahMdcnA=";
        } {};
      "th-lock" = hfinal.callHackageDirect
        { pkg = "th-lock";
          ver = "0.0.4";
          sha256 = "sha256-chFv77J0oWLzf4zAX4Awv7uhQEhiPegvPgrLWNaEuhs=";
        } {};

      "haddock-use-refs" = hfinal.callHackageDirect
        { pkg = "haddock-use-refs";
          ver = "1.0.1";
          sha256 = "sha256-fxrfMQ4CUthzNwYVjwV5kJmmPgimVpbnVhxnoYi1GrE=";
        } {};

      "trace-embrace" = hfinal.callHackageDirect
        { pkg = "trace-embrace";
          ver = "1.2.0";
          sha256 = "sha256-O3865lJryaDfDM4NQVHNu45DI/vNxofY4/+RVcnJlPg=";
        } {};
    }
