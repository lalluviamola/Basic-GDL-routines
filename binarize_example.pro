PRO BINARIZE_EXAMPLE, threshold_level
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure load an existing image, convert it to grayscale and
; then transform it into a binary image obtained by aplying binary
; thresholding.
;
; Input:          threshold_level    (Optional. default is 100)
; Output:         -
; External calls: ImageBinarize      function(image_in,
;                                             threshold_level,
;                                             MODE=mode)
; 
; Programmer:    Daniel Molina García (based on M. Messerotti examples)
; Creation date: 18 October 2011
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

; Set grayscale threshold level if not passed as argument
if N_ELEMENTS(threshold_level) eq 0 then threshold_level=100

; Set indexed mode
DEVICE, DECOMPOSED = 0

; Load grayscale palette
LOADCT, 0

; Load an image from IDL directory by converting it to grayscale
filename = !DIR + '/examples/data/marsglobe.jpg'

READ_JPEG, filename, image, /GRAYSCALE;, /TWO_PASS_QUANTIZE

; Derive image size
im_size = SIZE(image)
x_size = im_size[1]
y_size = im_size[2]

; Derive centered position for graphic window
CENTER_WINDOW_POS, 2*x_size, y_size, x_win_pos, y_win_pos

; Open graphic window with doubled x-size to display two quadrants
WINDOW, 1, XSIZE = 2*x_size, YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
           TITLE = 'Original and binary Image'

; Display original image in left quadrant
TV, image, 0

; Write threshold level in left quadrant
XYOUTS, 0.005, 0.01, 'Threshold = ' + STRING(STRTRIM(threshold_level, 2)), /NORM

; Set binarization mode to 0 (level LE threshold) and display binarized image in right quadrant
TVSCL, BINARIZE(image, threshold_level, MODE=0), 1

; Write binarization mode in right quadrant
XYOUTS, 0.505, 0.01, 'Mode 0: LE Threshold', COLOR = 0, /NORM
CURSOR, xcpos, ycpos, 4

; Set binarization mode to 1 (level GT threshold) and show in right
; quadrant
TVSCL, BINARIZE(image, threshold_level, MODE=1), 1

; Write binarization mode in right quadrant
XYOUTS, 0.505, 0.01, 'Mode 1: GT Threshold', /NORM
CURSOR, xcpos, ycpos, 4

; Delete window
WDELETE

end
