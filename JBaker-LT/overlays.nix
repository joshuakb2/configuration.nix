let
  vesktop = final: prev: {
    vesktop = prev.vesktop.overrideAttrs (finalAttrs: prevAttrs: {
      postFixup = prevAttrs.postFixup + ''
        wrapProgram $out/bin/vesktop \
          --add-flags --disable-gpu
      '';
    });
  };

in
{
  nixpkgs.overlays = [ vesktop ];
}
