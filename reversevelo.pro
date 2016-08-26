pro reversevelo, imdata, imhd, newdata, newhd

  ;; reverse the velocity of 3D data cube

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() ne 2) && (n_params() ne 4) then begin
     print, 'Syntax - reversevelo, imdata, imhd, [newdata, newhd]'
     return
  endif

  if (n_params() eq 2) then update = 1 else update = 0

  naxis3 = sxpar(imhd, 'naxis3')
  crpix3 = sxpar(imhd, 'crpix3')
  cdelt3 = sxpar(imhd, 'cdelt3')

  if update then begin
     imdata = reverse(temporary(imdata), 3)
  endif else begin
     newdata = reverse(imdata, 3)
  endelse

  newhd = imhd
  sxaddpar, newhd, 'crpix3', naxis3 - crpix3 + 1
  sxaddpar, newhd, 'cdelt3', -cdelt3

  message, /inf, 'Reverse the velocity axis of 3D data cube.'
  get_date, dte, /timetag
  sxaddhist, 'CUBEREVERSEVELO: ' + dte, newhd

  if update then imhd = temporary(newhd)
end
