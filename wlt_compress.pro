PRO WLT_COMPRESS
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Complete me!
;
; Input:          -
; Output:         -
; External calls: -
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: -
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


; Begin by choosing the number of wavelet coefficients to use and a
; threshold value:
coeffs = 12 & thres = 25.0

; Open the people.dat data file, read an image using associated
; variables and close the file:
OPENR, 1, FILEPATH('people.dat', SUBDIR = ['examples', 'data'])
images  = assoc(1, bytarr(192, 192))
image_1 = images[0]
close, 1

; Expand the image to the nearest power of two using cubic
; convolution, and transform the image into its wavelet representation
; using the WTN function:
pwr = 256
image_1 = CONGRID(image_1, pwr, pwr, /CUBIC)
wtn_image = WTN(image_1, coeffs)

; Write the image to a file using the WRITEU procedure and check the
; size of the file (in bytes) using the FSTAT function:
OPENW, 1, 'original.dat'
WRITEU, 1, wtn_image
status = FSTAT(1)
CLOSE, 1
PRINT, 'Size of the file is ', status.size, ' bytes.'

; Now, we convert the wavelet representation of the image to a
; row-indexed sparse storage format using the SPRSIN function,
; write the data to a file using WRITE_SPR procedure, and check the
; size of the "compressed" file:
sprs_image = SPRSIN(wtn_image, THRES = thres)
WRITE_SPR, sprs_image, 'sparse.dat'
OPENR, 1, 'sparse.dat'
status = FSTAT(1)
CLOSE, 1
PRINT, 'Size of the compressed file is ', status.size, 'bytes.'

; Determine the number of elements (as a percentage of total elements)
; whose absolute magnitude is less than the specified threshold. These
; elements are not retained in the row indexed sparse storage format:
PRINT, 'Percentage of elements under threshold: ',      $
       100 * N_ELEMENTS( WHERE(wtn_image lt thres, count) ) / N_ELEMENTS(image_1)

; Next, read the row-indexed sparse data back from the file sparse.dat
; using the READ_SPR function and reconstruct the image from the
; non-zero data using the FULSTR function:
sprs_image = READ_SPR('sparse.dat')
wtn_image  = FULSTR(sprs_image)

; Apply the inverse wavelet transform to the image:
image_2 = WTN(wtn_image, coeffs, /INVERSE)

; Calculate and print the amount of data used in reconstruction of the
; image
PRINT, 'The image on the right side is reconstructed from:', $
       100. - (100. * count/N_ELEMENTS(image_1)), $
       '% of original image data.'

; Finally, display the original and reconstructed images sode by side
WINDOW, 1, XSIZE = pwr*2, YSIZE = pwr,   $
        TITLE = 'Wavelet Image Compression and File I/O'
TV, image_1, 0, 0
TV, image_2, pwr -1 , 0

end
