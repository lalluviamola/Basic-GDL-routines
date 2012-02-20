PRO TVN, image0, image1, image2, image3,                                     $
         TEXT1 = text1, TEXT2 = text2, TEXT3 = text3, TEXT4 = text4, $
         CENTER = center, TITLE = title

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Represent between 1 and 4 images on a unique window, with optional
; descriptions written in the bottom left corner of the respectiv one
;
; Input:          image0
;                 image1
;                 image2
;                 image3
; Output:         -
; External calls: -
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


x_size = (SIZE(image0))[1]
y_size = (SIZE(image0))[2]

if N = 1 then begin
                                ; Open graphic window
WINDOW, 77, XSIZE = x_size, YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'DFT and DCT compressed images'

                                ; Display DFT-compressed image
TV, DCT_compressed_image, 1
                                ; Write label
XYOUTS, 0.005, 0.01, 'DFT Compressed' , /NORM

                                ; Display DCT-compressed image in
                                ; quadrant 2
TV, DCT_compressed_image, 1

                                ; Write label
XYOUTS, 0.505, 0.01, 'DCT Compressed', /NORM

PRESS_MOUSE

; Delete graphic window
WDELETE
