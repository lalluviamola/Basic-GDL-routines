PRO IMAGE_SCALE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure loads a truecolor image of Mars, convert it to
; indexed, displays and activate cursor to mark planet diameter,
; finally determines the physical scale of image and displays it in a
; physical coordinate system
;
; Input:          -
; Output:         -
; External calls: SCREEN_SIZE   procedure
;                 CENTER_WINDOW_POS
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: -
; Environment:   i686 GNU/Linux 2.6.32-34-generic Ubuntu
; Modified:      -
; Version:       0.1
;
; License: Copyright 2011 Daniel Molina García 
;
;          This program is free software: you can redistribute it
;          and/or modify it under the terms of the GNU General Public
;          License as published by the Free Software Foundation,
;          either version 3 of the License, or (at your option) any
;          later version.
;
;          This program is distributed in the hope that it will be
;          useful, but WITHOUT ANY WARRANTY; without even the implied
;          warranty of  MERCHANTABILITY or FITNESS FOR A PARTICULAR
;          PURPOSE.  See the GNU General Public License for more
;          details.
;
;          You should have received a copy of the GNU General Public
;          License along with this program.  If not, see
;          <http://www.gnu.org/licenses/>.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DEVICE, DECOMPOSED = 0

; Read in true color Mars image from file
READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image, TRUE = 1

; Convert truecolor image into 256-colors indexed
image = COLOR_QUAN(image, 1, r, g, b)

; Determine image size 
image_size = SIZE(image)
x_size     = image_size[1]
y_size     = image_size[2]

; Define window size based on image size to allow for axes and labels
x_win_size = 1.25 * x_size
y_win_size = 1.25 * y_size

; Derive centered window position
CENTER_WINDOW_POS, x_size, y_size, x_win_pos, y_win_pos

; Open window
WINDOW, 0, XSIZE = x_win_size, YSIZE = y_win_size, XPOS = x_win_pos, YPOS = y_pos, $
        TITLE = 'Logical Scale'

; Load image palette
TVLCT, r, g, b

; Draw axes based on image size
PLOT, FINDGEN(x_size), FINDGEN(y_size), XSTYLE = 1, YTITLE = 1, XTITLE = '(pxs)', $
      YTITLE = '(pxs)', TITLE='Logical Scale of Image', /NODATA, /NOERASE,        $
      POSITION = [0.1, 0.1, 0.9, 0.9]

; Determine size of plot window as defined by the PLOT procedure
; * !X.WINDOW, !Y.WINDOW  -- normalized coordinates of axis end points
; * !D.X_VSIZE, !D.Y_SIZE -- size of visible are of window (pxs)

plot_win_x_size = !X.WINDOW * !D.X_VSIZE
plot_win_y_size = !Y.WINDOW * !D.Y_VSIZE

; Define size of image to fit the plot window
image_x_size = plot_win_x_size[1] - plot_win_x_size[0] + 1
image_y_size = plot_win_y_size[1] - plot_win_y_size[0] + 1

; Display rebinned image according to new size
TV, CONGRID(BYTSCL(image), image_x_size, image_y_size), plot_win_x_size[0], plot_win_y_size[0]

; Redraw axes
PLOT, FINDGEN(x_size), FINDGEN(y_size), XSTYLE = 1, YSTYLE = 1,XTITLE = '(pxs)', $
      YTITLE = '(pxs)', TITLE = 'Logical Scale of Image', /NODATA, /NOERASE,     $
      POSITION = [0.1, 0.1, 0.9, 0.9]

; Activate graphic cursor to mark start pixel of planet diameter
CURSOR, x_start, y_start, 4, /DEV

; Activate graphic cursor to mark start pixel of planet diameter
CURSOR, x_end, y_end, 4, /DEV

; Compute image scale

; Mars apparent diameter
mars_apparent_diam_arcsec = 25   ; (arcsec)

; Mars distance
mars_dist_au = 0.3727    ; (astronomical units)

; Astrnomical Unit
au_km = 149.6E6          ; (km/au)

; Radians from one arcsec
arcsec_rad = 1/206265.    ; (rad/arcsec)

; Mars lineal diameter
mars_lineal_diam = (mars_apparent_diam_arcsec * arcsec_rad) * (mars_dist_au * au_km) ; (km)

; Mars diameter on image
mars_plot_diam = SQRT((x_start-x_end)^2 + (y_start - y_end)^2)                       ; (pxs)

; Image scale factor
scale_factor = mars_lineal_diam / mars_plot_diam                                     ; (km/px)


; Display image in physical coordinate system

; Clear window
ERASE

; Display image
TV, CONGRID(BYTSCL(image), image_x_size, image_y_size), plot_win_x_size[0], plot_win_y_size[0]

; Draw axes with physical units
PLOT, FINDGEN(x_size) * mars_linear_diam / x_size, FINDGEN(y_size) * mars_linear_diam / y_size, $
      XSTYLE = 1, YSTYLE = 1, XTITLE = '(km)', YTITLE = '(km)',                                 $
      TITLE = 'Physical Scale of Image' + STRTRIM(STRING(scale_factor), 2) + '(km/px)',         $
      /NODATA, /NOERASE, POSITION = [0.1, 0.1, 0.9, 0.9]

; Write text in graphic window
XYOUTS, 0.1, 0.01, 'Planet Diameter: ' + STRTRIM(STRING(mars_lineal_diam  ), 2) + '(km)'      + $
                                         STRTRIM(STRING(mars_plot_diam    ), 2) + '(pxs)'     + $
                                         STRTRIM(STRING(mars_apparent_diam), 2) + '(arcsec)',   $
        /NORM

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, xcpos, ycpos, /DEVICE, /WAIT

; Delete active window
WDELETE

END
        
