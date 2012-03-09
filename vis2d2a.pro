PRO VIS2D2A, image_1, image_2,                             $
             WTITLE   = win_title,                         $
             TITLE_1  = title_1,                           $
             XTITLE_1 = x_title_1, YTITLE_1 = y_title_1,   $
             TITLE_2  = title_2,                           $
             XTITLE_2 = x_title_2, YTITLE_2 = y_title_2,   $
             XMIN_1  = x_min_1,    XMAX_1   = x_max_1,     $
             YMIN_1  = y_min_1,    YMAX_1   = y_max_1,     $
             XMIN_2  = x_min_2,    XMAX_2   = x_max_2,     $
             YMIN_2  = y_min_2,    YMAX_2   = y_max_2,     $
             XLINE_1 = x_line_1,  YLINE_1   = y_line_1,    $
             XLINE_2 = x_line_2,  YLINE_2   = y_line_2,    $
             RHO_MAX = rho_max,   THETA_MAX = theta_max
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure visualizes 2 arrays in adjacents quadrants of a
; unique graphic window as colored images and with customizable axes
; ranges and allows the drawing of a straight line in the first
; quadrant and a marker in the second quadrant
;
; WARNING: Expection GRAYSCALE image
;
; Input:          image_?       array of ? image
;                 WTITLE        window title
;                 TITLE_?       title  of the ? graph
;                 XTITLE_?      title of the x-axis in ? graph
;                 YTITLE_?      y-size of the ? image
;                 XMIN_?        min axis value of the image ?
;                 XMAX_?        max axis value of the image ?
;                 XLINE_?       x coordinate of ? line point
;                 YLINE_?       y coordinate of ? line point
;                 RHO_MAX       y coordinate of Radon maximum
;                 THETA_MAX     x coordinate of Radon maximum
; Output:         -
; External calls: SCREEN_SIZE
;                 CENTER_WINDOW_POS
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: 7-March-2012
; Environment:   i686 GNU/Linux 2.6.32-38-generic Ubuntu
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

; Derive maximum screen size (pxs)
SCREEN_SIZE, x_screen, y_screen

; Derive images size
x_size_1 = (SIZE(image_1))[1]
y_size_1 = (SIZE(image_1))[2]

x_size_2 = (SIZE(image_2))[1]
y_size_2 = (SIZE(image_2))[2]

; Determine aspect ratio of image 1 (x : y)
ar_1 = FLOAT(x_size_1) / FLOAT(y_size_1)

; Determine aspect ratio of image 2 (x : y)
ar_2 = FLOAT(x_size_2) / FLOAT(y_size_2)

; Define size of a standard graphic window (pxs) according to the sum
; of images sizes as 90% of screen size in x or y direction according
; to dominant aspect ratio to allow the display of two windows in the
; viewport

; Two square quadrants => 1/2 | 1/2
if (x_size_1 eq y_size_1) and (x_size_2 eq y_size_2) then begin

   ; x size of 1st quadrant as 1/2 of 90% of screen x size
   x_size_quad_1 = (1. / 2.) * 0.9 * x_screen

   ; y size of 1st quadrant is equal to x size
   y_size_quad_1 = x_size_quad_1

   ; Define x and y size of window
   x_win_size = FLOOR(2 * x_size_quad_1)
   y_win_size = FLOOR(y_size_quad_1)

endif

; A square quadrant and a rectangular quadrant => (y_size_2 | 2/3) OR
;                                                 [y_size_2 | 0.9]
if (x_size_1 eq y_size_1) and (x_size_2 ne y_size_2) then begin

   ; x size of rectangular quadrant is 2/3 of 90% of screen x size
   x_size_quad_2 = (2. / 3.) * 0.9 * x_screen

   ; y size of rectangular quadrant is derived according to aspect
   ; ratio
   y_size_quad_2 = x_size_quad_2 / ar_2

   ; If y size exceeds 90% of screen y size then redefine it and
   ; x size accordingly
   if (y_size_quad_2 gt (0.9 * y_screen)) then begin

      y_size_quad_2 = 0.9 * y_screen
      x_size_quad_2 = y_size_quad_2 * ar_2

   endif

   ; Define x and y size of square quadrant
   x_size_quad_1 = y_size_quad_2
   y_size_quad_1 = y_size_quad_2

   ; Define x and y size of graphic window
   x_win_size = FLOOR(x_size_quad_1 + x_size_quad_2)
   y_win_size = FLOOR(y_size_quad_1)

endif

; A rectangular quadrant and a square quadrant => (2/3 | y_size_1) OR
;                                                 [0.9 | y_size_1]
if (x_size_1 ne y_size_1) and (x_size_2 eq y_size_2) then begin

; x size of rectangular quadrant is 2/3 of 90% of screen x size
   x_size_quad_1 = (2. / 3.) * 0.9 * x_screen

; y size of rectangular quadrant is derived according to aspect
; ratio
   y_size_quad_1 = x_size_quad_1 / ar_1

; If y size exceeds 90% of screen y size then redefine it and
; x size accordingly
   if (y_size_quad_1 gt (0.9 * y_screen)) then begin
      y_size_quad_1 = 0.9 * y_screen
      x_size_quad_1 = y_size_quad_1 * ar_1
   endif

   ; Define x and y size of square quadrant
   x_size_quad_2 = y_size_quad_1
   y_size_quad_2 = y_size_quad_1

   ; Define x and y size of graphic window
   x_win_size = FLOOR(x_size_quad_1 + x_size_quad_2)
   y_win_size = FLOOR(y_size_quad_1)

endif

; Two rectangular quadrants
if (x_size_1 ne y_size_1) and (x_size_2 ne y_size_2) then begin
   case 1 of

      ; The first image is larger than/equal to the second one
      (x_size_1 ge x_size_2) : begin

         ; x size of rectangular quadrant is 1/2 of 90% of screen x size
         x_size_quad_1 = (1. / 2.) * 0.9 * x_screen

         ; y size of rectangular quadrant is derived according to aspect
         ; ratio
         y_size_quad_1 = x_size_quad_1 / ar_1

         ; If y size exceeds 90% of screen y size then redefine it and
         ; x size accordingly
         if (y_size_quad_1 gt (0.9 * y_screen)) then begin

            y_size_quad_1 = 0.9 * y_screen
            x_size_quad_1 = y_size_quad_1 * ar_1

         endif

         ; Define x and y size of second quadrant
         x_size_quad_2 = x_size_quad_1
         y_size_quad_2 = y_size_quad_1

         ; Define x and y size of graphic window
         x_win_size = FLOOR(x_size_quad_1 + x_size_quad_2)
         y_win_size = FLOOR(y_size_quad_1)

      end

      ; The first image is smaller than the second one
      (x_size_1 lt x_size_2) : begin

         ; x size of rectangular quadrant is 1/2 of 90% of screen x size
         x_size_quad_2 = (1. / 2.) * 0.9 * x_screen

         ; y size of rectangular quadrant is derived according to aspect
         ; ratio
         y_size_quad_2 = x_size_quad_2 / ar_2

         ; If y size exceeds 90% of screen y size then redefine it and
         ; x size accordingly
         if (y_size_quad_2 gt (0.9 * y_screen)) then begin

            y_size_quad_2 = 0.9 * y_screen
            x_size_quad_2 = y_size_quad_2 * ar_2

         endif

         ; Define x and y size of first quadrant
         x_size_quad_1 = x_size_quad_2
         y_size_quad_1 = y_size_quad_2

         ; Define x and y size of graphic window
         x_win_size = FLOOR(x_size_quad_1 + x_size_quad_2)
         y_win_size = FLOOR(y_size_quad_1)

      end

   endcase

endif

; 2-D VISUALIZATION

; Define centered window origin based on window size
CENTER_WINDOW_POS, x_win_size, y_win_size, x_win_pos, y_win_pos

; Open Window
WINDOW, 1, XSIZE = x_win_size, YSIZE = y_win_size,                   $
           XPOS  = x_win_pos,  YPOS  = y_win_pos,                    $
           TITLE = win_title

; Draw axes based on image size in 1st quadrant defined
; by normalized coordinates [0.05, 0.1, 0.45, 0.9]
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1),                          $
      XSTYLE = 1, YSTYLE = 1,                                        $
      TITLE = title_1,                                               $
      XTITLE = x_title_1, YTITLE = y_title_1,                        $
      POSITION = [0.05, 0.1, 0.45, 0.9],                             $
      /NODATA, /NOERASE,                                             $
      XRANGE = [x_min_1, x_max_1], YRANGE = [y_min_1, y_max_1]

; Determine size of plot window as defined by the PLOT procedure
; * !X.WINDOW,  !Y.WINDOW  -> normalized coordinates of axis end points
; * !D.X_VSIZE, !D.Y_VSIZE -> size of visible area of window (pxs)
plot_x = !X.WINDOW * !D.X_VSIZE
plot_y = !Y.WINDOW * !D.Y_VSIZE

; Define size of image to fit 1st quadrant of plot window
image_x_size = plot_x[1] - plot_x[0] + 1
image_y_size = plot_y[1] - plot_y[0] + 1

; Display original image rebinned according to new size
case (SIZE(image_1))[0] of

   ; Indexed color image
   2 : TV, CONGRID(BYTSCL(image_1), image_x_size, image_y_size), plot_x[0], plot_y[0]

   ; True-color image
   3 : TV, CONGRID(image_1, 3, image_x_size, image_y_size), plot_x[0], plot_y[0], /TRUE

endcase

; Redraw axes
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1),                          $
      XSTYLE = 1, YSTYLE = 1,                                        $
      TITLE = title_1,                                               $
      XTITLE = x_title_1, YTITLE = y_title_1,                        $
      POSITION = [0.05, 0.1, 0.45, 0.9],                             $
      /NODATA, /NOERASE

; Draw straight line
PLOTS, x_line_1, y_line_1
PLOTS, [x_line_1, x_line_2], [y_line_1, y_line_2],                   $
       /DATA, /CONTINUE, NOCLIP = 0

; Draw axes based on image size in 2nd quadrant defined
; by normalized coordinates [0.55, 0.1, 0.95, 0.9]
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1),                          $
      XSTYLE = 1, YSTYLE = 1,                                        $
      TITLE = title_2,                                               $
      XTITLE = x_title_2, YTITLE = y_title_2,                        $
      POSITION = [0.55, 0.1, 0.95, 0.9],                             $
      XRANGE = [x_min_2, x_max_2], YRANGE = [y_min_2, y_min_2],      $
      /NODATA, /NOERASE


; Determine size of plot window as defined by the PLOT procedure
; * !X.WINDOW, !Y.WINDOW   -> normalized coordinates of axis end points
; * !D.X_VSIZE, !D.Y_VSIZE -> size of visible area of window [pxs]
plot_x = !X.WINDOW * !D.X_VSIZE
plot_y = !Y.WINDOW * !D.Y_VSIZE

; Define size of image to fit 2nd quadrant of plot window
image_x_size = plot_x[1] - plot_x[0] + 1
image_y_size = plot_y[1] - plot_y[0] + 1

; Display rebinned image rebinned according to new size
case (SIZE(image_2))[0] of

   ; Indexed color image
   2 : TV, CONGRID(BYTSCL(image_2), image_x_size, image_y_size), plot_x[0], plot_y[0]

   ; Truecolor image
   3 : TV, CONGRID(image_2, 3, image_x_size, image_y_size), plot_x[0], plot_y[0], /TRUE

endcase

; Redraw axes
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1),                          $
      XSTYLE = 1, YSTYLE = 1,                                        $
      TITLE = title_2,                                               $
      XTITLE = x_title_2, YTITLE = y_title_2,                        $
      POSITION = [0.55, 0.1, 0.95, 0.9],                             $
      XRANGE = [x_min_2, x_max_2], YRANGE = [y_min_2, y_min_2],      $
      /NODATA, /NOERASE


; Plot marker on Radon maximum
PLOTS, theta_max, rho_max,    $
       PSYM = 7, SYMSIZE = 3, $
       /DATA

END
