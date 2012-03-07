PRO VIS2D2A, image_1, image_2,                             $
             WTITLE   = win_title,                         $
             TITLE_1  = title_1,                           $
             XTITLE_1 = x_title_1, YTITLE_1 = y_title_1,   $
             TITLE_2  = title_2,                           $
             XTITLE_2 = x_title_2, YTITLE_2 = y_title_2,   $
             XMIN_1  = x_min_1,    XMAX_1   = x_max_1,     $
             YMIN_1  = y_min_1,    YMAX_1   = y_max_1,     $
             XMIN_2  = x_min_2,    XMAX_2   = x_max_2,     $
             YMIN_2  = y_min_2,    YMIN_2   = y_max_2,     $
             XLINE_1 = x_line_1,  YLINE_1   = y_line_1,    $
             XLINE_2 = x_line_2,  YLINE_2   = y_line_2,    $
             RHO_MAX = rho_max,   THETA_MAX = theta_max
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure visualizes 2 arrays in adjacents quadrants of a
; unique graphic window as colored images and with customizable axes
; ranges and allows the drawing of a straight line in the first
; quadrant and a marker in the second quadrant
;
; WARNING: Expection GRAYSCALE image
;
; Input:          image_?       array of ? image
;                 WTITLE        window title
;                 TITLE_?       title  of the ? graph
;                 XTITLE_?      title of the x-axis in ? graph
;                 YTITLE_?      y-size of the ? image
;                 XMIN_?        min axis value of the image ?
;                 XMAX_?        max axis value of the image ?
;                 XLINE_?       x coordinate of ? line point
;                 YLINE_?       y coordinate of ? line point
;                 RHO_MAX       y coordinate of Radon maximum
;                 THETA_MAX     x coordinate of Radon maximum
; Output:         -
; External calls: SCREEN_SIZE
;                 CENTER_WINDOW_POS
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

; Derive maximum screen size (pxs)
SCREEN_SIZE, x_screen, y_screen

; Derive images size
x_size_1  = (SIZE(image_in ))[1]
y_size_1  = (SIZE(image_in ))[2]

x_size_2 = (SIZE(image_out))[1]
y_size_2 = (SIZE(image_out))[2]

; Determine aspect ratio of image 1 (x : y)
ar_1 = FLOAT(x_size_1) / FLOAT(y_size_1)

; Determine aspect ratio of image 2 (x : y)
ar_2 = FLOAT(x_size_2) / FLOAT(y_size_2)

; Define size of a standard graphic window (pxs) according to the sum
; of images sizes as 90% of screen size in x or y direction according
; to dominant aspect ratio to allow the display of two windows in the
; viewport

; Two square quadrants
if (x_size_1 eq y_size_1) and (x_size_2 eq y_size_2) then begin

   ; x size of 1st quadrant as 1/2 of 90% of screen x size
   x_size_quad_1 = (1. / 2.) * 0.9 * x_screen

   ; y_si
