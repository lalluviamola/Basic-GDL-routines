PRO VIS_2D, win_x_size, win_y_size, win_title,                           $
            image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
            image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure visualizes 2 BYTE-ARRAYS in adjacent quadrants of a unique
; graphic window as colored images
;
; Input:          win_x_size
;                 win_y_size
;                 win_title
;                 image_1
;                 x_size_1      x-size of 1st image
;                 y_size_1      y-size of 1st image
;                 title_1
;                 x_title_1
;                 y_title_1
;                 image_2
;                 x_size_2      x-size of 2nd image
;                 y_size_2      y-size of 2nd image
;                 title_2
;                 x_title_2
;                 y_title_2

; Output:         -
; External calls: SCREEN_SIZE
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

; 2-D Visualization

; Define centered window origin based on window size
CENTER_WINDOW_POS, 2 * win_x_size, win_y_size, x_win_pos, y_win_pos

; Open window
WINDOW, 1, XSIZE = 2 * win_width, YSIZE = win_height,  $
           XPOS  = x_win_pos,     YPOS  = y_win_pos,   $
           TITLE = win_title

; Draw axes based on image size in 1st quadrant defined by normalized
; coordinates [0.05, 0.1, 0.45, 0.9] 
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1),     $
      XSTYLE   = 1,         YSTYLE = 1,         $
      XTITLE   = x_title_1, YTITLE = y_title_1, $
      TITLE    = title_1,                       $
      POSITION = [0.05, 0.1, 0.45, 0.9],        $
      /NODATA, /NOERASE

; Determine size of plot window as defined by the plot procedure
; * !X.WINDOW,  !Y.WINDOW  -- Normalized coordinates of axis end points
; * !D.X_VSIZE, !D.Y_VSIZE -- Size of visible are of window (pxs)
plot_x_size = !X.WINDOW * !D.X_VSIZE
plot_y_size = !Y.WINDOW * !D.Y_VSIZE 

; Define size of image to fit 1st quadrant of plot window
image_x_size = plot_x_size[1] - plot_x_size[0] + 1
image_y_size = plot_y_size[1] - plot_y_size[0] + 1

; Display original image rebinned according to new size
case (SIZE(image_1))[0] of
                                ; Indexed color image
   2 : TV, CONGRID(BYTSCL(image_1), image_x_size, image_y_size), plot_x_size[0], plot_y_size[0]

                                ; True color image
   3 : TV, CONGRID(image_1, 3, image_x_size, image_y_size), plot_x_size, plot_y_size, /TRUE

endcase

; Redraw axes
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1),     $
      XSTYLE   = 1,         YSTYLE = 1,         $
      XTITLE   = x_title_1, YTITLE = y_title_1, $
      TITLE    = title_1,                       $
      POSITION = [0.05, 0.1, 0.45, 0.9],        $
      /NODATA, /NOERASE

; Draw axes based on image size in 2nd quadrant defined by normalized
; coordinates [0.55, 0.1, 0.95, 0.9]
PLOT, FINDGEN(x_size_2), FINDGEN(y_size_2),     $
      XSTYLE   = 1,         YSTYLE = 1,         $
      XTITLE   = x_title_2, YTITLE = y_title_2, $
      TITLE    = title_2,                       $
      POSITION = [0.55, 0.1, 0.95, 0.9],        $
      /NODATA, /NOERASE 

; Determine size of plot window as defined by the plot procedure
; * !X.WINDOW,  !Y.WINDOW  -- Normalized coordinates of axis end points
; * !D.X_VSIZE, !D.Y_VSIZE -- Size of visible are of window (pxs)
plot_x_size = !X.WINDOW * !D.X_VSIZE
plot_y_size = !Y.WINDOW * !D.Y_VSIZE 

; Define size of image to fit 2nd quadrant of plot window
image_x_size = plot_x_size[1] - plot_x_size[0] + 1
image_y_size = plot_y_size[1] - plot_y_size[0] + 1

; Display original image rebinned according to new size
case (SIZE(image_2))[0] of
                                ; Indexed color image
   2 : TV, CONGRID(BYTSCL(image_2), image_x_size, image_y_size), plot_x_size[0], plot_y_size[0]

                                ; True color image
   3 : TV, CONGRID(image_2, 3, image_x_size, image_y_size), plot_x_size, plot_y_size, /TRUE
endcase

; Redraw axes
PLOT, FINDGEN(x_size_2), FINDGEN(y_size_2),     $
      XSTYLE   = 1,         YSTYLE = 1,         $
      XTITLE   = x_title_2, YTITLE = y_title_2, $
      TITLE    = title_2,                       $
      POSITION = [0.55, 0.1, 0.95, 0.9],        $
      /NODATA, /NOERASE 

END
