FUNCTION RADON_TRANSFORM, image_in
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure identifies dominant directions in a grayscale image
; by detecting the maxima in the Radon domain {Rho, Theta}, where Rho
; is the distance of the line from the origin of the Cartesian
; reference system and Theta is the anticlockwise angle between Rho
; and the x axis.
;
; WARNING : Expecting GRAYSCALE image
;
;
; Input:          image_in
; Output:         image_out
; External calls: -
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: 7-March-2012
; Environment:   i686 GNU/Linux 2.6.32-38-generic Ubuntu
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

; Set indexed colortable display
DEVICE, DECOMPOSED = 0

; Load Grayscale colortable
LOADCT, 0

; Compute radon transform of image
image_out = RADON(image, RHO = rho, THETA = theta)

; Derive images size
in_x_size  = (SIZE(image_in ))[1]
in_y_size  = (SIZE(image_in ))[2]

out_x_size = (SIZE(image_out))[1]
out_y_size = (SIZE(image_out))[2]

; Visualization

; Define plot labels
win_title  = 'Dominant Direction Identification via Radon Transform'

title_1    = 'Original Image'
x_title_1  = '(pxs)'
y_title_1  = '(pxs)'

title_2    = 'Radon Transform'
x_title_2  = 'Theta [deg]'
y_title_2  = 'Rho [pxs]'

; Define ...
x_min_1 = 0
x_max_1 = x_size_in - 1
y_min_1 = 0
y_max_1 = y_size_in - 1

x_min_2 = MIN(theta) * !RADEG
x_max_2 = MAX(theta) * !RADEG
y_min_2 = MIN(rho)
y_max_2 = MAX(rho)

x_line_1  = 0.
y_line_1  = 0.
x_line_2  = 0.
y_line_2  = 0.
rho_max   = 0.
theta_max = 0.

; Draw 2-D plots
VIS2D2A, image_in, image_out,                   $
         win_title,                             $
         title_1,                               $
         x_title_1, y_title_1,                  $
         title_2,                               $
         x_title_2, y_title_2,                  $
         x_min_1, x_max_1, y_min_1, y_max_1,    $
         x_min_2, x_max_2, y_min_2, y_max_2,    $
         x_line_1, y_line_1,                    $
         x_line_2, y_line_2,                    $
         rho_max, theta_max

PRESS_MOUSE

; Determine maximum of Radon transform
max_radon = MAX(image_out)

; Determine addresses of maximum
max_adrr = WHERE(image_2 eq max_radon)

; Decompose addresses into x and y addresses
;
;=================================
; address = x + x_size * y
; y =  INT(address) / INT(x_size)
; x = address - x_size * y
;=================================

max_y = max_addr / x_size_out
max_x = max_addr - x_size_out * max_y

PRINT, 'x coordinate of Radon maximum: ', max_x
PRINT, 'y coordinate of Radon maximum: ', max_y
PRINT, '          Radon maximum value: ', max_radon

; Derive Rho and Theta relevant to maximum
rho_max   = rho[max_y]
theta_max = theta[max_x] * !RADEG

; Print data (Rho, theta) coordinates of radon maximum
PRINT, 'Rho   coordinate of Radon maximum: ', rho_max
PRINT, 'Theta coordinate of Radon maximum: ', theta_max

; Compute m and  dominant straight line
m = TAN((90. + theta_max) * !DTOR)
q = rho_max / COS((90. - theta_max) * !DTOR)

; Derive start and end point of straight line
x_line_1 = 0
y_line_1 = q + y_size_in
x_line_2 = x_size_1 - 1
y_line_2 = m * x_line_out + q + y_size_in

; Redraw 2-D plots with identified line
win_title = 'Primary Direction Angle = ' + STRTRIM(STRING(theta_max), 2) + ' [deg]'

; Draw 2-D plots
VIS2D2A, image_in, image_out,                   $
         win_title,                             $
         title_1,                               $
         x_title_1, y_title_1,                  $
         title_2,                               $
         x_title_2, y_title_2,                  $
         x_min_1, x_max_1, y_min_1, y_max_1,    $
         x_min_2, x_max_2, y_min_2, y_max_2,    $
         x_line_1, y_line_1,                    $
         x_line_2, y_line_2,                    $
         rho_max, theta_max

PRESS_MOUSE

WDELETE

END


