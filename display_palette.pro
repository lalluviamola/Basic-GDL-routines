PRO DISPLAY_PALETTE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure display the palette of an indexed image
;
; Input:          -
; Output:         -
; External calls: LOAD_IMAGE
;                 DRAW_PALETTE
; 
; Programmer:    Daniel Molina García (based on M. Messerotti examples)
; Creation date: -
; Environment:   i686 GNU/Linux Saturno 2.6.32-34-generic #77-Ubuntu
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

; Load default palette [0]
LOADCT, 0

; Interactive image file selection and analysis
LOAD_IMAGE, image, n_channels, x_size, y_size,    $
            has_palette, r, g, b, interleav_type, $
            pixel_type, image_index, num_images,  $
            image_type, filename

; Image display in window
win_index  = 1
win_x_size = x_size + 50
win_y_size = y_size + 50
win_x_pos  = 0
win_y_pos  = 0
image_pos  = 0
win_title  = filename

; Open window
WINDOW, win_index, XSIZE = win_x_size, YSIZE = win_y_size,    $
        XPOS = win_x_pos, YPOS = win_y_pos, TITLE = win_title

; Load image palette, if any
if ( has_palette EQ 1 ) then begin
   DEVICE, DECOMPOSED = 0
   TVLCT, r, g, b
endif

; Display image
case n_channels of
   1 : TV, image, image_pos
   3 : begin
      DEVICE, DECOMPOSED = 1
      TV, image, image_pos, /TRUE
   end
   4 : begin
      DEVICE, DECOMPOSED = 1
      TV, image, image_pos, /TRUE
   end 
endcase

; Draw one horizontal colorbar
x_palette_size = x_size - 0.3 * x_size
y_palette_size = 20
x_palette_origin = (x_size - x_palette_size + 1) / 2.
y_palette_origin = 20
border_color = !P.COLOR

DRAW_PALETTE, x_palette_origin, y_palette_origin, $
              x_palette_size, y_palette_size,     $
              border_color


; Draw vertical colorbar
x_palette_size   = 20
y_palette_size   = y_size - 0.3 * y_size

x_palette_origin = x_size + 5
y_palette_origin = (y_size - y_palette_size + 1) / 2 + 50

border_color = !P.COLOR

DRAW_PALETTE, x_palette_origin, y_palette_origin, $
              x_palette_size, y_palette_size,     $
              border_color

;stop

; Activate graphic cursor to wait for mouse click
PRESS_MOUSE

; Delete graphic window
WDELETE

END
