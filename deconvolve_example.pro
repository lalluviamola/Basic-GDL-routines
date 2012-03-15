PRO DISPLAY_2D_3D, image, TITLE = title

; DESCRIPTION: It displays 2 windows, one showing the original image
; and 

; Define size of the window (as twice the image's of the example's)
x_win_size = 256 * 2
y_win_size = 256 * 2

; Set graphic mode to indexed
DEVICE, DECOMPOSE = 0

; Load some Color Table
LOADCT, 4

; Display Object image
WINDOW, 1, XSIZE = x_win_size, YSIZE = y_win_size, $
        TITLE = title

; Display surface as shaded object
SHADE_SURF, image, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, AZ = 15, $
            XTITLE = '(pxs)', YTITLE = '(pxs)', CHARSIZE = 1.5

; Open a second window to display 2-D views
WINDOW, 2, XSIZE = x_win_size, YSIZE = y_win_size, $
        TITLE = title

; Display (resampled) object image
TVSCL, CONGRID(image, x_win_size, y_win_size)

PRESS_MOUSE

END

PRO DISPLAY_PS, ps, ps2, TITLE = title

; DESCRIPTION: Display a power spectrum (shifted)

; INPUT: ps       ABS(FFT of any image)^2
;        ps2

; Define size of the window (as twice the image's of the example's)
x_win_size = 256 * 4
y_win_size = 256 * 2

WINDOW, 3, XSIZE = x_win_size, YSIZE = y_win_size, $
        TITLE = title

LOADCT, 0

TVSCL, SHIFT( CONGRID(ALOG10(ps),  x_win_size/2, y_win_size), x_win_size/4, y_win_size/2 ), 0
TVSCL, SHIFT( CONGRID(ALOG10(ps2), x_win_size/2, y_win_size), x_win_size/4, y_win_size/2 ), 1

PRESS_MOUSE

WDELETE, 3

END

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

DISPLAY_2D_3D, image_obj, TITLE = 'Image with 4 point sources'


;------------------------------------
; Define POINT SPREAD FUNCTION (psf)
;------------------------------------

image_psf = FLTARR(x_size, y_size)

s_psf = 30

for i = 0, x_size - 1 do begin

   for j = 0, y_size -1 do begin

      image_psf[i,j] = exp(-(FLOAT( i-x_size/2 )^2 + FLOAT( j-y_size/2 )^2)/ ( 2*s_psf^2 ) )

   endfor

endfor

; Normalize PSF to unitary integral
image_psf = image_psf / TOTAL(image_psf)

DISPLAY_2D_3D, image_psf, TITLE = 'Gaussian Point Spread Function'



;-----------------------------------------------
; Create CONVOLVED image (OBJECT IMAGE * PSF)
;-----------------------------------------------

; Convolve original image with PSF (Why SHIFTED?)
image_conv = FFT( FFT(image_obj) * FFT(image_psf), 1 )
image_conv = REAL_PART(SHIFT(image_conv, x_size/2, y_size/2))

DISPLAY_2D_3D, image_conv, TITLE = 'Image convolved with Gaussian PSF'



;------------------
; Adding NOISE
;------------------

snr = 0
; Ask for SRN selection
repeat begin

   ; Ask Signal-to-Noise Ratio (SNR)
   READ, PROMPT = 'Enter SNR (5-1000): ', snr

endrep until (snr ge 5) && (snr le 1000)

; Add Gaussian noise to image according to selected SNR
noise_factor = ( MAX(image_conv) - MIN(image_conv) ) / snr

; Calculate a normally-distributed, floating-point, pseudo-random
; array with a mean of zero and a standard deviation of one
image_noise = RANDOMN(seed, x_size, y_size) * noise_factor

DISPLAY_2D_3D, image_noise, TITLE = 'Additive Noise'



;-------------------------
; Create Image with NOISE
;--------------------------
image_conv = image_conv + image_noise

DISPLAY_2D_3D, image_conv, TITLE = 'Noisy Image (SNR = ' + STRTRIM(STRING(snr), 2) + ')'



; ---------------------------------------------------
; Apply OPTIMUM Linear WIENER-FOURIER Deconvolution
; ---------------------------------------------------

; PS of original image
ps_obj = ABS(FFT(image_obj))^2

; Aproximate (at 0 order) signal power spectrum with data power
; spectrum
ps_signal  = ABS(FFT(image_conv))^2

DISPLAY_PS, ps_signal, BYTSCL(ps_obj),  $
            TITLE = 'Signal (really, Data) Power Spectrum'

; Aproximate noise power spectrum with high-frecuency data power
; spectrum
mean_noise = MEAN(ps_signal[x_size/4 : x_size/2, y_size/4 : y_size/2])

; Approximate signal power spectrum with data power spectrum offset by
; noise power spectrum
ps_signal = ps_signal - mean_noise
ps_signal[ WHERE(ps_signal lt 0.) ] = 0.


DISPLAY_PS, ps_signal, BYTSCL(ps_obj), TITLE = 'Signal Power Spectrum minus mean of high frequencies (noise).'


; Fourier transform PSF and normalize to 1.0 at frecuency [0, 0]
fft_psf = FFT(image_psf)
fft_psf = fft_psf/fft_psf[0, 0]

DISPLAY_PS, BYTSCL((ABS(fft_psf))^2), BYTSCL(ps_obj), TITLE = 'Power Spectrum of PSF (BYTSCLed)'


; Define deconvolution filter and normalize to 1.0 at frecuency [0, 0]
deconv_filter = COMPLEX( REAL_PART(fft_psf), - IMAGINARY(fft_psf) )

deconv_filter = deconv_filter / ( (ABS(fft_psf))^2 + mean_noise / (ps_signal * 0.001) )

deconv_filter = deconv_filter/deconv_filter[0,0]

; Deconvolve data by filter
image_dec = REAL_PART(SHIFT(FFT(deconv_filter * FFT(image_conv), 1), x_size / 2, y_size / 2))

; Show both power spectrums
DISPLAY_PS, BYTSCL(ABS(deconv_filter * image_conv)^2), BYTSCL(ps_obj), TITLE = 'Deconvolved after apply filter'


DISPLAY_2D_3D, image_dec, TITLE = 'Wiener-Fourier Deconvolver Image (SNR = ' + STRTRIM(STRING(snr), 2) + ')'




;--------------------------------------------------
; Apply non-linear RICHARDSON-LUCY DECONVOLUTION
;--------------------------------------------------
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

   ; Show both power spectrum
   DISPLAY_PS, BYTSCL(ABS(FFT(t2) * fft_psf)^2), BYTSCL(ps_obj), TITLE = 'Iteration: ' + STRING(n)


endfor
	
; Derive deconvolved image by taking the real part
image_dec = REAL_PART(t1)

DISPLAY_2D_3D, image_dec, TITLE = 'Richardson-Lucy Deconvolved Image (Iterations = ' + $
                                  STRTRIM(STRING(FIX(itno)), 2) + ') (SNR = '        + $
                                  STRTRIM(STRING(FIX(snr)), 2) + ')'

; Delete graphic windows
WDELETE, 1, 2

; End of procedure
END

