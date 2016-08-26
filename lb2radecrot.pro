pro lb2radecrot, imdata, imhd, newdata, newhd, xc=xc, yc=yc, $
                 int=int, equinox=equinox

  ;; Convert Galactic to Celestial system and rotate.

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  if n_params() lt 4 then begin
     print, 'Syntax - lb2radecrot, imdata, imhd, newim, newhd, ' + $
            '[xc=xc, yc=yc, int=int, equinox=equinox]'
     return
  endif

  if ~keyword_set(equinox) then equinox=2000.0
  hd1=imhd
  sxaddpar, hd1, 'EQUINOX', equinox
  heuler, hd1, /celestial
  rot2radec, imdata, hd1, newdata, newhd, xc=xc, yc=yc, int=int
end
