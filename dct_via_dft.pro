FUNCTION DCT_VIA_DFT, image0, direction,                         $
                      SHOW_EXPANDED_IMAGE = show_expanded_image, $
                      SHOW_DCT_DFT        = show_dct_dft

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure returns the 2-D Discrete Cosine Transform (DCT) by
; means of the 2-D Discrete Fourier Transform (DFT), or its inverse.
;
; This "quick and dirty" method is based on the consideration that the
; DCT of a NxN image can be computed via application of the DFT to a
; (2 N)x(2 N) image derived from the original image by symmetrical
; expansion:
;
; Original 2x2 image A:  |a b|    Expanded 4x4 image B: |a b b a|
;                        |c d|                          |c d d c|
;                                                       |c d d c|
;                                                       |a b b a|
; DCT(A) = REAL_PART(FFT(B))  (apart from normalization)
; A      =~ FFT(DCT(A), 1) 
;
; Input:          image0          original image
;                 direction       LT 0 -- Forward transform (default)
;                                 GT 0 -- Inverse transform
;                 SHOW_EXPANDED_IMAGE (flag)
;                 SHOW_DCT_DFT        (flag) 
; 
;
; Output:         output_image    DCT(A) or a reconstructed A,
;                                 depending on "direction" 
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

; Options by default
if N_ELEMENTS(direction)           eq 0 then direction           = -1
if N_ELEMENTS(show_expanded_image) eq 0 then show_expanded_image = 0
if N_ELEMENTS(show_dct_dft)        eq 0 then show_dct_dft        = 0    $
else if (direction GT 0) AND show_dct_dft then begin
   PRINT, 'Warning: SHOW_DCT_DFT keyword is not allowed when anti-transforming'
   show_dct_dft = 0
endif

; Get dimensions of the image
x_size = (SIZE(image0))[1]
y_size = (SIZE(image0))[2]

; Image in 2nd quadrant is x-flipped
image1 = REVERSE(image0, 1)

; Image in 3rd quadrant is y flipped
image2 = REVERSE(image0, 2)

; Image in 4rd quadrant is x- and y- flipped
image3 = REVERSE(image1, 2)

                                ; Assign the 4 sub-images to the
                                ; relevant quadrants in the expanded
                                ; image
expanded_image = FLTARR(2 * x_size, 2 * y_size)
                                ; Top-left quadrant
expanded_image[0      : x_size - 1    , y_size : 2 * y_size - 1 ] = image0
                                ; Top-right quadrant
expanded_image[x_size : 2 * x_size - 1, y_size : 2 * y_size - 1 ] = image1
                                ; Bottom-left quadrant
expanded_image[0      : x_size - 1    , 0      : y_size - 1     ] = image2
                                ; Bottom-right quadrant
expanded_image[x_size : 2 * x_size - 1, 0      : y_size - 1     ] = image3


; Compute the DCT as the first quadrant of the real part in the DFT domai
if direction LE 0 then output_image = REAL_PART(FFT(expanded_image)) $

; Derive DCT compressed image as 1st quadrant of the universe DF transform
else output_image = FFT(expanded_image, 1)

; Crop the image to the first quadrant
output_image = output_image[0 : x_size - 1, 0 : y_size - 1] ; (!)


;;;; Optional displays

if show_expanded_image then begin

; Open graphic window with 4 quadrants to host the expanded image
   WINDOW, 10, XSIZE = 2 * x_size, YSIZE = 2 * y_size, TITLE = 'Expanded Image', $
           XPOS = 0, YPOS = 0

; Display the component images in the 4 quadrants
   TV, image0, 0
   TV, image1, 1
   TV, image2, 2
   TV, image3, 3
                                ; Grab the expanded image from graphic
                                ; window
                                ; (Commented. It's better a
                                ; unique method, if the image
                                ; is showed or not)

                                ; expanded_image = TVRD()
   CURSOR, unused_cursor_x_pos, unused_cursor_y_pos, 4
   WDELETE, 10
endif

if show_dct_dft then begin
                                ; Open graphic window to display the DCT and the DFT
   WINDOW, 11, XSIZE = 2 * x_size, YSIZE = y_size, TITLE = 'DCT and DFT', $
           XPOS = 4 * x_size, YPOS = 0

                                ; Display the DCT
   TV, HIST_EQUAL(ALOG10(output_image)), 0

                                ; Display the DFT
   TV, HIST_EQUAL(ALOG10(ABS(fft(image0)))), 1

   CURSOR, unused_cursor_x_pos, unused_cursor_y_pos, 4

   WDELETE, 11
endif



; Return the transformed image
return, output_image

end
