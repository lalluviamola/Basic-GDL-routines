PRO SPATIAL_TRANSFORMATION
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure realizes a series of spatial transformations and
; visualizes the result in 2-D and 3-D
;
; Input:          -
; Output:         -
; External calls: GAUSSIAN_2D           function
;                 SCREEN_SIZE           procedure
;                 CENTER_WINDOW_POS     procedure
;                 VIS_2D                procedure
;                 VIS_3D                procedure
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

; Derive maximum screen size (pxs)
SCREEN_SIZE, x_screen, y_screen

; Define size of a standard graphic window (pxs)
; as 1/2 of 90 % of screen size to allow the display
; of two windows in the viewport

x_standard_size = FLOOR(0.5 * 0.9 * x_screen)
y_standard_size = x_standard_size

; Set graphics mode to indexed CT
DEVICE, DECOMPOSED = 0

; Load 32-color palette
LOADCT, 39

; Define an asymetric 2-D Gaussian pseudo-image
; (Small size helps in emphasizing various aspects
;  in the transformed image, which would be smoothed
;  out in a large image)

x_size_1 = 64
y_size_1 = 64

sigma_x_1 = x_size_1 / 6
sigma_y_1 = y_size_1 / 6

image_1 = GAUSSIAN_2D(x_size_1, y_size_1, sigma_x_1, sigma_y_1)

; Define centered window origin based on window size
CENTER_WINDOW_POS, x_standard_size, y_standard_size, x_win_pos, y_win_pos

; Open window
WINDOW, 1, XSIZE = x_standard_size, YSIZE = y_standard_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = '2-D Gaussian -- Original Image'

; Draw axes based on image size
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1), XSTYLE = 1, YSTYLE = 1,          $
      XTITLE = '(pxs)', YTITLE = '(pxs)', TITLE = 'Original Image: '    +    $
      STRTRIM(STRING(x_size_1), 2) + 'x' + STRTRIM(STRING(y_size_1), 2) +    $
      ' pxs 2-D Gaussian', /NODATA, /NOERASE, POSITION = [0.1, 0.1, 0.9, 0.9]

; Determine size of plot window as defined by the PLOT procedure
; * !X.WINDOW, !Y.WINDOW   -- normalized coordinates of axis end points
; * !D.X_VSIZE, !D.Y_VSIZE -- size of the visible area of window (pxs)

plot_win_x_size = !X.WINDOW * !D.X_VSIZE
plot_win_y_size = !Y.WINDOW * !D.Y_VSIZE

; Define size of image to fit the plot window
image_x_size = plot_win_x_size[1] - plot_win_x_size[0] + 1
image_y_size = plot_win_y_size[1] - plot_win_y_size[0] + 1

; Display original image rebinned according to new size
TV, CONGRID(BYTSCL(image_1), image_x_size, image_y_size), plot_win_x_size[0], plot_win_y_size[0]

; Redraw axes 
PLOT, FINDGEN(x_size_1), FINDGEN(y_size_1), XSTYLE = 1, YSTYLE = 1,          $
      XTITLE = '(pxs)', YTITLE = '(pxs)', TITLE = 'Original Image: '    +    $
      STRTRIM(STRING(x_size_1), 2) + 'x' + STRTRIM(STRING(y_size_1), 2) +    $
      ' pxs 2-D Gaussian', /NODATA, /NOERASE, POSITION = [0.1, 0.1, 0.9, 0.9]

PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UnderSampling -- Reduce image size by an integer factor

; Set rebinning factor (same for both x- and y-axis to
;  preserve image aspect ratio)

rebin_factor = 4

; Derive size of rebinned image
x_size_2 = FLOOR(x_size_1 / rebin_factor)
y_size_2 = FLOOR(y_size_1 / rebin_factor)

; Create byte-type array to store rebinned image
image_2 = BYTARR(x_size_2, y_size_2)

; Rebin image

; Scan rebinned image
for x2 = 0, x_size_2 - 1 do begin
   for y2 = 0, y_size_2 - 1 do begin

      ; Reset summation buffer
      sum = 0.

      ; Sum pixel attributes of original image in a square window
      ; of size (rebin_factor) and origin based on the inverse 
      ; transform of the pixel address in the rebinned image
      for x1 = x2 * rebin_factor, (x2 + 1) * rebin_factor - 1 do begin
         for y1 = y2 * rebin_factor, (y2 + 1) * rebin_factor - 1 do begin
            
            sum = sum + image_1[x1, y1]

         endfor
      endfor
      
      ; Assign the mean of the pixel attributes in the window
      ; to the transformated pixel in the rebinned image
      image_2[x2, y2] = sum / rebin_factor^2
   endfor
endfor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2-D visualization

; Define plot labels
win_title = 'Image Undersampling by Integer Factor = ' + $
            STRTIM(STRING(rebin_factor), 2)
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'
title_1   = 'Original Image: ' + STRTRIM(STRING(x_size_1), 2) + $
            ' x ' + STRTRIM(STRING(y_size_1), 2) + 'pxs'
x_title_2 = '(pxs)'
y_title_2 = '(pxs)'
title_2   = 'Rebinned Image: ' + STRTRIM(STRING(x_size_2), 2) + 'x' + $
            STRTIM(STRING(y_size_2), 2) + 'pxs'

; Draw 2-D plots
VIS_2D, x_standard_size, y_standard_size, win_title, image_1, x_size_1, y_size_1, $
        image_2, x_size_2, y_size_2, x_title_1, y_title_1, title_1, x_title_2,    $
        y_title_2, title_2

; Activate graphic cursor and wait for key pressed,
PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OverSampling -- Expand image size by an integer factor

; Set rebinning factor (same for both x- and y-axis to
;  preserve image aspect ratio)
rebin_factor = 2

; Derive size of rebinned image
x_size_2 = FLOOR(x_size_1 * rebin_factor)
y_size_2 = FLOOR(y_size_1 * rebin_factor)

; Create byte-type array to store rebinned image
image_2 = BYTARR(x_size_2, y_size_2)

; Rebin image

; Scan rebinned image
for x2 = 0, x_size_2 - 1 do begin
   for y2 = 0, y_size_2 -1 do begin

      ; Pixel attributes in original image are replicated
      ; in rebinned image a number of times defined by the
      ; rebinning factor
      image_2[x2, y2] = image_1[x2 / rebin_factor, y2 / rebin_factor]
   endfor
endfor

; 2-D Visualization
; Define plot labels
win_title = 'Image Oversampling by Integer Factor N = ' + STRTRIM(STRING(rebin_factor), 2)

title_1   = 'Original Image: ' + STRTRIM(STRING(x_size_1), 2) + ' x ' + $
            STRTRIM(STRING(y_size_1), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'

title_2   = 'Rebinned Image: ' + STRTRIM(STRING(x_size_2), 2) + ' x ' + $
            STRTRIM(STRING(y_size_2), 2) + ' pxs'
x_title_2 = '(pxs)'
y_title_2 = '(pxs)'

; Draw 2-D plots
VIS_2D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OVERSAMPLING -- Expand image size by a non-integer factor via
;                 nearest neighbour pixel attribute assignment

; Set rebinning factor (same for both x- and y-axis to
;                       preserve image aspect radio)

rebin_factor = 2.7

; Derive size of rebinned image
x_size_2 = ROUND(x_size_1 * rebin_factor)
y_size_2 = ROUND(y_size_1 * rebin_factor)

; Create byte-type array to store rebinned image
image_2 = BYTARR(x_size_2 - 1) do begin

; Rebin image

; Scan rebinned image
for x2 = 0, x_size_2 -1 do begin
   for y_2 = 0, y_size_2 -1 do begin

                                ; Pixel attributes in original image
                                ; are replicated in rebinned image a
                                ; number of times defined by the
                                ; rebinning factor and pixel adresses
                                ; are rounded  to the nearest integer
                                ; (nearest neighbour approximation)
      x1 = ROUND(x2 / rebin_factor)
      y1 = ROUND(y2 / rebin_factor)

      if ( x1 GT 0 ) AND ( x1 LE (x_size_1 - 1) ) AND ( y1 GE 0 ) AND ( y1 LE (y_size_1 - 1)) then begin
         image_2[x_2, y_2] = 0
      endelse
   endfor
endfor

; 2-D Visualization

; Define plot labeles

win_title = 'Nearest Neighbour Image Oversampling by Non-Integer factor N = ' $
            + STRTRIM(STRING(rebin_factor), 2)

title_1  = 'Original image: ' + STRTRIM(STRING(x_size_1), 2) + 'x'            $
           + STRTRIM(STRING(y_size_1), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'

title_2   = 'Rebinned image: ' + STRTRIM(STRING(x_size_2), 2) + 'x'            $
           + STRTRIM(STRING(y_size_2), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'


; Draw 2-D plots
VIS_2D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OVERSAMPLING -- Expand image size by a non-integer factor via
;                 bilinear interpolation in pixel  attribute
;                 assignment


; Set rebinning factor (same for both x- and y-axis to
;                       preserve image aspect radio)

rebin_factor = 2.7

; Derive size of rebinned image
x_size_2 = ROUND(x_size_1 * rebin_factor)
y_size_2 = ROUND(y_size_1 * rebin_factor)

; Create byte-type array to store rebinned image
image_2 = BYTARR(x_size_2 - 1) do begin

; Rebin image

; Scan rebinned image
for x2 = 0, x_size_2 -1 do begin
   for y_2 = 0, y_size_2 -1 do begin

                                ; Pixel attributes in original image
                                ; are replicated in rebinned image a
                                ; number of times defined by the
                                ; rebinning factor and pixel adresses
                                ; are derived via bilinear
                                ; interpolation of  pixel attributes

                                ; Derive (floating) pixel address in
                                ; rebinned image
      x = x2 / rebin_factor
      y = y2 / rebin_factor

                                ; Extract integer part of pixel address
      x_i = FLOOR(x)
      y_i = FLOOR(y)

                                ; Extract fractional part of pixel address
      x_f = x - x_i
      y_f = y - y_i

                                ; If pixel address in original image
                                ; does not exceed image range.

                                ; Why 2 instead of 1 ??)
      if ( x1 GT 0 ) AND ( x1 LE (x_size_1 - 2) ) AND ( y1 GE 0 ) AND ( y1 LE (y_size_1 - 2)) then begin

                                ; Compute bilineal interpolation
                                ; coefficients from original image
                                ; pixel attributes
         c1 = image_1[x_i    , y_i    ]
         c2 = image_1[x_i    , y_i + 1]
         c3 = image_1[x_i + 1, y_i    ]
         c3 = image_1[x_i + 1, y_i + 1]
         
                                ; Apply bilineal interpolation formula
                                ; to define the pixel attribute in
                                ; rebinned image as interpolation of
                                ; pixel attributes in original image
         image_2[x2, y2] =   c1 * (1 - x_f) * (1 - y_f) $
                           + c2 * (1 - x_f) *    y_f    $
                           + c3 *    x_f    * (1 - y_f) $
                           + c4 *    x_f    *    y_f
      endif else begin

                                ; Pixel addres in original image
                                ; exceeds allowed range:
                                ; -- set pixel attribute in rebinned
                                ; image to zero
         image_2[x2, y2] = 0

      endelse
   endfor
endfor

; 2-D Visualization

; Define plot labeles

win_title = 'Bilinear interpolation Image Oversampling by Non-Integer factor N = ' $
            + STRTRIM(STRING(rebin_factor), 2)

title_1  = 'Original image: ' + STRTRIM(STRING(x_size_1), 2) + 'x'            $
           + STRTRIM(STRING(y_size_1), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'

title_2   = 'Rebinned image: ' + STRTRIM(STRING(x_size_2), 2) + 'x'            $
           + STRTRIM(STRING(y_size_2), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'


; Draw 2-D plots
VIS_2D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRANSLATION AND ROTATION -- Shift an image via nearest neighbour
;                             interpolation in pixel attribute assignment


; Set translation offset (pxs)
delta_x =  10    ; x-offset
delta_y = -10    ; y-offset

; Derive original image center
x_center_1 = x_size_1 / 2
y_center_1 = y_size_1 / 2

; Set rotation angle
theta = -23. * !DTOR ; (radians)

; Defined angular constants to minimize computations
sin_theta = SIN(theta)
cos_theta = COS(theta)

; Set size of rotated image equal to size of original image
x_size_2 = x_size_1
y_size_2 = y_size_1

; Create byte-type array to store rebinned image
image_2 = BYTARR(x_size_2, y_size_2)

; Rotate image

; Scan rotated image
for x2 = 0, x_size_2 - 1 do begin
   for y_2 = 0, y_size_2 - 1 do begin

                                ; Image is shifted by (delta_x,
                                ; delta_y) and rotated by (theta)
                                ; around its center. Nearest neighbour
                                ; approximation is used in new image
                                ; pixel attribute assignment

                                ; Derive (floating) pixel address in
                                ; rotated image by applying inverse transformation

      x1 = ROUND(x_center_1 + (x2 - x_center_1 - delta_x) * cos_theta - (y2 - yc - delta_y) * sin_theta)
      y1 = ROUND(y_center_1 + (x2 - x_center_1 - delta_x) * sin_theta - (y2 - yc - delta_y) * cos_theta)

                                ; Why 2 instead of 1 ??)
      if ( x1 GT 0 ) AND ( x1 LE (x_size_1 - 2) ) AND ( y1 GE 0 ) AND ( y1 LE (y_size_1 - 2)) then begin

                                ; Assign pixel attribute as
                                ; correspondent one in original image
         image_2[x2, y2] = image_1[x1, y1]

      endif else begin

                                ; Pixel address in original  image
                                ; exceeds allowed range.
                                ; Set pixel attribute in rotated image
                                ; to zero
         image_2[x2, y2] = 0
      endelse
   endfor
endfor

; 2-D Visualization

; Define plot labeles

win_title = 'Nearest Neighbour Image Shift and Rotation by Theta = ' $
            + STRTRIM(STRING(theta * !RADEG), 2) + ' deg'

title_1  = 'Original image: ' + STRTRIM(STRING(x_size_1), 2) + 'x'            $
           + STRTRIM(STRING(y_size_1), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'

title_2   = 'Shifted and rotated image: ' + STRTRIM(STRING(x_size_2), 2) + 'x'            $
           + STRTRIM(STRING(y_size_2), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'


; Draw 2-D plots
VIS_2D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRANSLATION AND ROTATION -- Shift  and rotate an image via bilinear
;                             interpolation in pixel attribute
;                             assignment

; Set translation offset (pxs)
delta_x = 10                    ; [ xc2 - xc1 ], xc2, xc1 -- coordinate of sifted and original reference origin
delta_y = -10                   ; [ yc2 - yc1 ]

; Derive original image center
xc_1 = x_size_1 / 2
yc_1 = y_size_1 / 2

; Set rotation angle
theta = -23 * !DTOR             ; (radians)

; Defined angular constants to minimize computations
sin_theta = SIN(theta)
cos_theta = COS(theta)

; Set size of rotated image equal to size of original image
x_size_2 = x_size_1
y_size_2 = y_size_1

; Create byte-type array to store rebinned image
image_2 = BYTARR(x_size_2, y_size_2)

; Rotate image

; Scan rotated image
for x2 = 0, x_size_2 - 1 do begin
   for y_2 = 0, y_size_2 - 1 do begin

                                ; Image is shifted by (delta_x,
                                ; delta_y) and rotated by (theta)
                                ; around its center. Bilinear
                                ; interpolation is used in new image
                                ; pixel attribute assignment

                                ; Derive (floating) pixel address in
                                ; rotated image by applying inverse transformation

      x1 = x_center_1 + (x2 - x_center_1 - delta_x) * cos_theta - (y2 - yc - delta_y) * sin_theta
      y1 = y_center_1 + (x2 - x_center_1 - delta_x) * sin_theta - (y2 - yc - delta_y) * cos_theta


                                ; Extract integer part of pixel
                                ; address
      x_i = FLOOR(x)
      y_i = FLOOR(y)

                                ; Extract fractional part of pixel
                                ; address
      x_f = x - x_i
      y_f = y - y_i


                                ; I pixel address in original image
                                ; does not exceed image range

                                ; Why 2 instead of 1 ??)
      if ( x1 GT 0 ) AND ( x1 LE (x_size_1 - 2) ) AND ( y1 GE 0 ) AND ( y1 LE (y_size_1 - 2)) then begin

                                ; Apply binlinear interpolation
                                ; formula to define the pisel
                                ; attribute in rotated image as
                                ; interpolation of pixel attributes in
                                ; original image
         image_2[x2, y2] =   c1 * (1 - x_f) * (1 - y_f) $
                           + c2 * (1 - x_f) *    y_f    $
                           + c3 *    x_f    * (1 - y_f) $
                           + c4 *    x_f    *    y_f



      endif else begin

                                ; Pixel address in original  image
                                ; exceeds allowed range.
                                ; Set pixel attribute in rotated image
                                ; to zero
         image_2[x2, y2] = 0
      endelse
   endfor
endfor

; 2-D Visualization

; Define plot labeles

win_title = 'Bilinear interpolation Image shift and Rotation by Theta = ' $
            + STRTRIM(STRING(theta * !RADEG), 2) + ' deg'

title_1  = 'Original image: ' + STRTRIM(STRING(x_size_1), 2) + 'x'            $
           + STRTRIM(STRING(y_size_1), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'

title_2   = 'Shifted and rotated image: ' + STRTRIM(STRING(x_size_2), 2) + 'x'            $
           + STRTRIM(STRING(y_size_2), 2) + ' pxs'
x_title_1 = '(pxs)'
y_title_1 = '(pxs)'


; Draw 2-D plots
VIS_2D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

WDELETE, 1, 2

END
