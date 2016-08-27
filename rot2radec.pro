pro rot2radec, oldim, oldhd, newim, newhd, xc=xc, yc=yc, int=int

  ;; Rotate 2D or 3D image to align with Ra / Dec coordinates

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters and keywords
  if (n_params() ne 4) && (n_params() ne 2) then begin
     print, 'Syntax, oldim, oldhd, [newim, newhd, xc=xc, yc=yc, int=int]'
     return
  endif

  if (n_params() eq 2) then update = 1 else update = 0

  if n_elements(xc) eq 0 then xc = -1
  if n_elements(yc) eq 0 then yc = -1
  if n_elements(int) eq 0 then int = 1

  ;; Number of dimensions
  naxis = sxpar(oldhd, 'naxis')
  if (naxis ne 2) && (naxis ne 3) then begin
     message, 'ERROR - Input image array must be 2D or 3D.', /con
     return
  endif

  ;; Calculate angle to rotate
  naxis1 = sxpar(oldhd, 'naxis1')

  xyad, oldhd, 0, 0, ra0, dec0
  xyad, oldhd, 0, naxis1 - 1, ra1, dec1
  rotangle = -180.0d * atan(ra1 - ra0, dec1 - dec0) / !dpi

  ;; Rotate using HROT
  if (naxis eq 2) then begin
     hrot, oldim, oldhd, newim, newhd, rotangle, xc, yc, int, $
           missing=!values.d_nan
  endif else begin
     naxis2 = sxpar(oldhd, 'naxis2')
     naxis3 = sxpar(oldhd, 'naxis3')

     oldhd2d = oldhd
     sxaddpar, oldhd2d, 'naxis', 2
     sxdelpar, oldhd2d, 'naxis3'

     newim = make_array(naxis1, naxis2, naxis3, /double, value=0)

     for i = 0, naxis3 - 1 do begin
        oldimi = oldim[*, *, i]
        hrot, oldimi, oldhd2d, newimi, newhd2d, rotangle, xc, yc, int, $
              missing=!values.d_nan
        newim[*, *, i] = newimi
     endfor

     newhd = newhd2d
     sxaddpar, newhd, 'naxis', 3
     sxaddpar, newhd, 'naxis3', naxis3
  endelse

  ;; Update old image array and header if needed
  if update then begin
     oldim = temporary(newim)
     oldhd = temporary(newhd)
  endif

end
