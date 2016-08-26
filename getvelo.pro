function getvelo, imhd

  ;; Get velocity array of data cube in km/s from fits header

  ;; Return to caller
  on_error, 2

  ;; Check parameters
  if (n_params() ne 1) then begin
     print, 'Syntax - Result = getvelo(imhd)'
     return, 0
  endif

  ;; Get information from fits header
  naxis3 = sxpar(imhd, 'NAXIS3')
  crval3 = sxpar(imhd, 'CRVAL3')
  crpix3 = sxpar(imhd, 'CRPIX3')
  cdelt3 = sxpar(imhd, 'CDELT3')

  ;; Generate velocity array
  velocity = dblarr(naxis3)

  ;; Calculate velocity
  for i = 0, naxis3 - 1 do begin
     velocity[i] = 0.001d * ((i + 1 - crpix3) * cdelt3 + crval3)
  endfor

  ;; Return velocity
  return, velocity

end
