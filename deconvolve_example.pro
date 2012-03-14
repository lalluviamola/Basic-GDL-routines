PRO DECONVOLVE_EXAMPLE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure explore the deconvolution of an image affected by
; additive noise acording to the:
;
; * OPTIMUM LINEAR Wiener-Fourier deconvolution method
; * NON-LINEAR Richardson-Lucy deconvolution method
;
; A pseudo image is generated with a constant background and 4
; gaussian functions to simulate 4 point sources.
;
; This image is convolved with a gaussian function as a Point Spread
; Function to obtain a blurred image of the original point sources.
;
; A certain level of noise with normal distribution is added to the
; image based on the selected Signal-to-Noise-Ratio (SNR).
;
; The deconvolution methods are applied to such noise image.
;
; Input: -
; Output: -
; External calls: -
;
; Programmer: Daniel Molina García (based on M. Messerotti's examples)
; Creation date: 10-March-2012
; Environment: i686 GNU/Linux 2.6.32-38-generic Ubuntu
; Modified: -
; Version: 0.1
;
; License: Copyright 2011 Daniel Molina García
;
; This program is free software: you can redistribute it
; and/or modify it under the terms of the GNU General Public
; License as published by the Free Software Foundation,
; either version 3 of the License, or (at your option) any
; later version.
;
; This program is distributed in the hope that it will be
; useful, but WITHOUT ANY WARRANTY; without even the implied
; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
; PURPOSE. See the GNU General Public License for more
; details.
;
; You should have received a copy of the GNU General Public
; License along with this program. If not, see
; <http://www.gnu.org/licenses/>.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;----------------------
; Create OBJECT IMAGE
;----------------------

; Create an array of 256 x 256 floating-point elements
x_size = 256
y_size = 256

image_obj = FLTARR(x_size, y_size)

; Define a constant background level
background = 5

; Set parameters of Gaussian 1
x1 = 95
y1 = 174
a1 = 1000
s1 = 2

; Set parameters of Gaussian 2
x2 = 80
y2 = 79
a2 = 1200
s2 = 2

; Set parameters of Gaussian 3
x3 = 174
y3 = 158
a3 = 1400
s3 = 2

; Set parameters of Gaussian 4
x4 = 174
y4 = 79
a4 = 1600
s4 = 2

; Build object image
for i = 0, x_size - 1 do begin

for j = 0, y_size -1 do begin

image_obj[i,j] = background + a1 * exp(-(FLOAT( i-x1 )^2 + FLOAT( j-y1 )^2)/ ( 2*s1^2 ) ) $
                            + a2 * exp(-(FLOAT( i-x2 )^2 + FLOAT( j-y2 )^2)/ ( 2*s2^2 ) ) $
                            + a3 * exp(-(FLOAT( i-x3 )^2 + FLOAT( j-y3 )^2)/ ( 2*s3^2 ) ) $
                            + a4 * exp(-(FLOAT( i-x4 )^2 + FLOAT( j-y4 )^2)/ ( 2*s4^2 ) )

endfor

endfor

; Display Object image
WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Image with 4 point sources'

; Set graphic mode to indexed
DEVICE, DECOMPOSE = 0

; Load red Color Table
LOADCT, 3

; Display surface as shaded object
SHADE_SURF, image_obj, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15, $
XTITLE = '(pxs)', YTITLE = '(pxs)', CHARSIZE = 1.5

; Open a second window to display 2-D views
WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Image with 4 Point Sources'

; Display (resampled) object image
TVSCL, CONGRID(image_obj, 2 * x_size, 2 * y_size)

PRESS_MOUSE

;-------------------------------
; Define POINT SPREAD FUNCTION (psf)
;-------------------------------

image_psf = FLTARR(x_size, y_size)

s_psf = 30

for i = 0, x_size - 1 do begin

for j = 0, y_size -1 do begin

image_psf[i,j] = background + a1 * exp(-(FLOAT( i-x1 )^2 + FLOAT( j-y1 )^2)/ ( 2*s1^2 ) )

endfor

endfor

; Normalize PSF to unitary integral
image_psf = image_psf / TOTAL(image_psf)

; Display Object image
WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Gaussian Point Spread Function'

; Load red Color Table
LOADCT, 3

; Display surface as shaded object
SHADE_SURF, image_psf, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15, $
XTITLE = '(pxs)', YTITLE = '(pxs)', CHARSIZE = 1.5

; Open a second window to display 2-D views
WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Gaussian Point Spread Function'

; Display (resampled) object image
TVSCL, CONGRID(image_psf, 2 * x_size, 2 * y_size)

PRESS_MOUSE


;-----------------------------
; Create (OBJECT IMAGE * PSF)
;-----------------------------

; Convolve original image with PSF
image_conv = REAL_PART(SHIFT( $
FFT( FFT(image_obj) * FFT(image_psf), 1 ), $
x_size/2, y_size/2 ))

; Display Convolved image
WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Image convolved with Gaussian PSF'

; Display surface as shaded object
SHADE_SURF, image_conv, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15, $
XTITLE = '(pxs)', YTITLE = '(pxs)', CHARSIZE = 1.5

; Open a second window to display 2-D views
WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Image convolved with Gaussian PSF'

; Display (resampled) object image
TVSCL, CONGRID(image_conv, 2 * x_size, 2 * y_size)

PRESS_MOUSE


snr = 0
; Ask for SRN selection
repeat begin

READ, PROMPT = 'Enter SNR (5-1000): ', snr

endrep until (snr ge 5) && (snr le 1000)

; Add Gaussian noise to image according to selected SNR
image_conv = image_conv + RANDOMN(seed, x_size, y_size) $
+ (MAX(image_conv) - MIN(image_conv)) / snr

; Display noisy image
WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Noisy Image (SNR = ' + STRTRIM(STRING(snr), 2) + ')'

; Display surface as shaded object
SHADE_SURF, image_conv, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15, $
XTITLE = '(pxs)', YTITLE = '(pxs)', CHARSIZE = 1.5

; Open a second window to display 2-D views
WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Noisy Image (SNR = ' + STRTRIM(STRING(snr), 2) + ')'

; Display (resampled) object image
TVSCL, CONGRID(image_conv, 2 * x_size, 2 * y_size)

PRESS_MOUSE


; ---------------------
; Apply OPTIMUM Linear Wiener-Fourier Deconvolution
; ---------------------

; Aprozimate (at 0 order) signal power spectrum with data power
; spectrum
ps = ABS(FFT(image_conv))^2

; Aproximate noise power spectrum with high-frecuency data power
; spectrum
pn = MEAN(ps[64:127, 64:126])

; Approximate signal power spectrum with data power spectrum offset by
; noise power spectrum
ps = ps - pn

; Fourier transform PSF and normalize to 1.0 at frecuency [0, 0]
p = FFT(image_psf)
p = p/p[0, 0]

; Fourier transform data
d = FFT(image_conv)

; Define deconvolution filter and normalize to 1.0 at frecuency [0, 0]
h = COMPLEX( REAL_PART(p) - IMAGINARY(p) )/( ABS(p)^2 + pn / (ps * 0.001) )

h = h/h[0,0]

; Deconvolve data by filter
image_dec = REAL_PART(SHIFT(FFT(h * d, 1), x_size / 2, y_size / 2))

; Display deconvolved data
WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Wiener-Fourier Deconvolver Image (SNR = ' + STRTRIM(STRING(snr), 2) + ')'

; Display surface as shaded object
SHADE_SURF, image_dec, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15, $
XTITLE = '(pxs)', YTITLE = '(pxs)', CHARSIZE = 1.5

; Open a second window to display 2-D views
WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 2 * y_size, $
TITLE = 'Wiener-Fourier Deconvolver Image (SNR = ' + STRTRIM(STRING(snr), 2) + ')'

; Display (resampled) object image
TVSCL, CONGRID(image_dec, 2 * x_size, 2 * y_size)

PRESS_MOUSE

;-----------------------------------
; Apply non-linear RICHARDSON-LUCY DECONVOLUTION
; ==============================================
; Ask for iteration number
READ, PROMPT = 'Enter iteration no.:', itno

; Initial value
t1 = image_conv

; Iteration loop
for n = 1, itno do begin

   t2 = image_conv / SHIFT(FFT( FFT(t1) * FFT(image_psf) , 1 ),$
                          x_size / 2, y_size / 2)
   t1 = t1 * SHIFT(FFT( FFT(t2) * FFT(image_psf) , 1 ),       $
                   x_size / 2, y_size / 2)

endfor
	
  
; Derive deconvolved image by taking the real part
image_dec = REAL_PART(t1)

; Display the deconvolved image
WINDOW, 1, XSIZE = 2 * x_size, YSIZE = 2 * y_size,                   $
        TITLE = 'Richardson-Lucy Deconvolved Image (Iterations = ' + $
        STRTRIM(STRING(FIX(itno)), 2) + ') (SNR = '                + $
        STRTRIM(STRING(FIX(snr)), 2) + ')'

SHADE_SURF, image_dec, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15,  $
            XTITLE = '[pxs]', YTITLE = '[pxs]', CHARSIZE = 1.5

WINDOW, 2, XSIZE = 2 * x_size, YSIZE = 2 * y_size,                   $
        TITLE = 'Richardson-Lucy Deconvolved Image (Iterations = ' + $
        STRTRIM(STRING(FIX(itno)), 2) + ') (SNR = '                + $
        STRTRIM(STRING(FIX(snr)), 2) + ')'

TVSCL, CONGRID(image_dec, 2 * x_size, 2 * y_size)

; Activate graphic cursor to wait for a mouse click
PRESS_MOUSE

; Delete graphic windows
WDELETE, 1, 2

; End of procedure
END

