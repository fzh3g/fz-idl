pro cutvelo, oldim, oldhd, newim, newhd, velo1, velo2

  ;; Clip a velocity range (v in km/s) in data according to fits header

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() ne 4) && (n_params() ne 6) then begin
     print, 'Syntax - cutvelo, oldim, oldhd, [newim, newhd,] velo1, velo2'
     return
  endif

  if (n_params() eq 4) then begin
     update = 1
     velo1 = newim & velo2 = newhd
  endif else update = 0

  ;; Sort velocities
  tmp = min([velo1, velo2])
  velo2 = max([velo1, velo2])
  velo1 = temporary(tmp)

  if sxpar(oldhd, 'CDELT3') lt 0 then begin
     if update then begin
        reversevelo, oldim, oldhd
     endif else begin
        reversevelo, oldim, oldhd, newim, newhd
     endelse
  endif else begin
     if ~update then begin
        newim = oldim
        newhd = oldhd
     endif
  endelse

  if update then begin
     newim = temporary(oldim)
     newhd = temporary(oldhd)
  endif

  naxis3 = sxpar(newhd, 'NAXIS3')
  crval3 = sxpar(newhd, 'CRVAL3')
  crpix3 = sxpar(newhd, 'CRPIX3')
  cdelt3 = sxpar(newhd, 'CDELT3')

  veloslices = ([velo1, velo2] * 1000d - crval3) / cdelt3 + crpix3 - 1
  veloslices = veloslices[sort(veloslices)]
  veloslices = [floor(veloslices[0]), ceil(veloslices[1])]

  if (veloslices[0] gt naxis3) or (veloslices[1] lt 0) then begin
     message, 'ERROR - Velocity out of range.', /con
     return
  endif

  veloslices = veloslices > 0 < naxis3
  newim = newim[*, *, veloslices[0]:veloslices[1]]
  sxaddpar, newhd, 'NAXIS3', veloslices[1] - veloslices[0] + 1
  sxaddpar, newhd, 'CRPIX3', crpix3 - veloslices[0]
  message, /inf, 'Cut velocity from ' + strtrim(velo1, 2) + ' km/s to ' + $
           strtrim(velo2, 2) + ' km/s.'
  sxaddhist, 'CUTVELO: ' + systime() + ' Velocity clipped from ' + $
             strtrim(velo1, 2) + ' km/s to ' + strtrim(velo2, 2) + $
             ' km/s', newhd

  if update then begin
     oldim = temporary(newim) & oldhd = temporary(newhd)
     newim = velo1 & newhd = velo2
  endif

end
