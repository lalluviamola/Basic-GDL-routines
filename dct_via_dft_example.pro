PRO DCT_VIA_DFT_EXAMPLE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure computes the 2-D Discrete Cosine
; Transform (DCT) by means of the 2-D Discrete Fourier Transform
; (DFT) to a 'R' thin white letter on a black foreground and
; reconstructs it later.
;
; Input:          -
; Output:         -
; External calls: DCT_VIA_DFT    procedure
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

; Set indexed graphic mode
DEVICE, DECOMPOSE = 0

; Lad grayscale palette
LOADCT, 0

; Define size of simple image
x_size = 128
y_size = 128

; Open graphic window
WINDOW, 0, XSIZE = x_size, YSIZE = y_size, TITLE = 'ORG'

; Write a centered letter "R"
XYOUTS, 0.25, 0.25, 'R', CHARSIZE = 8, CHARTHICK = 4, /NORM

; Grab the sample image from window
image = TVRD()

; Wait click
CURSOR, unused_cursor_x_pos, unused_cursor_y_pos, 4

; Compute the DCT as the DFT of the expanded image
DCT_image = DCT_VIA_DFT(image, /SHOW_EXPANDED_IMAGE, /SHOW_DCT_DFT)

; Recover the original image
inv_DCT_image = DCT_VIA_DFT(DCT_image, 1, /SHOW_DCT_DFT)

; Open graphic window to host the reconstructed image
WINDOW, 1, XSIZE = x_size, YSIZE = y_size, TITLE = 'Image compressed by DCT', $
        XPOS = 3 * x_size, YPOS = 3 * y_size

; Display the reconstructed image in window
TV, inv_DCT_image

; Wait for mouse click
CURSOR, unused_cursor_x_pos, unused_cursor_y_pos, 4

WDELETE, 0, 1

END
