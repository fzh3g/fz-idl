pro gridspec, imdata, imhd, ra1, ra2, dec1, dec2, vrange=vrange, $
              yrange=yrange, markline=markline, gridsize=gridsize, $
              position=position, color=color, m_color=m_color, $
              m_thick=m_thick, l_color=l_color, window=window, addcmd=addcmd, $
              charsize=charsize, xtitle=xtitle, ytitle=ytitle, noaxis=noaxis, $
              wcs=wcs, _extra=extra, get_x=get_x, get_y=get_y

  ;; Plot a grid of spectra

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters and keywords
  if (n_params() lt 6) then begin
     print, 'Syntax - linegrid, imdata, imhd, ra1, ra2, dec1, dec2,'
     print, '         [vrange=vrange, yrange=yrange, markline=markline,'
     print, '          gridsize=gridsize, position=position, color=color,'
     print, '          m_color=m_color, m_thick=m_thick, l_color=l_color,'
     print, '          charsize=charsize, xtitle=xtitle, ytitle=ytitle,'
     print, '          noaxis=noaxis, wcs=wcs, _extra=extra]'
     return
  endif

  if ~keyword_set(position) then position = [0.1, 0.1, 0.90, 0.90]

  ;; Do not change input data
  imdata1 = imdata & imhd1 = imhd

  ;; Cut ra / dec
  cutradec, imdata1, imhd1, ra1, ra2, dec1, dec2, $
            get_x=get_x, get_y=get_y

  ;; Cut velocity
  if keyword_set(vrange) then begin
     vrange = vrange[sort(vrange)]
     cutvelo, imdata1, imhd1, vrange[0], vrange[1]
  endif

  ;; Check fits
  check_fits, imdata1, imhd1, dimen, /notype

  ;; Get velocity
  velocity = getvelo(imhd1)

  ;; Rebin if needed
  if ~keyword_set(gridsize) then begin
     gridsize = [dimen[0], dimen[1]]
  endif else begin
     if (gridsize[0] ne dimen[0]) || (gridsize[1] ne dimen[1]) then begin
        hrebin3, imdata1, imhd1, gridsize
     endif
  endelse
  message, /inf, 'XY size: [' + strtrim(dimen[0], 2) + ', ' + $
           strtrim(dimen[1], 2) + ']' + ', ' + $
           'Grid size: [' + strtrim(gridsize[0], 2) + ', ' + $
           strtrim(gridsize[1], 2) + ']'

  ;; Plot
  message, /inf, 'Plotting grid and spectra ...'
  pos = fltarr(4)
  dx = (position[2] - position[0]) / gridsize[0]
  dy = (position[3] - position[1]) / gridsize[1]

  if ~keyword_set(yrange) then begin
     maxvalue = max(imdata1)
     yrange = [0, maxvalue]
  endif

  if ~keyword_set(xtitle) then xtitle = 'V!DLSR !N(km s!U -1!N)'
  if ~keyword_set(ytitle) then ytitle = 'T!Dmb !N(K)'

  if ~keyword_set(noaxis) then begin
     xstyle=1
     ystyle=1
  endif else begin
     xstyle=13
     ystyle=13
  endelse

  if keyword_set(wcs) then begin
     newim1 = imdata1[*, *, 0]
     newhd1 = imhd1
     sxaddpar, newhd1, 'naxis', 2
     sxdelpar, newhd1, 'naxis3'
     imcontour, newim1, newhd1, position=position, /nodata, /noerase, $
                xticklen=-0.02, yticklen=-0.02, xstyle=9, ystyle=9, $
                window=window
  endif else begin
     if keyword_set(window) then cgwindow
  endelse

  if keyword_set(window) || keyword_set(addcmd) then cgwin = 1 else cgwin = 0

  for i = 0, gridsize[0] - 1 do begin
     for j = 0, gridsize[1] - 1 do begin
        pos[0] = position[0] + i * dx
        pos[1] = position[1] + j * dy
        pos[2] = position[0] + (i + 1) * dx
        pos[3] = position[1] + (j + 1) * dy

        cgplot, velocity, imdata1[i, j, *], xrange=vrange, yrange=yrange, $
                xstyle=xstyle, ystyle=ystyle, xticks=2, yticks=2, xminor=5, $
                yminor=5, ticklen=0.05, xtickformat="(A1)", color=color, $
                ytickformat="(A1)", position=pos, psym=10, /noerase, $
                addcmd=cgwin, _extra=extra

        if keyword_set(markline) then begin
           cgoplot, [markline, markline], yrange, linestyle=1, $
                    thick=m_thick, color=m_color, addcmd=cgwin
        endif

        if ~keyword_set(noaxis) then begin
           if ~keyword_set(charsize) then charsize=1.0
           if ~keyword_set(l_color) then l_color=cgcolor('black')
           if (i eq gridsize[0] - 1) && (j eq gridsize[1] - 1) then begin
              cgaxis, xaxis=1, xticks=2, xrange=vrange, xstyle=xstyle, $
                      charsize=charsize, charthick=m_thick, $
                      xtitle=xtitle, color=l_color, window=cgwin
              cgaxis, yaxis=1, yticks=2, yrange=yrange, ystyle=ystyle, $
                      charsize=charsize, charthick=m_thick, $
                      ytitle=ytitle, color=l_color, window=cgwin
           endif
        endif
     endfor
  endfor
end
