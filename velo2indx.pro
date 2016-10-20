pro velo2indx, imhd, velocity, index

  ;; Get the index(indecis) of given velocity(velocities) in km/s from
  ;; the fits header

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if n_params() ne 3 then begin
     print, 'Syntax - velo2indx, imhd, velocity, index'
     return
  endif

  ;; Get information from fits header
  crval3 = sxpar(imhd, 'CRVAL3')
  crpix3 = sxpar(imhd, 'CRPIX3')
  cdelt3 = sxpar(imhd, 'CDELT3')

  ;; Calculate the index
  index = (1000d * velocity - crval3) / cdelt3 + crpix3 - 1

end
