PRO FFT_BUTTERWORTH_FILTERING
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure performes imaeg filtering in the Fourier domain via
; Low-pass and High-pass Butterworth frequency filters
;
; WARNING: Operate ON A GRAYSCALE IMAGE ONLY!
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

; Read in "Mars" image from file and convert it to grayscale
READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image, $
           /GRAYSCALE

; Determine image size
image_size = SIZE(image)
x_size = image_size[1]
y_size = image_size[2]

; Derive centered window position with x size to host 2 quadrants
CENTER_WINDOW_POS, 2 * x_size, y_size, x_win_pos, y_win_pos

; Load grayscale palette
LOADCT, 0

; Open graphic window
WINDOW, 1, XSIZE = (2 * x_size), YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Original Grayscale Image and its Fourier Spectrum'

; Display original image in left quadrant
TV, image, 0, 0

; Compute FFT of image
image_fft = FFT(image)

; Display Fourier Spectrum in right quadrant
TV, HIST_EQUAL(SHIFT((ABS(image_fft)), x_size / 2, y_size / 2)), x_size, 0

PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Low-Pass Butterworth frequency filter
; n = 2     Filter order
; C = 1.0   Filter magnitude 50% at point R=R0
; C = 0.414 Filter magnitude 1/SQRT(2)
; LPB_filter = 1 / (1 + C * (R / R0))^(2*n)
;    with R - frequency image and R0 - nominal filter cut-off
;             frequency
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define filter parameters
n  = 2
c  = 1.0
r  = DIST(x_size, y_size)
r0 = 15.0

; Compute filter mask
n = 2
lpb_filter = 1.0 / (1.0D + C * (R/R0))^(2*n)

; Display filter mask (resampled for better display)
WINDOW, 1, XSIZE = (2 * x_size), YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Low-Pass Butterworth Filter Mask (3-D and 2-D View)'

SURFACE, CONGRID(SHIFT(LPB_filter, x_size / 2, y_size / 2), 100, 100), $
         INDGEN(x_size / 4.) * 4., INDGEN(y_size / 4.) * 4., AZ = 15,  $
         CHARSIZE = 2.0, POS = [0.05, 0.05, 0.45, 0.95]

TVSCL, (SHIFT(lpb_filter, x_size / 2., y_size / 2)), x_size, 0

PRESS_MOUSE

; Apply filter mask in Fourier domain and inverse transform the masked
; domain
filtered = REAL_PART(fft(image_fft * lpb_filter, 1))

; Display filtered image and its Fourier spectrum
WINDOW, 1, XSIZE = (2 * x_size), YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'Low-Pass Butterworth Filtered Image and its Fourier Spectrum'

TV, filtered, 0, 0
TV, HIST_EQUAL(SHIFT(ABS(FFT(filtered)), x_size / 2, y_size / 2)), x_size, 0

PRESS_MOUSE

;;;;;;;;;;;;;;;;;;;;,
; High-Pass Butterworth frequency filter
; 
; HPB_filter = 1 / (1 + C * (R0 / R))^(2*n)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define filter parameters
n  = 2
c  = 1.0
r  = DIST(x_size, y_size)
r0 = 50.0

; Compute filter mask
n = 2
hpb_filter = 1.0 / (1.0D + C * (R0/R))^(2*n)

; Display filter mask (resampled for better display)
WINDOW, 1, XSIZE = (2 * x_size), YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'High-Pass Butterworth Filter Mask (3-D and 2-D View)'

SURFACE, CONGRID(SHIFT(HPB_filter, x_size / 2, y_size / 2), 100, 100), $
         INDGEN(x_size / 4.) * 4., INDGEN(y_size / 4.) * 4., AZ = 15,  $
         CHARSIZE = 2.0, POS = [0.05, 0.05, 0.45, 0.95]

TVSCL, (SHIFT(hpb_filter, x_size / 2., y_size / 2)), x_size, 0

PRESS_MOUSE

; Apply filter mask in Fourier domain and inverse transform the masked
; domain
filtered = REAL_PART(fft(image_fft * hpb_filter, 1))

; Display filtered image and its Fourier spectrum
WINDOW, 1, XSIZE = (2 * x_size), YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
        TITLE = 'High-Pass Butterworth Filtered Image and its Fourier Spectrum'

TV, filtered, 0, 0
TV, HIST_EQUAL(SHIFT(ABS(FFT(filtered)), x_size / 2, y_size / 2)), 1

PRESS_MOUSE

WDELETE

END
