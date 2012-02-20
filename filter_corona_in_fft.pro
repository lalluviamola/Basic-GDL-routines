PRO FILTER_CORONA_IN_FFT, image, r_min, r_max
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure deletes those frecuency components in the fourier
; spectrum (shifted in directions x and y by the half of their
; respective sizes) which are inside a circular corona.
;
; The procedure alos shows original and final image in front of their
; power spectrum.
;
; WARNING: ONLY TESTED with GRAYSCALE IMAGES
;
; Input:          image   image to filter
;                 r_min
;                 r_max
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

; Set graphic device to INDEXED
DEVICE, DECOMPOSE = 0

; Open graphic window with 2 quadrants
x_size = (SIZE(image))[1]
y_size = (SIZE(image))[2]

WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 400, TITLE = 'Original image and Power Spectrum'

; Load Grayscale color table
LOADCT, 0

; Display original image in quadrant 0
TVSCL, image, 1

; Derive power spectrum
fti = FFT(image)
fsp = ABS(fti)
psp = fsp^2

; Display power spectrum in quadrant 1
TVSCL, SHIFT(ALOG10(psp), x_size/2, y_size/2), 0

; Activate graphic cursor to wait for mouse click
PRESS_MOUSE

; Apply shift on real and imaginary parts of Fourier transform
fts_re = SHIFT(REAL_PART(fti), x_size/2, y_size/2)
fts_im = SHIFT(IMAGINARY(fti), x_size/2, y_size/2)

; Rebuild complex transform with shifted Re and Im components
fts = COMPLEX(fts_re, fts_im)

; Zero Fourier components in a circular corona between r_min and r_max
for i=0, x_size - 1 do begin
   for j = 1, y_size -1 do begin
      if (sqrt((i - 199)^2 + (j - 199)^2) gt r_min)  and $
         (sqrt((i - 199)^2 + (j - 199)^2) lt r_max) then $
            fts[i,j] = COMPLEX(0.0001, 0.00001)
   endfor
endfor

; Open graphic window with 2 quadrants
WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 400, TITLE = 'Masked Power Spectrum and Filtered image'

; Display power spectrum in quadrant 1
TVSCL, ALOG10((ABS(fts))^2), 0

; Shift back Re and Im components of Fourier transform
fti_re  = SHIFT(REAL_PART(fts), -x_size + 1, -y_size + 1)
fti_im  = SHIFT(IMAGINARY(fts), -x_size + 1, -y_size + 1)

; Rebuild complex Fourier transform
fti = COMPLEX(fti_re, fti_im)

; Get filtered image by inverse Fourier transform
fim = ABS(FFT(fti, 1))

; Display filtered image in quadrant 1
TVSCL, fim, 1

; Acivate graphic cursor to wait for mouse click
PRESS_MOUSE

WDELETE, 1, 2

END
