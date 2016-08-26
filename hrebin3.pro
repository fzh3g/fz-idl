pro hrebin3, oldim, oldhd, newim, newhd, outsize

  ;; Rebin 3D data cube using HREBIN

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() ne 5) && (n_params() ne 3) then begin
     print, 'Syntax - hrebin3, oldim, oldhd, [newim, newhd,] outsize'
     return
  endif

  if (n_params() eq 3) then begin
     update = 1
     outsize = newim
  endif else update = 0

  naxis = sxpar(oldhd, 'naxis')

  if naxis ne 3 then begin
     message, 'ERROR - Input data must be 3D', /con
     return
  endif else begin
     message, /inf, 'Rebinning data cube ...'
     naxis3 = sxpar(oldhd, 'naxis3')

     oldhd2d = oldhd
     sxaddpar, oldhd2d, 'naxis', 2
     sxdelpar, oldhd2d, 'naxis3'

     newim1 = make_array(outsize[0], outsize[1], naxis3, /double, $
                        value=0)

     for i = 0, naxis3 - 1 do begin
        newimi = oldim[*, *, i]
        hrebin, newimi, oldhd2d, newim2d, newhd2d, outsize=outsize
        newim1[*, *, i] = newim2d
     endfor

     newhd = temporary(newhd2d)
     sxaddpar, newhd, 'naxis', 3
     sxaddpar, newhd, 'naxis3', naxis3
  endelse

  if update then begin
     oldim = temporary(newim1)
     oldhd = temporary(newhd)
  endif

end
