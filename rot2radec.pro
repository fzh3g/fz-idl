pro rot2radec, oldim, oldhd, newim, newhd, xc=xc, yc=yc, int=int

  ;; Rotate 2D or 3D image to align with Ra / Dec coordinates

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() lt 4) then begin
     print, 'Syntax, oldim, oldhd, newim, newhd, [xc=xc, yc=yc, int=int]'
     return
  endif

  if n_elements(xc) eq 0 then xc=-1
  if n_elements(yc) eq 0 then yc=-1
  if n_elements(int) eq 0 then int=1

  naxis = sxpar(oldhd, 'naxis')
  naxis1 = sxpar(oldhd, 'naxis1')

  xyad, oldhd, 0, 0, ra0, dec0
  xyad, oldhd, 0, naxis1 - 1, ra1, dec1
  rotangle = -180.0d * atan(ra1 - ra0, dec1 - dec0) / !dpi

  if (naxis eq 3) then begin
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
  endif else begin
     if (naxis eq 2) then begin
        hrot, oldim, oldhd, newim, newhd, rotangle, xc, yc, int, $
              missing=!values.d_nan
     endif else begin
        message, 'ERROR - Input image array must be 2 or 3-dimensional', /con
     endelse
  endelse
end
