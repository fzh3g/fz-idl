pro cutradec, oldim, oldhd, newim, newhd, ra1, ra2, dec1, dec2, $
              _extra=extra_keywords, get_x=get_x, get_y=get_y

  ;; Cut a region of fits image by ra/dec.

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() lt 6) || (n_params() eq 7) then begin
     print, 'Syntax - cubecutradec, oldim, oldhd, [newim, newhd,] '
     print, '         x0, x1, y0, y1, [_extra=extra_keywords, '
     print, '         get_x=get_x, get_y=get_y]'
     return
  endif

  if (n_params() eq 6) then begin
     update = 1
     dec1 = ra1 & dec2 = ra2
     ra1 = newim & ra2 = newhd
  endif else update = 0

  ;; Check fits
  check_fits, oldim, oldhd, dimen, /notype

  ;; Number of dimensions
  ndimen = n_elements(dimen)

  if (ndimen ne 2) && (ndimen ne 3) then begin
     print, 'Input image array must be 2D or 3D.'
     return
  endif

  ;; Convert ra/dec to pixel index
  adxy, oldhd, ra1, dec1, x1, y1
  adxy, oldhd, ra2, dec2, x2, y2

  ;; Sort
  x = round([x1, x2])
  y = round([y1, y2])
  x = x[sort(x)]
  y = y[sort(y)]

  ;; Do not go out of range
  x = x > 0 < dimen[0] - 1
  y = y > 0 < dimen[1] - 1

  ;; For output
  get_x = x
  get_y = y

  ;; Message
  message, /inf, 'Cutting data by ra / dec using HEXTRACT ...'
  message, /inf, 'X range: [' + strtrim(x[0], 2) + ', ' + strtrim(x[1], 2) + $
           ']' + ', ' + 'Y range: [' + strtrim(y[0], 2) + ', ' + $
           strtrim(y[1], 2) + ']'

  ;; Cut using HEXTRACT
  if ndimen eq 2 then begin
     if update then begin
        hextract, oldim, oldhd, x[0], x[1], y[0], y[1], /silent, $
                  _extra=extra_keywords
     endif else begin
        hextract, oldim, oldhd, newim, newhd, x[0], x[1], y[0], y[1], /silent, $
                  _extra=extra_keywords
     endelse
  endif else begin
     if update then begin
        hextract3, oldim, oldhd, x[0], x[1], y[0], y[1], /silent, $
                   _extra=extra_keywords
     endif else begin
        hextract3, oldim, oldhd, newim, newhd, x[0], x[1], y[0], y[1], $
                   /silent, _extra=extra_keywords
     endelse
  endelse

  ;; Parameters
  if update then begin
     newim = ra1 & newhd = ra2
     ra1 = dec1 & ra2 = dec2
  endif

end
