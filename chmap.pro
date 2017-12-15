pro chmap, imdata, imhd, imdatac, imhdc, dims=dims, vinit=vinit, $
           dvindx=dvindx, levels=levels, xgap=xgap, ygap=ygap, pos=pos, $
           cbpos=cbpos, charsize=charsize, drange=drange, xdelta=xdelta, $
           ydelta=ydelta, xtitle=xtitle, ytitle=ytitle, nocont=nocont, $
           noerase=noerase

  ;; Plot radio channel maps

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  if n_params() lt 4 then begin
     print, 'Syntax - chmap, imdata, imhd, imdatac, imhdc, [dims=dims,'
     print, '         vinit=vinit, dvindx=dvindx, levels=levels, xgap=xgap,'
     print, '         ygap=ygap, pos=pos, cbpos=cbpos, charsize=charsize,'
     print, '         drange=drange, xdelta=xdelta, ydelta=ydelta,'
     print, '         xtitle=xtitle, ytitle=ytitle, nocont=nocont]'
     return
  endif

  ;; Column number and line number of channel maps
  if ~keyword_set(dims) then dims = [3, 4]

  ;; Number of channels
  nchannel = fix(dims[1]) * fix(dims[0])

  ;; Spacing of velocity indecis
  if ~keyword_set(dvindx) then dvindx = 1

  ;; Velocity array
  velo = getvelo(imhd)

  ;; Initial index number of velocity
  if ~keyword_set(vinit) then begin
     vindx = 0
  endif else begin
     velo2indx, imhd, vinit, vindx
     vindx = round(vindx)
  endelse

  ;; Slicing data cube and velocity array
  data = imdata[*, *, vindx : (vindx + (nchannel - 1) * dvindx) : dvindx]
  velo = velo[vindx : (vindx + (nchannel - 1) * dvindx) : dvindx]

  ;; Contour levels
  if ~keyword_set(levels) then levels = [23, 27, 31, 35, 39, 43]

  ;; Position
  if ~keyword_set(pos) then pos = [0.10, 0.09, 0.88, 0.95]

  ;; Colorbar position
  if ~keyword_set(cbpos) then cbpos = [0.91, 0.2, 0.94, 0.85]

  ;; Charsize of axis labels
  if ~keyword_set(charsize) then charsize = 0.8

  ;; Gaps between subplots in X direction
  if ~keyword_set(xgap) then xgap = 0.02

  ;; Gaps between subplots in Y direction
  if ~keyword_set(ygap) then ygap = 0.04

  ;; Some parameters of imcontour
  if ~keyword_set(xdelta) then xdelta = 3
  if ~keyword_set(ydelta) then ydelta = 2
  if ~keyword_set(xtitle) then xtitle = 'RA (J2000)'
  if ~keyword_set(ytitle) then ytitle = 'Dec (J2000)'

  ;; Specific value range of data
  if keyword_set(drange) then begin
     data = data > min(drange) < max(drange)
  endif else begin
     data = data > 0
  endelse

  ;; Erase or not
  if ~keyword_set(noerase) then cgerase

  ;; Max and min values of data
  dmax = max(data)
  dmin = min(data)

  ;; Byte scale
  data = bytscl(data)

  ;; Normalized size of subplots
  dpx = (pos[2] - pos[0] - (dims[1] - 1) * xgap) / dims[1]
  dpy = (pos[3] - pos[1] - (dims[0] - 1) * ygap) / dims[0]

  ;; Load color table
  cgloadct, 3, /reverse

  ;; Position
  position = fltarr(4)

  ;; Plot
  for i = 0, dims[0] - 1 do begin    ;i for line
     for j = 0, dims[1] - 1 do begin ;j for column
        position[0] = pos[0] + (dpx + xgap) * j
        position[1] = pos[1] + (dpy + ygap) * (dims[0] - i - 1)
        position[2] = position[0] + dpx
        position[3] = position[1] + dpy

        ;; Current velocity
        velocity = velo[i * dims[1] + j]

        ;; the first column but not the last line
        if (i ne dims[0] - 1) && (j eq 0)then begin
           cgimage, data[*, *, i * dims[1] + j], /keep_aspect_ratio, $
                    position=position, /noerase
           imcontour, imdatac, imhdc, levels=levels, position=position, $
                      /type, /noerase, xtickformat="(A1)", subtitle=' ', $
                      xtitle='', xminor=0, yminor=0, label=0, nodata=nocont, $
                      ydelta=ydelta, ytitle=ytitle, charsize=charsize
           cgtext, 0.05 * (position[2] - position[0]) + position[0], $
                   1.05 * (position[3] - position[1]) + position[1], $
                   string(velocity, format='(f0.2)') + 'km/s', $
                   charsize=1.2 * charsize, /normal
        endif
        ;; the last line but not the first column
        if (i eq dims[0] - 1) && (j ne 0) then begin
           cgimage, data[*, *, i * dims[1] + j], /keep_aspect_ratio, $
                    position=position, /noerase
           imcontour, imdatac, imhdc, levels=levels, position=position, $
                      /type, /noerase, ytickformat="(A1)", subtitle=' ', $
                      ytitle='', xdelta=xdelta, xminor=0, yminor=0, $
                      label=0, xtitle=xtitle, charsize=charsize, nodata=nocont
           cgtext, 0.05 * (position[2] - position[0]) + position[0], $
                   1.05 * (position[3] - position[1]) + position[1], $
                   string(velocity, format='(f0.2)') + 'km/s', $
                   charsize=1.2 * charsize, /normal
        endif
        ;; the fist column and the last line
        if (i eq dims[0] - 1) && (j eq 0) then begin
           cgimage, data[*, *, i * dims[1] + j], /keep_aspect_ratio, $
                    position=position, /noerase
           imcontour, imdatac, imhdc, levels=levels, position=position, $
                      /type, /noerase, charsize=charsize, subtitle=' ', $
                      xdelta=xdelta, ydelta=ydelta, xminor=0, yminor=0, $
                      label=0, xtitle=xtitle, ytitle=ytitle, nodata=nocont
           cgtext, 0.05 * (position[2] - position[0]) + position[0], $
                   1.05 * (position[3] - position[1]) + position[1], $
                   string(velocity, format='(f0.2)') + 'km/s', $
                   charsize=1.2 * charsize, /normal
        endif
        ;; neither the first column nor the last line
        if (i ne dims[0] - 1) && (j ne 0) then begin
           cgimage, data[*, *, i * dims[1] + j], /keep_aspect_ratio, $
                    position=position, /noerase
           imcontour, imdatac, imhdc, levels=levels, position=position, $
                      /type, /noerase, xtickformat="(A1)", xtitle='', $
                      ytickformat="(A1)", subtitle=' ', charsize=charsize, $
                      ytitle='', xminor=0, yminor=0, label=0, nodata=nocont
           cgtext, 0.05 * (position[2] - position[0]) + position[0], $
                   1.05 * (position[3] - position[1]) + position[1], $
                   string(velocity, format='(f0.2)') + 'km/s', $
                   charsize=1.2 * charsize, /normal
        endif
     endfor
  endfor

  ;; Load color table and plot colorbar
  cgloadct, 3
  cgcolorbar, /vertical, range=[dmin, dmax], format='(f0.1)', $
              position=cbpos, /reverse, charsize=1.1 * charsize, /right

end
