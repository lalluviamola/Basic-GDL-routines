PRO DFT_AND_DCT_COMPRESS
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure performs image compression via low-pass filtering in
; the Fourier domain. Two cases are considered: filtering via the
; complex DFT and filtering via the real DCT to emphasize the quality
; of the compression result in the former case due to the use of a
; double amount of information (Re + Im instead of only Re).
;
; WARNING: Grayscale square images are requeired!
;
; Input:          -
; Output:         -
; External calls: CENTER_WINDOW_POS  procedure
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
READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image, /GRAYSCALE

; Determine image size
image_size = SIZE(image)

x_size = image_size[1]
y_size = image_size[2]

; Derive centered window position with x size to host 2 quadrants
CENTER_WINDOW_POS, 2 * x_size, y_size, x_win_pos, y_win_pos

; Load grayscale palette
LOADCT, 0

; Derive the cutt-off frecuency according to the required compression
; factor

                                ; Define the usable Nyquist frecuency for the image
f_nyq = x_size/2.

                                ; Define the required data volume
                                ; compression factor with:
                                ; N  - size of oroginal (square)
                                ;      image (pxs)
                                ; fc - cut-off spatial frequency
                                ;      (pxs)
                                ;      (fc LT N/2)

READ, cprs, PROMPT = 'Required image compression [2-32]? '
cfact = (1. / FLOAT(cprs))

                                ; Derive the related cut-off frequency
                                ; fc
fc = ROUND(SQRT(cfact * x_size^2))

                                ; DErive the related spectral band
                                ; reduction
sbred = FLOAT(fc) / x_size

; Print the compression parameters on the system console
PRINT, 'Image Data Volume = ', x_size * y_size, '(pxs)'
PRINT, FORMAT = '("Image Compression  = ", I4)', FIX(cprs)
PRINT, FORMAT = '("Cut-off Frequency  = ", I4)', fc
PRINT, FORMAT = '("Compression Factor = ", F4.2)', cfact
PRINT, FORMAT = '("Band Reduction     = ", F4.2)', sbred

; ---------------------------------------
;           DFT Compression
; ---------------------------------------

; Compute DFT of image
image_DFT_shift = SHIFT(FFT(image), x_size/2, y_size/2))

; Extract selected domain from DFT spectrum
image_DFT_cropped = FLTARR(fc, fc)
image_DFT_cropped = image_DFT_shift[(x_size/2 - 1 - fc/2) : (x_size/2 - 1 + fc / 2), $
                                    (y_size/2 - 1 - fc/2) : (y_size/2 - 1 + fc / 2)]

; Derive compressed image by inverse DFT transform
DFT_compressed_image = FFT(image_DFT_cropped, 1)

; -------------------------------
;          DCT Compression
; -------------------------------


; Derive DCT of image via DFT
image_DCT = DCT_VIA_FFT(image)

; Extract selcted domain from DCT spectrum
image_DCT_cropped = FLTARR(fc, fc)
image_DCT_cropped = image_DCT[0 : (fc - 1), (y_size - fc) : (y_size - 1)]

DCT_compressed_image = DCT_VIA_FFT(image_DCT_cropped, 1)

; Display DFT and DCT compressed images in quadrant 0 and 1 for
; comparison
TVN, DFT_compressed_image, DCT_compressed_image, $
     TITLE = 'DFT and DCT compressed images', TEXT1 = 'DFT Compressed', $
     TEXT2 = 'DCT Compressed'


; Start visualization of DFT

if show_original_dft then $

   TVN, TITLE = 'Original Grayscale Image and Its Fourier Spectrum (shifted)', $
        image, HIST_EQUAL(ALOG10(ABS(image_DFT_shift))),                       $
        TEXT1 = 'Original Image', TEXT2 = 'DFT Spectrum'

if show_original_dft_filtered then begin

   ; Create CENTERED SQUARE mask (low-pass filter)
   centered_square_mask = FLTARR(x_size, y_size)

   centered_square_mask[(x_size/2 - 1 - fc/2) : (x_size/2 - 1 + fc / 2),       $
                        (y_size/2 - 1 - fc/2) : (y_size/2 - 1 + fc / 2)        $
                       ] = 1.0

   ; Apply the mask to SHIFTED image
   filtered_spectrum = centered_square_mask * image_DFT_shifted

   TVN, TITLE = 'Original and Its Fourier Spectrum Filtered (and shifted)', $
        image, HIST_EQUAL(ALOG10(ABS(filtered_spectrum))),                  $
        TEXT1 = 'Original Image', TEXT2 = 'Filtered DFT Spectrum'
endif

if show_original_dft_compressed then begin

   quadrant = FLTARR(x_size, y_size)
   quadrant[(x_size/2 - 1 - fc/2) : (x_size/2 - 1 + fc / 2),       $
            (y_size/2 - 1 - fc/2) : (y_size/2 - 1 + fc / 2)        $
           ] = DFT_compressed_image

   TVN, TITLE = 'Original Grayscale Image and compressed by DFT', $
        image, quadrant, TEXT1 = 'Original Image', TEXT2 = 'Compressed Image'

   TVN, TITLE = 'Original Grayscale Image and compressed by DFT', $
        image, CONGRID(DFT_compressed_image, x_size, y_size),     $
        TEXT1 = 'Original Image', TEXT2 = 'Compressed Image'
endif

; Start visualization of DCT

if show_original_dct then $

   TVN, TITLE = 'Original Grayscale Image and Its Fourier Spectrum (shifted)', $
        image, HIST_EQUAL(ALOG10(ABS(image_DFT_shift))),                       $
        TEXT1 = 'Original Image', TEXT2 = 'DCT Spectrum'

if show_original_dct_filtered then begin

; CREATE LOW-PASS SQUARE MASK 
; where the zero frequency is located at the TOP LEFT CORNER

; Define a 0 matrix with the same size than the original image 
   top_left_square_mask = FLTARR(x_size, y_size)

; Let pass the frequencies inside the square (fc, fc) 
   top_left_square_mask[ 0 : fc - 1 , y_size - fc : y_size - 1 ] = 1.

; Apply filter mask to DCT spectrum
   filtered_spectrum = image_DCT * top_left_square_mask

   TVN, TITLE = 'Original and Its Fourier Spectrum Filtered (and shifted)', $
        image, HIST_EQUAL(ALOG10(filtered_spectrum)),                       $
        TEXT1 = 'Original Image', TEXT2 = 'Filtered DCT Spectrum'

if show_original_dct_compressed then begin

   quadrant = FLTARR(x_size, y_size)
   quadrant[(x_size/2 - 1 - fc/2) : (x_size/2 - 1 + fc / 2),       $
            (y_size/2 - 1 - fc/2) : (y_size/2 - 1 + fc / 2)        $
           ] = DFT_compressed_image

   ; Open graphic window
   WINDOW, 1, XSIZE = (2 * x_size), YSIZE = y_size, XPOS = x_win_pos, YPOS = y_win_pos, $
           TITLE = 'Original Grayscale Image and compressed by DFT'

   ; Display original image in left quadrant
   TV, image, 0
   XYOUTS, 0.005, 0.01, 'Original Image', /NORM

   ; Display DFT Spectrum in right quadrant
   TV, quadrant, 1
   XYOUTS, 0.505, 0.01, 'Compressed Image', /NORM

   PRESS_MOUSE
   
   ; Resize compressed image to match the size of original one
   TV, CONGRID(DFT_compressed_image, x_size, y_size), 1
   XYOUTS, 0.505, 0.01, 'Compressed Image', /NORM   

   PRESS_MOUSE

endif



END 
