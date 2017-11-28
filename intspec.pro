pro intspec, imdata, imhd, imnew, hdnew, vrange

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  cutvelo, imdata, imhd, vrange[0], vrange[1]

  naxis1 = sxpar(imhd, 'naxis1')
  naxis2 = sxpar(imhd, 'naxis2')
  cdelt3 = sxpar(imhd, 'cdelt3')

  hdnew = imhd
  sxaddpar, hdnew, 'naxis', 2
  sxaddpar, hdnew, 'bunit', 'K km/s'

  imnew = make_array(naxis1, naxis2, /double, value=0)
  help, imnew

  help, naxis1
  help, naxis2
  help, cdelt3

  for i = 0, naxis1 - 1 do begin
     for j = 0, naxis2 - 1 do begin
        imnew[i, j] = total(imdata[i, j, *]) * cdelt3 / 1000
     endfor
  endfor

  sxaddhist, 'INTSPEC: ' + systime() + ' [' + strtrim(vrange[0], 2) + ', ' + $
             strtrim(vrange[1], 2) + ']', hdnew

end
