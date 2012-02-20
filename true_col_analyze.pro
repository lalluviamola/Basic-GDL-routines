PRO TRUE_COL_ANALYZE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure counts and displays the true colors in a 3
; channels' RGB image.
;
; Input:          -
; Output:         -
; External calls: LOAD_IMAGE
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

; Set True Color Mode
DEVICE, DECOMPOSED = 1

; Interactive image file selection and analysis

LOAD_IMAGE, image, channels, x_size, y_size, has_palette, r, g, b, $
            interleav_type, pixel_type, image_index, num_images,  $
            image_type, filename

; Proceed only if the image is true color

IF channels ne 3 then begin
   PRINT, 'Error: Number of channels of the image diferent to 3.'
endif else begin
   ; Display image in window
   win_index  = 1
   win_x_size = x_size + 50     ; Set window x_size for hosting the colorbar
   win_y_size = y_size + 50     ; Set window y_size according to image size
   win_x_pos  = 0
   win_y_pos  = 0
   image_pos  = 0
   win_title  = filename
                                ; Open window
   WINDOW, win_index, XSIZE = win_x_size, YSIZE = win_y_size,    $
           XPOS = win_x_pos, YPOS = win_y_pos, TITLE = win_title

                                ; Display image
   TV, image, win_x_pos, win_y_pos, /TRUE 

                                ; Build up a vector with used True
                                ; Colors

                                ; Define a 2-D Long Integer Array with
                                ; same size of input image
   truecolor_image = LONARR(x_size, y_size)

                                ; Fill up each array element with the
                                ; correspondent true color value
   truecolor_image = REFORM(image[0, *, *]) + 256L * REFORM(image[1, *, *]) $
                     + 65536L * REFORM(image[2, *, *])

   HELP, truecolor_image

                                ; Print truecolor_image[100, 100]
                                ; (it can be useful for checking what
                                ; is in our artificial array)

                                ; Count the number of true colors
   histo      = HISTOGRAM(truecolor_image)
   truecolors = WHERE(histo GT 0L, truecolors_n)
   truecolors = SORT(truecolors)

   PRINT, 'Number of true colors: ', truecolors_n
   PRINT, 'Showing help about "truecolors" varaible:'
   HELP, truecolors

                                ; PLOT, histo, YSTYLE = 1, $
                                ; MIN_VALUE = 1
   x_size = ROUND(SQRT(truecolors_n))
   y_size = x_size

   WINDOW, win_index, XSIZE = x_size, YSIZE = y_size, TITLE = 'True Colors in Image', $
           XPOS = 0, YPOS = 0
   WSET, 1
;   PLOTS, 0, 0

;   bsize   = 1
   tci_max = MAX(truecolors)
   for i = 0L, x_size - 1L do begin
      for j = 0L, y_size - 1L do begin
         tci = i + (x_size - 1L) * j
         if ( tci LE tci_max ) AND ( i GT 0L ) then begin
            x = i + 2
            y = j + 2

                                ; POLYFILL, [x, x+bsize, x], [y, y,
                                ; y+bsize, y+bsize], COLOR =
                                ; truecolors[tci], /DEV
            PLOTS, x, y, /CONT, /DEV, COLOR = truecolors[tci]
;            print, 'i: ', i
         endif
                                ; POLYFILL, [i, i+bsize, i], [j, j,
                                ; j+bsize, j+bsize], COLOR =
                                ; truecolors[tci], /DEV
      endfor
   endfor

; Activate graphic cursor to wait for mouse click

endelse

END
