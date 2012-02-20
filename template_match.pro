PRO TEMPLATE_MATCH
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure identifies a feature on an image via template
; matching, i.e., by searching the maxima of the correlation between
; the image to be analyzed and a template sub-image, which is
; interactively selected from the original image.
;
; An external simple image file is requested.
;
; Input:          -
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

; Load in the sample text image and convert

READ_JPEG, '/home/lluvia/Desktop/Text.jpg', image, /GRAYSCALE

; Determine the size of the image
x_size = (SIZE(image))[1]
y_size = (SIZE(image))[2]

LOADCT, 0

CENTER_WINDOW_POS, x_size, y_size, x_win_pos, y_win_pos
WINDOW, 1, XSIZE = 2*x_size, YSIZE = y_size, XPOS=x_win_pos, YPOS=y_win_pos, $
        TITLE= 'Feature Recognition via Template'
TV, image, 0

; Require the selection of a sub-image with the cursor
                                ; Lower Left Corner
PRINT, 'Click on template Lower Left corner'
CURSOR, x1, y1, 4, /DEV
                                ; Upper Right corner
PRINT, 'Click on template Upper Right corner'
CURSOR, x2, y2, 4, /DEV

; Avoids human-errors
if x2 lt x1 then begin
   x3 = x2
   x2 = x1
   x1 = x3
endif

if y2 lt y1 then begin
   y3 = y2
   y2 = y1
   y1 = y3
   endif

; Derive the size of the sub-image
tmpl_x_size = x2 - x1 + 1
tmpl_y_size = y2 - y1 + 1

; Create a byte array sized accordingly
tmpl = BYTARR(tmpl_x_size, tmpl_y_size)

; Fill in the byte array with the sub-image extracted from the
; original image by array slicing

tmpl = image[ x1 : x2 , y1 : y2 ]

; Create a byte array to host the template;
; it MUST have the same size of the original image to avoid
; periodicity problems in FFT

tmpl_page_sized = BYTARR(x_size, y_size)

; Set all array values to the max LUT value
tmpl_page_sized[*,*] = 255

; Copy the sub-image to the center of the template
tmpl_page_sized[ FLOOR(x_size / 2. - tmpl_x_size / 2.) : FLOOR(x_size/2. + tmpl_x_size/2. - 1), $
                 FLOOR(y_size / 2. - tmpl_y_size / 2.) : FLOOR(y_size/2. + tmpl_y_size/2. - 1)  $
               ] = tmpl[ 0 : (tmpl_x_size - 1), 0 : (tmpl_y_size - 1)]

; Display the template in the right quadrant
TV, tmpl_page_sized, 1

PRESS_MOUSE

; Compute the correlation between the original image and the template
; rotated by PI
correlation = FFT(image) * FFT(ROTATE(tmpl_page_sized, 2))
correlation = ABS(FFT(correlation, 1))
correlation = SHIFT(correlation, x_size / 2., y_size / 2.)

TV, BYTSCL(correlation), 1

PRESS_MOUSE

; Determine the maximum value in the correlation
max_corr = MAX(correlation)

; Identify the coordinates of the correlation array elements with
; value equal to maximum
feature_coord = WHERE(correlation ge (max_corr*(1 - 0.0001)), n_found)

; Print the number of identified elements on the console
PRINT, 'N. of identified elements: ', n_found

; Decompose feature address into x and y adresses
;----------------------------------
;  address = x + x_size * y
;  y = INT(address) / INT(x_size)
;  x = address - x_size * y
;---------------------------------

x_found = LONARR(n_found)
y_found = LONARR(n_found)

for i = 0, n_found - 1 do begin
   y_found[i] = feature_coord[i] / x_size
   x_found[i] = feature_coord[i] - x_size * y_found[i]
endfor

; Plot boxes around identified positions in correlation array in right
; quadrant
PLOTS, x_found + x_size, y_found, PSYM = 6, SYMSIZE = 2.1, COLOR = 0, $
       CLIP = [0, 0, x_size - 1, y_size - 1], NOCLIP = 0, /DEV

PRESS_MOUSE

; Delete window
WDELETE

end
