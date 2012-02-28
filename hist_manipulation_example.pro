PRO HISTO_MANIPULATION
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure performs various histogram manipulations
; ON A GRAYSCALE IMAGE
;
; Input:          -
; Output:         -
; External calls: SCREEN_SIZE
;                 CENTER_WINDOW_POS
;                 DRAW_HISTOGRAM
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

; Derive maximum screen  size (pxs)
SCREEN_SIZE, x_screen, y_screen

; Define size of a standard graphic window (pxs) as 1/2 of 90 % of
; screen size to allow the display of two windows in the viewport
x_standard_size = FLOOR(0.5, * 0.9 + x_screen) 
y_standard_size = x_standard_size

; Derive centered window position
CENTER_WINDOW_POS, 2 * x_standard_size, y_standard_size, x_win_pos, y_win_pos

; Set indexed colortable display
DEVICE, DECOMPOSED = 0

; Load a grayscale palette
LOADCT, 0

; Get a grayscale image of Mars by direct conversion from image file
READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image, $
           /GRAYSCALE

; Determine image size
image_size = SIZE(image)


; Are theese indexes ok?????
x_size_1 = image_size[1]
y_size_1 = image_size[2]

; Resample image to fit quadrant size
image = CONGRID(image, x_standard_size * 0.9, y_standard_size * 0.9, /INTERP)

; --------------------------- ORIGINAL IMAGE

; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Original Image'

; Display original image
TV, image, 0

; Display histogram
DRAW_HISTOGRAM, image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine max index (it will be used by next transformations)
W = MAX(image)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;------------------------------ NEGATIVE IMAGE
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Negative Image'

; Perform negative transformation
modified_image = W - image

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE


;------------------------------ DECREASE IMAGE BRIGHTNESS
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Image Brightness Decrease'

; Perform negative transformation
modified_image = image - W * 0.1

; Display modified image
TV, modified_image,  0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE


;------------------------------ INCREASE IMAGE BRIGHTNESS
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Image Brightness Increase'

; Perform negative transformation
modified_image = image + W * 0.2

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE


;------------------------------ IMAGE CONTRAST DECREASE
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Image Contrast Decrease'

n = 0.5

; Perform negative transformation
modified_image = BYTSCL(FLOAT(image)^n / FLOAT(W)^(n-1))

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE

;------------------------------ IMAGE CONTRAST INCREASE
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Image Contrast Increase'

n = 2

; Perform negative transformation
modified_image = BYTSCL(FLOAT(image)^n / FLOAT(W)^(n-1))

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE

;------------------------------ CONTRAST ENHANCEMENT VIA BYTE SCALING
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos, TITLE = 'Contrast Enhancement via Byte Scaling'

; Perform negative transformation
modified_image = BYTSCL(image)

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE

;------------------------------ CONTRAST ENHANCEMENT VIA
;                               HISTOGRAM EQUALIZATION
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos,                      $
        TITLE = 'Contrast Enhancement via Histogram Equalization'

; Perform negative transformation
modified_image = HIST_EQUAL(image)

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE

;------------------------------ CONTRAST ENHANCEMENT VIA ADAPTATIVE
;                               HISTOGRAM EQUALIZATION
; Open window
WINDOW, 1, XSIZE = 2 * x_standard_size, YSIZE = y_standard_size, $
        XPOS = x_win_pos, YPOS = y_win_pos,                      $
        TITLE = 'Contrast Enhancement via Adaptative Histogram Equalization'

; Perform negative transformation
modified_image = ADAPT_HIST_EQUAL(image)

; Display negative image
TV, modified_image, 0

; Display histogram
DRAW_HISTOGRAM, modified_image, 0, 255, 0.55, 0.1, 0.95, 0.9

PRESS_MOUSE

WDELETE

END
