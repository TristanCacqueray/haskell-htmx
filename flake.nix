{
  nixConfig.bash-prompt = "[nix(haskell-htmx)] ";
  inputs = {
    hspkgs.url =
      "github:podenv/hspkgs/fe0dabfd8acf96f1b5cff55766de6284517868cf";
    # "path:///srv/github.com/podenv/hspkgs";

  };
  outputs = { self, hspkgs }:
    let
      pkgs = hspkgs.pkgs;

      haskellExtend = hpFinal: hpPrev: {
        haskell-htmx = hpPrev.callCabal2nix "haskell-htmx" self { };

      };
      hsPkgs = pkgs.hspkgs.extend haskellExtend;

      baseTools = with pkgs; [ cabal-install hsPkgs.cabal-fmt hlint fourmolu ];
      exe = pkgs.haskell.lib.justStaticExecutables hsPkgs.haskell-htmx;
    in {
      packages."x86_64-linux".default = exe;
      devShell."x86_64-linux" = hsPkgs.shellFor {
        packages = p: [ p.haskell-htmx ];
        buildInputs = with pkgs; [ ghcid haskell-language-server ] ++ baseTools;

      };

    };

}
