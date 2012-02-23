PRO SPATIAL_TRANSFORMATION_EXAMPLE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure realizes a series of spatial transformations and
; visualizes the result in 2-D and 3-D
;
; Input:          -
; Output:         -
; External calls: SPATIAL_TRANSFORMATION
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

; Set graphics mode to indexed COLOR TABLE
DEVICE, DECOMPOSED = 0

; Load color palette
LOADCT, 39

; Define an asymetric 2-D Gaussian pseudo-image
; (small size helps in emphasizing various aspects
;  in the transformed image, which would be smoothed
;  out in a large image)


; Define size of the Gaussian (it is defined here, so it is NOT
; RElATED TO ANY SIZE of any window or image)
x_size_1 = 64
y_size_1 = 64

sigma_x_1 = x_size_1 / 6
sigma_y_1 = y_size_1 / 6

; Create the gaussian byte-array (it is returned really a byte-array!)
original_image = GAUSSIAN_2D(x_size_1, y_size_1, sigma_x_1, sigma_y_1)

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
; * !X.WINDOW, !Y.WINDOW   -- normalized coordinates of axis begin and
;                             end points.
; * !D.X_VSIZE, !D.Y_VSIZE -- size of the visible area of window (pxs)

plot_win_x_size = !X.WINDOW * !D.X_VSIZE
plot_win_y_size = !Y.WINDOW * !D.Y_VSIZE

; Define size of image to fit the plot window
image_x_size = plot_win_x_size[1] - plot_win_x_size[0] + 1
image_y_size = plot_win_y_size[1] - plot_win_y_size[0] + 1

; Display original image rebinned according to new size
TV, CONGRID(original_image, image_x_size, image_y_size), plot_win_x_size[0], plot_win_y_size[0]

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

; Undersample the image
undersampled_image = SPATIAL_TRANSFORMATION(image, /UNDERSAMPLE, REBIN_FACTOR=rebin_factor)

x_size_2 = (SIZE(undersampled_image))[0]
y_size_2 = (SIZE(undersampled_image))[1]

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
VIS_2D, x_standard_size, y_standard_size, win_title, $              
        original_image, x_size_1, y_size_1,          $
        undersampled_image, x_size_2, y_size_2,      $
        x_title_1, y_title_1, title_1, x_title_2,y_title_2, title_2

; Activate graphic cursor and wait for key pressed,
PRESS_MOUSE



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Oversampling

; Set rebinning factor (same for both x- and y-axis to
;  preserve image aspect ratio)
rebin_factor = 2

; Oversample the image
integer_oversampled_image = SPATIAL_TRANSFORMATION(image, /OVERSAMPLE, REBIN_FACTOR=rebin_factor)

x_size_2 = (SIZE(integer_oversampled_image))[0]
y_size_2 = (SIZE(integer_oversampled_image))[1]



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
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        integer_oversampled_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        integer_oversampled_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OVERSAMPLING -- Expand image size by a non-integer factor via
;                 NEAREST NEIGHBOUR pixel attribute assignment

; Set rebinning factor (same for both x- and y-axis to
;                       preserve image aspect radio)
rebin_factor = 2.7

real_nearest_oversampled_image = SPATIAL_TRANSFORMATION(image, /UNDERSAMPLE, REBIN_FACTOR=rebin_factor, /NEAREST_NEIGHBOUR)

x_size_2 = (SIZE(real_nearest_oversampled_image))[0]
y_size_2 = (SIZE(real_nearest_oversampled_image))[1]


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
VIS_2D, x_standard_size, y_standard_size, win_title,                       $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        real_nearest_oversampled_image, x_size_2, y_size_2,                $
        title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        real_nearest_oversampled_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OVERSAMPLING -- Expand image size by a non-integer factor via
;                 bilinear interpolation in pixel  attribute
;                 assignment


rebin_factor = 2.7

real_bilinear_oversampled_image = SPATIAL_TRANSFORMATION(image, /UNDERSAMPLE, REBIN_FACTOR=rebin_factor, /BILINEAR)

x_size_2 = (SIZE(real_bilinear_oversampled_image))[0]
y_size_2 = (SIZE(real_bilinear_oversampled_image))[1]



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
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        real_bilinear_oversampled_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        real_bilinear_oversampled_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRANSLATION AND ROTATION -- Shift an image via nearest neighbour
;                             interpolation in pixel attribute assignment


; Set translation offset (pxs)
trans_values = [ 10, -10]    ; x and y-offset

; Set rotation angle
theta = -23. * !DTOR ; (radians)

nearest_transrot_image = SPATIAL_TRANSFORMATION(image,                       $
                                                /TRANSROT,                   $
                                                TRANS_VALUES = trans_values, $
                                                ROT_VALUE = theta,           $
                                                /NEAREST_NEIGHBOUR)

x_size_2 = (SIZE(nearest_transrot_image))[0]
y_size_2 = (SIZE(nearest_transrot_image))[1]



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
VIS_2D, x_standard_size, y_standard_size, win_title,                               $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1,         $
        nearest_transrot_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                               $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1,         $
        nearest_transrot_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRANSLATION AND ROTATION -- Shift  and rotate an image via bilinear
;                             interpolation in pixel attribute
;                             assignment

; Set rotation angle
theta = -23 * !DTOR             ; (radians)
trans_values = [10, -10]

bilinear_transrot_image = SPATIAL_TRANSFORMATION(image,                       $
                                                 /TRANSROT,                   $
                                                 TRANS_VALUES = trans_values, $
                                                 ROT_VALUE = theta,           $
                                                 /BILINEAR)

x_size_2 = (SIZE(bilinear_transrot_image))[0]
y_size_2 = (SIZE(bilinear_transrot_image))[1]


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
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        bilinear_transrot_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

; 3-D Visualization

; Draw 3-D plots

VIS_3D, x_standard_size, y_standard_size, win_title,                $
        original_image, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
        bilinear_transrot_image, x_size_2, y_size_2, title_2, x_title_2, y_title_2, 

; Wait for user-confirmation
PRESS_MOUSE

WDELETE, 1, 2

END
