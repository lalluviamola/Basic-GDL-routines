FUNCTION GAUSSIAN_2, x_size, y_size, sigma_x, sigma_y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This function generates a (sigma_x, sigma_y) 2-D
; gaussian in a (x_size * y_size) array with values
; normilized to [0, 255]
;
; Input:          x_size  (pxs)
;                 y_size  (pxs)
;                 sigma_x (pxs)
;                 sigma_y (pxs)
; Output:         A normalized 2_D array
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

; Define a 2_D Buffer array
buffer = FLTARR(y_size, x_size)

; Define Gaussian center
x_0 = x_size / 2.
y_0 = y_size / 2.

; Convert sigmas to floating variables
sigma_x = FLOAT(sigma_x)
sigma_y = FLOAT(sigma_y)

; Compute the gaussian
for i=0, x_size - 1 do begin
   for j=0, y_size - 1 do begin
      buffer[i,j] = exp(-((i-x_0)^2 / (2. * sigma_x^2)) $
                        -((j-y_0)^2 / (2. * sigma_y^2)))
   endfor
endfor

; Return array with normalized Gaussian
RETURN, BYTSCL(buffer)

END
