PRO VISUALIZE_2D
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure visualize a 2-D pseudo image in
; different ways
;
; Input:          -
; Output:         -
; External calls: GAUSSIAN_2          function
;                 SCREEN_SIZE         procedure
;                 WINDOWS_CENTER_POS  procedure
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

; Standard delay (seconds)
delay = 0.5

; Set graphics mode to indexed ColorTable
DEVICE, DECOMPOSED=0

; Load grayscale palette
LOADCT, 0

; Define an asymmetric 2-D gaussian pseudo-image (256 * 256 pxs)
x_size  = 256
y_size  = 256
sigma_x = x_size / 6.
sigma_y = y_size / 9.

image = GAUSSIAN_2(x_size, y_size, sigma_x, sigma_y)

; Define centered window origin based window size
CENTER_WINDOW_POS, x_size, y_size, x_win_pos, y_win_pos

; Open window
WINDOW, 1, XSIZE = x_size, YSIZE = y_size,  $
        XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = '2-D Gaussian'

; Display image
TV, image

; Activate graphic cursor and wait for key pressed, return
; cursor (device) coordinates in [x_c_pos, y_c_pos]
PRINT, 'Press a mouse buton to continue'
CURSOR, x_c_pos, y_c_pos, 4

; Rotate the standard system palettes (40 colortables)
for ct = 0, 30 do begin

   ; Get colortable names in string array
   LOADCT, ct, GET_NAMES = ct_names

   ; Define centered window origin based window size
   CENTER_WINDOW_POS, x_size, y_size, x_pos, y_pos

   ; Open window to update title
   WINDOW, 1, XSIZE = x_size, YSIZE = y_size,  $
           XPOS = x_win_pos, YPOS = y_win_pos, $
           TITLE = ct_names[ct]

   ; Load ColorTable
   LOADCT, ct

   ; Display image
   TV, image
   WAIT, delay
endfor


; Display simple image contouring
x_size = 512
y_size = 512

; Define centered window origin based window size
CENTER_WINDOW_POS, x_size, y_size, x_win_pos, y_win_pos

; Open window
WINDOW, 1, XSIZE = x_size, YSIZE = y_size,  $
        XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Image contouring with contour labels'

; Load Palette
TEK_COLOR

; Image contouring with labels
CONTOUR, image, XSTYLE = 1, YSTYLE = 1,           $
         XTITLE = '(pxs)', YTITLE = '(pxs)',      $
         NLEVELS = 10, C_LABELS = 1 + INTARR(10), $
         C_COLOR = INDGEN(10) + 2,                $
         TITLE = 'Image Color Contours with Labels'

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

; Define centered window origin based window size        
CENTER_WINDOW_POS, x_size, y_size, x_win_pos, y_win_pos

; Open window                                            
WINDOW, 1, XSIZE = x_size, YSIZE = y_size,  $
        XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Image contouring with filled contours'

CONTOUR, image, XSTYLE = 1, YSTYLE = 1,           $
         XTITLE = '(pxs)', YTITLE = '(pxs)',      $
         NLEVELS = 10, C_COLOR = INDGEN(10) + 2,  $
         /FILL,                                   $
         TITLE = 'Image Contouring with Color Filling'

PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

; Define centered window origin based window size        
CENTER_WINDOW_POS, x_size, y_size, x_win_pos, y_win_pos

; Image contouring superimposed to original image
WINDOW, 1, XSIZE = x_size, YSIZE = y_size,  $
        XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Image contouring superimposed to image'

LOADCT, 0

IMAGE_CONT, image, /ASPECT, /INTERP

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

; Delete the active graphic window
WDELETE

END
