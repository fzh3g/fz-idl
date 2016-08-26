pro hextract3, oldim, oldhd, newim, newhd, x1, x2, y1, y2, silent=silent, $
               _extra=extra_keywords

  ;; Extract a subimage from an 3D array and update astrometry in FITS header

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() ne 6) && (n_params() ne 8) then begin
     print, 'Syntax - hextract3, oldim, oldhd, [newim, newhd,] x1, x2, y1, y2'
     return
  endif

  if (n_params() eq 6) then begin
     y1 = x1 & y2 = x2
     x1 = newim & x2 = newhd
     update = 1
  endif else update = 0

  naxis = sxpar(oldhd, 'naxis')
  if (naxis ne 3) then begin
     message, 'ERROR - Input image array must be 3D', /con
     return
  endif

  ;; Array dimensions
  naxis1 = sxpar(oldhd, 'naxis1')
  naxis2 = sxpar(oldhd, 'naxis2')
  naxis3 = sxpar(oldhd, 'naxis3')

  ;; Sort x and y
  x = round([x1, x2])
  y = round([y1, y2])
  x = x[sort(x)]
  y = y[sort(y)]

  ;; 2D header
  imhd2d = oldhd
  sxaddpar, imhd2d, 'naxis', 2
  sxdelpar, imhd2d, 'naxis3'

  ;; New array
  newim = make_array(x[1] - x[0] + 1, y[1] - y[0] + 1, naxis3, /double, $
                     value=0)

  ;; Message
  if ~keyword_set(silent) then begin
     message, /inf, 'Now extracting a ' + strtrim(x[1] - x[0] + 1, 2) + $
              ' by ' + strtrim(y[1] - y[0] + 1, 2) + ' by ' + $
              strtrim(naxis3, 2) + ' subarray'
  endif

  ;; Extract subarray
  for i = 0, naxis3 - 1 do begin
     imdatai = oldim[*, *, i]
     hextract, imdatai, imhd2d, newim2d, newhd2d, x[0], x[1], y[0], y[1], $
               /silent, _extra=extra_keywords
     newim[*, *, i] = newim2d
  endfor

  ;; New 3D header
  newhd = temporary(newhd2d)
  sxaddpar, newhd, 'naxis', 3
  sxaddpar, newhd, 'naxis3', naxis3

  ;; Parameters
  if update then begin
     oldim = temporary(newim) & oldhd = temporary(newhd)
     newim = x1 & newhd = x2
     x1 = temporary(y1) & x2 = temporary(y2)
  endif
end
