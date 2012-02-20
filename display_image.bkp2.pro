PRO DISPLAY_IMAGE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure allows the interactive selection of an image file,
; determine its features and display it in a properly sized graphic
; windows. The R, G, B components of a true color image are
; displayed in a separated windows as well in a unique window after
; resizing.
;
; Input:          -
; Output:         -
; External calls: #LOAD_IMAGE
;                 #SHOW_IMAGE
; 
; Programmer:    Daniel Molina García
; Creation date: 17 October 2011
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

LOAD_IMAGE, image, n_channels, x_size, y_size, has_palette, r, g, b, interleav_type, $
           pixel_type, image_index, num_images, image_type, filename

; Display the original image in a window
win_index = 1
win_x_pos = 0
win_y_pos = 0
image_pos = 0
win_title = filename

SHOW_IMAGE, image, n_channels, x_size, y_size, has_palette, r, g, b, $
            interleav_type, filename, win_index, win_x_pos,          $
            win_y_pos, image_pos, title
;stop
case n_channels of
   ; True color image
   ; Display R, G and B in differents windows

   3: begin
   ; Check if image structure is (3, m, n)
      if (interleav_type EQ 1) then begin

         ; display R component in window (win_index + 1)
         ; Extract R component from image array
         image_R = image[1, *, *]

         ; set channel number to 1
         r_channel = 1

         ;set associate palette flag as true
         r_palette = 1

         ; build up a linear red color table
         R_vect = BYTSCL(INDGEN(256))
         G_vect = BYTARR(256)
         B_vect = BYTARR(256)

         ; set window's index, position, etc.
         win_index_R = win_index + 1
         win_x_pos = 200
         win_y_pos = 0
         image_pos = 0
         win_title = 'Red image component'

         ; There are a lot of properties but we are not to use all

         ; Let's display the image
         SHOW_IMAGE, image, r_channel, x_size, y_size,           $
                    r_palette, R_vect, G_vect, B_vect ,         $
                    interleav_type, filename, win_index_R,      $
                    win_x_pos, win_y_pos, image_pos, win_title

stop

         ; Display G component
         image_G = image[1, *, *] ; It is not a good idea, generally. Too much dimensions.

         g_channel = 1
         g_palette = 1

         R_vect = BYTARR(256)
         G_vect = BYTSCL(INDGEN(256))
         B_vect = BYTARR(256)

         win_index_G = win_index + 2
         win_x_pos = 400
         win_y_pos = 0
         image_pos = 0
         title = 'Green image component'

         SHOW_IMAGE, image_G, r_channel, x_size, y_size, has_palette, R_vect, $
                     G_vect, B_vect, interleav_type, filename, win_index_G,   $
                     win_x_pos, win_y_pos, image_pos, win_title

         ; Display B component
         image_B = image[1, *, *] ; It is not a good idea, generally. Too much dimensions.

         g_channel = 1
         g_palette = 1

         R_vect = BYTARR(256)
         G_vect = BYTARR(256)
         B_vect = BYTSCL(INDGEN(256))

         win_index_B = win_index + 3
         win_x_pos = 600
         win_y_pos = 0
         image_pos = 0
         title = 'Blue image component'

         SHOW_IMAGE, image_R, r_channel, x_size, y_size, has_palette, R_vect, $
                     G_vect, B_vect, interleav_type, filename, win_index_B,   $
                     win_x_pos, win_y_pos, image_pos, win_title

         ; Activate graphic cursor and wait until a button is pressed.
         ; It returns cursor (device) coordenates in (xcpos, ycpos)
          print, 'Press a mouse button to close the explicit decomposed images.'
          cursor, scpos, ycpos

          wdelete, win_index_R, win_index_G, win_index_B
       endif
   end
else: print, 'No action'
endcase

print, 'Press a mouse button to close the original image.'
cursor, xcpos, ycpos

wdelete, win_index
end


