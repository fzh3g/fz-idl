pro contgridspec, cubes, bkg, racen, deccen, rasize, decsize, $
                  vrange=vrange, yrange=yrange, gridsize=gridsize, $
                  outfile=outfile, nlevels=nlevels, levgap=levgap, $
                  levbot=levbot, contpos=contpos, cbpos=cbpos, cbname=cbname, $
                  legloc=legloc, markline=markline, ticklen=ticklen, $
                  specnames=specnames, speccolors=speccolors, $
                  specxytitle=specxytitle, workdir=workdir, pixgap=pixgap, $
                  colorbar=colorbar, legend=legend, nocont=nocont, nops=nops, $
                  nogrid=nogrid, charscale=charscale, cbtail=cbtail, $
                  thickscale=thickscale, window=window, noerase=noerase, $
                  get_gridpos=gridpos

  ;; Overplot a grid of spectra of data cubes on top of a contour of
  ;; background image

  ;; Return to caller
  on_error, 2

  ;; Compile option
  compile_opt idl2

  ;; Check parameters
  if (n_params() lt 6) then begin
     print, 'Syntax - contgridspec, cubes, bkg, racen, deccen, rasize, decsize,'
     print, '         [vrange=vrange, yrange=yrange, gridsize=gridsize,'
     print, '          outfile=outfile, nlevels=nlevels, levgap=levgap,'
     print, '          levbot=levbot, contpos=contpos, cbpos=cbpos,'
     print, '          cbname=cbname, legloc=legloc, markline=markline,'
     print, '          ticklen=ticklen,specnames=specnames,'
     print, '          specxytitle=specxytitle, speccolors=speccolors,'
     print, '          workdir=workdir, pixgap=pixgap, colorbar=colorbar,'
     print, '          legend=legend, nocont=nocont, nogrid=nogrid,'
     print, '          charscale=charscale, nops=nops, ctail=cbtail,'
     print, '          thickscale=thickscale, get_gridpos=gridpos]'
     return
  endif

  ;; Go to work directory
  if keyword_set(workdir) then begin
     message, /inf, 'Enter directory: ' + workdir
     cd, workdir
  endif

  ;; Number of cube files
  ncube = n_elements(cubes)

  if (ncube gt 5) then begin
     message, 'ERROR - length of CUBEFILES must be less than 6', /con
     return
  endif

  ;; Read fits file
  message, /inf,  'Read data cube file: ' + cubes[0]
  fits_read, cubes[0], imdata, imhd

  message, /inf,  'Read background file: ' + bkg
  fits_read, bkg, imdatab, imhdb

  ;; Output file name
  if ~keyword_set(outfile) then outfile = 'contgridspec.ps'

  if ~keyword_set(speccolors) then begin
     speccolors = ['red', 'dodger blue', 'orange', 'pur6', 'black']
     speccolors = speccolors[0 : ncube - 1]
  endif

  ;; Names
  if ~keyword_set(specnames) then begin
     specnames = ['SPEC1', 'SPEC2', 'SPEC3', 'SPEC4', 'SPEC5']
     specnames = specnames[0 : ncube - 1]
  endif

  ;; Spectra x y titles
  if ~keyword_set(specxytitle) then specxytitle = ['V!DLSR !N(km s!U -1!N)', $
                                                   'T!Dmb !N(K)']

  ;; Contour levels
  if ~keyword_set(nlevels) then nlevels = 10
  if ~keyword_set(levgap) then levgap = 2
  if ~keyword_set(levbot) then levbot = 23

  ;; Pixel gap between the grid and the axes frame of contour
  if ~keyword_set(pixgap) then pixgap = 0 else pixgap = round(pixgap)

  ;; Contour ticklen
  if ~keyword_set(ticklen) then ticklen = 0.02

  ;; Contour thickness
  if ~keyword_set(thickscale) then thickscale=1.0

  ;; Contour position
  if ~keyword_set(contpos) then begin
     contpos = [0.12, 0.14, 0.81, 0.94]
  endif

  ;; Legend location
  if ~keyword_set(legloc) then begin
     legloc = [(contpos[2] - contpos[0]) * 0.025 + contpos[2], $
               (contpos[3] - contpos[1]) * 0.03 * ncube + contpos[1]]
  endif

  ;; Colorbar position
  if ~keyword_set(cbpos) then begin
     cbpos = [(contpos[2] - contpos[0]) * 0.12 + contpos[2], $
              (contpos[3] - contpos[1]) * 0.20 + contpos[1], $
              (contpos[2] - contpos[0]) * 0.17 + contpos[2], $
              (contpos[3] - contpos[1]) * 0.80 + contpos[1]]
  endif

  ;; Colorbar name
  if ~keyword_set(cbname) then cbname = 'Contour !N(K)'

  ;; Scale of charsize
  if ~keyword_set(charscale) then charscale = 1.0

  ;; Tail of colorbar to remove
  if ~keyword_set(cbtail) then cbtail = 2

  ;; Range of ra / dec
  ra1 = racen - rasize / 2
  ra2 = racen + rasize / 2
  dec1 = deccen - decsize / 2
  dec2 = deccen + decsize / 2

  ;; Levels
  levels = findgen(nlevels) * levgap + levbot

  ;; Convert ra/dec to pixel index
  adxy, imhd, ra1, dec1, x1, y1
  adxy, imhd, ra2, dec2, x2, y2
  pixelx = round([x1, x2])
  pixelx = pixelx[sort(pixelx)]
  pixely = round([y1, y2])
  pixely = pixely[sort(pixely)]

  ;; Background pixel indices to cut
  check_fits, imdatab, imhdb, dimen, /notype

  xyad, imhd, pixelx[0] - 0.5, pixely[0] - 0.5, rab1, decb1
  xyad, imhd, pixelx[1] + 0.5, pixely[1] + 0.5, rab2, decb2
  adxy, imhdb, rab1, decb1, xb1, yb1
  adxy, imhdb, rab2, decb2, xb2, yb2

  xb = [xb1, xb2]
  yb = [yb1, yb2]
  xb = xb[sort(xb)]
  yb = yb[sort(yb)]

  dx1 = 0.5d + xb[0] - round(xb[0]) + min([pixgap, round(xb[0])])
  dx2 = 0.5d - xb[1] + round(xb[1]) + min([pixgap, dimen[0] - round(xb[1]) - 1])
  dy1 = 0.5d + yb[0] - round(yb[0]) + min([pixgap, round(yb[0])])
  dy2 = 0.5d - yb[1] + round(yb[1]) + min([pixgap, dimen[1] - round(yb[1]) - 1])

  xb = [max([0, round(xb[0]) - pixgap]), $
        min([dimen[0] - 1, round(xb[1]) + pixgap])]

  yb = [max([0, round(yb[0]) - pixgap]), $
        min([dimen[1] - 1, round(yb[1]) + pixgap])]

  ;; Grid position
  gridpos = fltarr(4)
  lx = xb[1] - xb[0] + 1
  ly = yb[1] - yb[0] + 1
  gridpos[0] = contpos[0] + dx1 / lx * (contpos[2] - contpos[0])
  gridpos[1] = contpos[1] + dy1 / ly * (contpos[3] - contpos[1])
  gridpos[2] = contpos[2] - dx2 / lx * (contpos[2] - contpos[0])
  gridpos[3] = contpos[3] - dy2 / ly * (contpos[3] - contpos[1])

  ;; PS output start
  if ~keyword_set(nops) && ~keyword_set(window) then begin
     getrot, imhd, rot, cdelt
     ;; cgps_open, outfile, default_thickness=1
     ;; cgdisplay, 600, 600 * decsize / rasize * $
     ;;            (gridpos[2] - gridpos[0]) / (gridpos[3] - gridpos[1]) * $
     ;;            abs(cdelt[1] / cdelt[0])
     pson, file=outfile, aspect=decsize / rasize * $
           (gridpos[2] - gridpos[0]) / (gridpos[3] - gridpos[1]) * $
           abs(cdelt[1] / cdelt[0])
     device, /encapsulated, preview=2
  endif

  ;; Cut background file
  message, /inf, 'Cutting background image using HEXTRACT ...'
  message, /inf, 'X range: [' + strtrim(xb[0], 2) + ', ' + $
           strtrim(xb[1], 2) + ']' + ', ' + $
           'Y range: [' + strtrim(yb[0], 2) + ', ' + $
           strtrim(yb[1], 2) + ']'
  hextract, imdatab, imhdb, imdatab1, imhdb1, xb[0], xb[1], $
            yb[0], yb[1], /silent

  ;; Plot contour
  message, /inf, 'Plotting contour ...'
  cgloadct, 8, ncolors=nlevels+cbtail, bottom=1, /reverse
  c_colors = indgen(nlevels) + cbtail + 1

  imcontour, imdatab1, imhdb1, levels=levels, label=0, $
             xticklen=ticklen, yticklen=ticklen, position=contpos, $
             c_colors=c_colors, c_thick=2.5*thickscale, xstyle=1, ystyle=1, $
             xthick=2.5*thickscale, ythick=2.5*thickscale, $
             charthick=2.5*thickscale, xmid=(xb[1]-xb[0])/2, $
             ymid=(yb[1]-yb[0])/2, nodata=nocont, $
             charsize=1.3 * charscale, window=window, noerase=noerase

  ;; Plot colorbar
  if keyword_set(colorbar) then begin
     message, /inf, 'Plotting colorbar ...'
     cgloadct, 8, /reverse
     cgcolorbar, divisions=nlevels-1, minor=0, format='(I0)', $
                 range=[min(levels), max(levels)], /vertical, $
                 bottom=256/(nlevels+cbtail-1)*cbtail, $
                 charsize=1.2*charscale, textthick=2.0*thickscale, $
                 annotatecolor='black', title=cbname, position=cbpos, $
                 tlocation='right', addcmd=window
  endif

  ;; Plot gridspec
  if ~keyword_set(nogrid) then begin
     gridspec, imdata, imhd, ra1, ra2, dec1, dec2, vrange=vrange, $
               color=speccolors[0], markline=markline, $
               m_color=cgcolor("blk6"), m_thick=1.5*thickscale, $
               l_color=cgcolor('brown'), yrange=yrange, position=gridpos, $
               thick=1.5*thickscale, xthick=thickscale, ythick=thickscale, $
               charsize=0.8 * charscale, gridsize=gridsize, addcmd=window, $
               xtitle=specxytitle[0], ytitle=specxytitle[1]

     if (ncube gt 1) then begin
        for i =1, ncube - 1 do begin
           message, /inf,  'Read data cube file: ' + cubes[i]
           fits_read, cubes[i], imdata, imhd
           gridspec, imdata, imhd, ra1, ra2, dec1, dec2, vrange=vrange, $
                     color=speccolors[i], yrange=yrange, $
                     thick=1.5*thickscale, /noaxis, position=gridpos, $
                     gridsize=gridsize, addcmd=window, $
                     xtitle=specxytitle[0], ytitle=specxytitle[1]
        endfor
     endif

     ;; Plot legends of spectra
     if keyword_set(legend) then begin
        message, /inf, 'Plotting legends ...'
        cglegend, title=specnames, color=speccolors, location=legloc, $
                  thick=2.0*thickscale, charsize=0.8 * charscale, $
                  length=0.02, addcmd=window
     endif
  endif

  ;; PS output
  if ~keyword_set(nops) && ~keyword_set(window) then begin
     ;; cgps_close
     psoff
  endif

end
