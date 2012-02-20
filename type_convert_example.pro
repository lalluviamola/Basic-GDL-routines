PRO TYPE_CONVERT_EXAMPLE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure loads a TRUE COLOR image and display it in and along
; others in 4x4-images grapic window.
;
;  0. Original image
;  1. 0 --- indexed 
;  2. 0 --- grayscaled
;  3. 0 --- binarized (depending of a threshold)
;;
; Input:          -
; Output:         -
; External calls: -
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

; Load a TRUE COLOR IMAGE
READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image, TRUE = 1

;-------------------------------------
; Preparing the visual composition
;-------------------------------------

; Determine image size
image_size = SIZE(image, /DIMENSIONS)
x_size = image_size[1]
y_size = image_size[2]

; Determine max image size
max_size = MAX(image_size[1:2])

; Determine image aspect radio
aspect_ratio = FLOAT(x_size) / FLOAT(y_size)

; Compute the maximum size for a 4 quadrant graphic
; window according to the original image size and
; resize the image accordingly
case (max_size EQ x_size) of
   1 : begin
      x_size = 300
      y_size = x_size / aspect_ratio
      image = CONGRID(image, 3, x_size, y_size, /INTERP)
   end
   0 : begin
      y_size = 300
      x_size = aspect_ratio * y_size
      image = CONGRID(image, 3, x_size, y_size, /INTERP)
   end
endcase

; Open a centered window with 4 quadrants
CENTER_WINDOW_POS, 2 * x_size, 2 * y_size, x_win_pos, y_win_pos

WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
        TITLE = 'TRUE COLOR, INDEXED PSEUDO-COLOR, INDEXED GRAYSCALE, BINARY_IMAGE', $ 
        XPOS = x_win_pos, YPOS = y_win_pos



;------------------------------
; Images
;------------------------------

; TRUE COLOR image in quadrant 0
;------------------------------------------
; Set graphic display to TRUE COLOR MODE
DEVICE, DECOMPOSE=1

TV, image, /TRUE, 0

; Write image label on grapic window
; We set 255 instead of 256 as a security mesure
DEVICE, DECOMPOSE=0
XYOUTS, 0.005, 0.505, 'True Color', /NORM, COLOR = 255


; INDEXED image
;-----------------------------------------------

; Convert true color image to an indexed image
;  image is a     [3,w,h] array
;  image_psudo is [w,h] array
;  r is an array with r-components of the Color Table chosen by
;    COLOR_QUAN.
;  g, b has the same meaning
PSEUDO_COLOR, image, image_pseudo, r, g, b

; Set a graphic display to INDEXED MODE
DEVICE, DECOMPOSE = 0

; Load indexed color table returned by COLOR_QUAN
TVLCT, r, g, b

TV, image_pseudo, 1

; Write image label on graphic window
XYOUTS, 0.505, 0.505, 'Pseudo-Color', /NORM, COLOR = 255

; Grayscale INDEXED image
;---------------------------------------------

; Load a grayscale ColorTable by equaling the G and B palette components to
; the R (given by COLOR_QUAN)
; Teacher said that it should be fine to make an average
; between RGB vectors, but using only the red one works 
average_component = (r+g+b)/3
TVLCT, average_component, average_component, average_component

TV, image_pseudo, 2

; Write image label on graphic windows
XYOUTS, 0.005, 0.005, 'Grayscale', /NORM, COLOR = 255


; BINARY image (as 2-color-indexed)
;---------------------------------------------------

; Create binary image from the original TRUE COLOR
image_pseudo = COLOR_QUAN(image, 1, r, g, b, COLORS=2)

; Display it
TVSCL, image_pseudo, 3

; Write image label on graphic windows
XYOUTS, 0.505, 0.005, 'Binary', /NORM, COLOR = 0

; Activate graphic cursor to wait for a mouse click
PRESS_MOUSE

; Delete graphic window
WDELETE, 1

end
