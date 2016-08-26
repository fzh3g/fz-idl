pro browsesub, array1d, range, x=x, position=position, thick=thick, $
               color=color, noerase=noerase, _extra=extra

  ;; Plot the whole 1D array and its subarray

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; check arguments and keywords
  if (n_params() lt 2) then begin
     print, 'Syntax - browsesub, array1d, range, [x=x, position=position,'
     print, '                                     thick=thick, color=color,'
     print, '                                     _extra=extra]'
     return
  endif

  if (size(array1d, /n_dimensions) ne 1) then begin
     message, 'ERROR - First argument must be an 1D array', /con
     return
  endif

  if ~keyword_set(x) then x = findgen(size(array1d, /dimensions))
  if ~keyword_set(position) then position=[0.1, 0.1, 0.9, 0.9]
  if ~keyword_set(thick) then thick=2.0
  if ~keyword_set(color) then color=cgcolor("red")

  ;; positions
  pos0 = [position[0], position[1], (position[2] - position[0]) * 0.45 + $
          position[0], position[3]]

  pos1 = [(position[2] - position[0]) * 0.55 + position[0], position[1], $
          position[2], position[3]]

  ;; subarray
  subarray1d = array1d[range[0]:range[1]]
  subx = x[range[0]:range[1]]

  ;; plot array1d
  cgplot, x, array1d, position=pos0, xstyle=1, ystyle=1, noerase=noerase, $
          _extra=extra
  xrange0 = !x.crange
  yrange0 = !y.crange

  ;; plot subarray1d
  cgplot, subx, subarray1d, position=pos1, /noerase, xstyle=1, ystyle=1, $
          _extra=extra
  xrange1 = !x.crange
  yrange1 = !y.crange

  ;; add box and lines
  cgplot, findgen(100), xstyle=12, ystyle=12, /nodata, /noerase, $
          position=position

  bx = (xrange1 - xrange0[0]) / (xrange0[1] - xrange0[0]) * $
       (pos0[2] - pos0[0]) / (position[2] - position[0]) * 100

  by = (yrange1 - yrange0[0]) / (yrange0[1] - yrange0[0]) * $
       (pos0[3] - pos0[1]) / (position[3] - position[1]) * 100

  x2 = (pos1[0] - pos0[0]) / (position[2] - position[0]) * 100

  cgoplot, [bx[0], bx[0]], by, thick=thick, color=color, /noerase, $
           xstyle=12, ystyle=12
  cgoplot, [bx[1], bx[1]], by, thick=thick, color=color, /noerase, $
           xstyle=12, ystyle=12
  cgoplot, bx, [by[0], by[0]], thick=thick, color=color, /noerase, $
           xstyle=12, ystyle=12
  cgoplot, bx, [by[1], by[1]], thick=thick, color=color, /noerase, $
           xstyle=12, ystyle=12
  cgoplot, [bx[1], x2], [by[0], 0], thick=thick, color=color, /noerase, $
           xstyle=12, ystyle=12
  cgoplot, [bx[1], x2], [by[1], 100], thick=thick, color=color, /noerase, $
           xstyle=12, ystyle=12

end
