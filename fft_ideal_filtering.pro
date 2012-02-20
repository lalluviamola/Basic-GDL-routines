PRO FFT_IDEAL_FILTERING
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure performes ideal image filtering in the Fourier domain
; (Low-pass and High-pass filtering)
;
; WARNING: Operate ON A GRAYSCALE IMAGE ONLY
;
; Input:          -
; Output:         -
; External calls: CENTER_WINDOW_POS
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

; Set indexed colortable display
DEVICE, DECOMPOSED = 0

; Load Blue-White colortable

; Define sample pseudo-image size (square image!)
x_size = 220
y_size = 220

; Define image half-size
m = x_size / 2
n = y_size / 2

; Define image as byte array
image = BYTARR(x_size, y_size)

; Set to max value the attribute of a centered square domain
image[(m - 50):(m + 50), (n - 50):(n + 50)] $
   = 255

; Compute position of a centered window with 4 quadrants
CENTER_WINDOW_POS, 4 * x_size, y_size, x_win_pos, y_win_pos

; Open graphic window with 4 quadrants
WINDOW, 1, XSIZE = 4 * x_size, YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Image, Fourier Spectrum, Power Spectrum, Phase'

; Display original image in quadrant 0
TV, image, 0, 0

; Compute FFT of mage
image_fft = FFT(image)

; Compute Fourier Spectrum
image_fsp = ABS(image_fft)

; Display Fourier Spectrum in quadrant 1
TV, HIST_EQUAL(ALOG10(SHIFT(image_fsp, m, n))), 1

; Compute Power Spectrum
image_psp = ABS(image_fft)^2

; Display Power Spectrum in quadrant 2
TV, HIST_EQUAL(ALOG10(SHIFT(image_psp, m, n))), 2

; Compute Phase
phase = ATAN(IMAGINARY(image_fft)/REAL_PART(image_fft))

; Display Phase in quadrant 3
TV, HIST_EQUAL(ALOG10(phase)), 3

PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDEAL LOW-PASS FILTER with decreseing cut-off frecuency from 75 to 5
;                       step -15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Re-open graphic window with 4 quadrants
WINDOW, 1, XSIZE = 4 * x_size, YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Image, Fourier Spectrum, Power Spectrum, Filtered Image'

; Display original image in quadrant 0
TV, image, 0, 0

; Display Fourier Spectrum in quadrant 1
TV, ALOG10(SHIFT(image_fsp, m, n)), x_size, 0

; Start filtering loop
for cut_off = 75, 5, -15 do begin

   ; Shift fourier image
   shifted_fft = SHIFT(image_fft, m, n)

   ; Define filter in FFT domain
   filter_fft = shifted_fft

   ; Zero filter elements
   filter_fft[*, *] = 0

   ; Set filter elements according to selected square FFT domain
   filter_fft[      (m - cut_off):(m + cut_off), (n - cut_off):(n + cut_off)] $
      = shifted_fft[(m - cut_off):(m + cut_off), (n - cut_off):(n + cut_off)]

   ; Display filtered Fourier Spectrum
   TV, ALOG10(filter_fft), 2*x_size, 0

   ; FILTERED IMAGE = ABSOLUTE VALUE OF SHIFTED ANTITRANSFORM
   ; Display filtered Fourier Spectrum
   TV, ALOG10(ABS(SHIFT(FFT(filter_fft, 1), m, n))), 3*x_size, 0

   PRESS_MOUSE

endfor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDEAL HIGH-PASS FILTER with increasing cut-off frequency from 5 to
; 75 step +15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Re-open graphic window with 4 quadrants
WINDOW, 1, XSIZE = 4 * x_size, YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Image, Fourier Spectrum, Power Spectrum, Filtered Image'

; Display original image in quadrant 0
TV, image, 0, 0

; Display Fourier Spectrum in quadrant 1
TV, ALOG10(SHIFT(image_fsp, m, n)), x_size, 0

; Start filtering loop
for cut_off = 75, 5, -15 do begin

   ; Shift fourier image
   shifted_fft = SHIFT(image_fft, m, n)

   ; Define filter in FFT domain
   filter_fft = shifted_fft

   ; Set filter elements according to selected square FFT domain
   filter_fft[      (m - cut_off):(m + cut_off), (n - cut_off):(n + cut_off)] $
      = 0.0

   ; Display filtered Fourier Spectrum
   TV, ALOG10(filter_fft), 2*x_size, 0

   ; FILTERED IMAGE = ABSOLUTE VALUE OF SHIFTED ANTITRANSFORM
   ; Display filtered Fourier Spectrum
   TV, ALOG10(ABS(SHIFT(FFT(filter_fft, 1), m, n))), 3*x_size, 0

   PRESS_MOUSE

endfor

WDELETE, 1

END
