PRO RADON_TRANSFORM_EXAMPLE
 
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
; Input:          -
; Output:         -
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

; Load mono-chrome image
READ_JPEG, '/home/lluvia/trunk/caca/images/text_angle.jpg', image_in, /GRAYSCALE

; Compute radon transform of image
image_out = RADON(image_in, RHO = rho, THETA = theta)

; Derive images size
x_size_in  = (SIZE(image_in ))[1]
y_size_in  = (SIZE(image_in ))[2]

x_size_out = (SIZE(image_out))[1]
y_size_out = (SIZE(image_out))[2]

; Visualization

; Define plot labels
win_title  = 'Dominant Direction Identification via Radon Transform'

title_1    = 'Original Image'
x_title_1  = '(pxs)'
y_title_1  = '(pxs)'

title_2    = 'Radon Transform'
x_title_2  = 'Theta [deg]'
y_title_2  = 'Rho [pxs]'

; Define range of values of original image (X, Y)
x_range = [ 0, x_size_in - 1 ]
y_range = [ 0, y_size_in - 1 ]

; Define range of values of randon transform (theta, rho)
theta_range = [ MIN(theta), MAX(theta) ] * !RADEG
rho_range   = [ MIN(rho)  , MAX(rho)   ]

; Initialize maximum values
rho_max   = 0.
theta_max = 0.

; Initialize straight line
line_start_point = [ 0., 0. ]
line_end_point   = [ 0., 0. ]

; Set indexed colortable display
DEVICE, DECOMPOSED = 0

; Load Grayscale colortable
LOADCT, 0

; Draw 2-D plots
VIS2D2A, image_in, image_out,                           $
         WTITLE   = win_title,                          $
         TITLE_1  = title_1,                            $
         XTITLE_1 = x_title_1, YTITLE_1  = y_title_1,   $
         TITLE_2  = title_2,                            $
         XTITLE_2 = x_title_2, YTITLE_2  = y_title_2,   $
         XRANGE_1 = x_range,   XRANGE_2  = theta_range, $
         YRANGE_1 = y_range,   YRANGE_2  = rho_range,   $
         LINE_START = line_start_point,                 $
         LINE_END   = line_end_point,                   $
         RHO_MAX  = rho_max,   THETA_MAX = theta_max

PRESS_MOUSE

; Determine maximum of Radon transform
max_radon = MAX(image_out)

; Determine address of maximum value
max_addr = WHERE(image_out eq max_radon)

; Decompose address into x and y address

;=================================
; image = [[(x0, y0), ..., (xn, y0)], [(x0, y1), ...,]...] 
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
x_line_2 = x_size_in - 1
y_line_2 = m * x_line_1 + q + y_size_in

; Redraw 2-D plots with identified line
win_title = 'Primary Direction Angle = ' + STRTRIM(STRING(theta_max), 2) + ' [deg]'

; Draw 2-D plots
VIS2D2A, image_in, image_out,                             $
         WTITLE   = win_title,                         $
         TITLE_1  = title_1,                           $
         XTITLE_1 = x_title_1, YTITLE_1  = y_title_1,  $
         TITLE_2  = title_2,                           $
         XTITLE_2 = x_title_2, YTITLE_2  = y_title_2,  $
         XMIN_1   = x_min_1,   XMAX_1    = x_max_1,    $
         YMIN_1   = y_min_1,   YMAX_1    = y_max_1,    $
         XMIN_2   = x_min_2,   XMAX_2    = x_max_2,    $
         YMIN_2   = y_min_2,   YMAX_2    = y_max_2,    $
         XLINE_1  = x_line_1,  YLINE_1   = y_line_1,   $
         XLINE_2  = x_line_2,  YLINE_2   = y_line_2,   $
         RHO_MAX  = rho_max,   THETA_MAX = theta_max

PRESS_MOUSE

WDELETE

END


