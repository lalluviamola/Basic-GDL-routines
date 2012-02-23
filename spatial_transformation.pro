FUNCTION SPATIAL_TRANSFORMATION, image_in,                                $
                                 UNDERSAMPLE        = undersample,        $
                                 OVERSAMPLE         = oversample,         $
                                 REBIN_FACTOR       = rebin_factor,       $
                                 TRANSROT           = transrot,           $
                                 TRANS_VALUES       = trans_values,       $
                                 ROT_VALUE          = rot_value,          $
                                 NEAREST_NEIGHBOUR  = nearest_neighbour,  $
                                 BILINEAR           = bilinear
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This function realizes one of the following spatial transformations
;     
;     * Undersampling
;     * Oversampling
;     * Rotation
;     * Translation (Shift)
;
; WARNING: Currently it only works with GRAYSCALE IMAGES.
;
;
;
; Input:          image_in
;                 ACTION-KEYWORDS:
;                            UNDERSAMPLE - Undersample image_in by
;                                           REBIN_FACTOR
;                                 WARNING: Accepted only integer
;                                           REBIN_FACTOR
;                            OVERSAMPLE  - Oversample image_in by
;                                           REBIN_FACTOR.
;                                          If REBIN_FACTOR is real, a
;                                           METHOD-KEYWORD must be
;                                           specified
;                            TRANSROT    - Shift and rotate image_in
;                                           by TRANS_VALUES[x,y] and
;                                           ROT_VALUE.
;                                          A METHOD_KEYWORD must be
;                                           specified

;                 CONTROL-KEYWORDS:
;                            REBIN_FACTOR
;                            TRANS_VALUES (2-Dim)
;                            ROT_VALUE (in radians and clock-wise)
;
;                 METHOD-KEYWORDS:
;                            NEAREST_NEIGHBOUR
;                            BILINEAR
;
; Output:         image_out
; External calls: -
;
; Inner Desciption: When OVERSAMPLING, we loop with the index running
;                   the pixels of the rebinned image, which dimensions
;                   have been defined before. That way we only need to
;                   avoid scanning out of the original image and we
;                   get a value for any pixel of our rebinned image. 
;
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: -
; Environment:   i686 GNU/Linux 2.6.32-34-generic Ubuntu
; Modified:      -
; Version:       0.2
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

; Check that any operation will be executed
if (N_ELEMENTS(undersample) eq 0) and $
   (N_ELEMENTS(oversample)  eq 0) and $
   (N_ELEMENTS(transrot)    eq 0) then begin

   MESSAGE, 'No valid operation selected: UNDERSAMPLE, OVERSAMPLE, TRANSROT'
   return, 1

endif

; Let only one operation at the same time
if ((N_ELEMENTS(undersample) ne 0) and (N_ELEMENTS(oversample) ne 0)) or $
   ((N_ELEMENTS(undersample) ne 0) and (N_ELEMENTS(transrot)   ne 0)) or $
   ((N_ELEMENTS(oversample)  ne 0) and (N_ELEMENTS(transrot)   ne 0)) then begin

   MESSAGE, 'Only one operation can be selected at a time'
   return, 1

endif

; Force definition of rebining_factor and a correct value
if undersample or oversample then begin

   if (N_ELEMENTS(rebin_factor) eq 0) then begin

      MESSAGE, 'A value of REBIN_FACTOR must be indicated.'
      return, 1
   endif

   if rebin_factor le 1 then begin
      MESSAGE, 'REBIN_FACTOR must be a number greater than 1.'
      return, 1
   endif

endif

; Avoids selection of both included methods of doing calcs at a time
if (N_ELEMENTS(nearest_neighbour) ne 0) and $
   (N_ELEMENTS(bilinear)          ne 0) then begin

   MESSAGE, 'NEAREST_NEIGHBOUR and BILINEAR keywords are exclusive. Use only one of them at a time.'
   return, 1

endif
 
; Force specification of a METHOD_KEYWORD if needed
if trans_rot or ( oversample and (FIX(rebin_factor)) ne rebin_factor ) then begin

   if ( (N_ELEMENTS(bilinear) eq 0) and (N_ELEMENTS(nearest_neighbour) eq 0) ) then begin

      MESSAGE, 'INTERP or NEAREST_NEIGHBOUR must be indicated.'
      return, 1
   endif

endif

; Define variables not passed as KEYWORDS
if N_ELEMENTS(undersample)       eq 0 then undersample       = 0
if N_ELEMENTS(oversample)        eq 0 then oversample        = 0
if N_ELEMENTS(transrot)          eq 0 then transrot          = 0
if N_ELEMENTS(nearest_neighbour) eq 0 then nearest_neighbour = 0
if N_ELEMENTS(bilinear)          eq 0 then bilinear          = 0
if N_ELEMENTS(rot_value)         eq 0 then rot_value         = 0
if N_ELEMENTS(trans_values)      eq 0 then transvalues       = [0, 0]


; START


; Get dimensions of image
x_size_in = (SIZE(image_in, /DIMENSIONS))[0]
y_size_in = (SIZE(image_in, /DIMENSIONS))[1]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INTEGER UNDERSAMPLING -- Reduce image size by an integer factor
;
; BTW, "Congrid" works with final dimensions, not a rebining factor.

if undersample then begin

   ; Check if rebin_factor is not integer
   if rebin_factor ne FIX(rebin_factor)  then begin

      MESSAGE, 'Not-integer undersampling is not coded yet. :('
      return, 1

   endif
                                ; SIZE OF REBBINED IMAGE (preserves
                                ; aspect-ratio) IS SMALLER than
                                ; ORIGINAL IMAGE OVER REBIN_FACTOR.

                                ; That is useful for not over-ride
                                ; original image when scanning it.
   x_size_out = FLOOR(x_size_in / rebin_factor)
   y_size_out = FLOOR(y_size_in / rebin_factor)

   image_out  = BYTARR(x_size_out, y_size_out)

   ; Scan rebinned image
   for x2 = 0, x_size_out - 1 do begin
      for y2 = 0, y_size_out - 1 do begin
         
         ; Reset summation buffer
         sum = 0.

                                ; Sum pixel attributes of original
                                ; image in a square window
                                ; of size (rebin_factor) 
                                ; Probably this loop doesn't
                                ; look into last pixels of original
                                ; image
         for x1 = x2 * rebin_factor, (x2 + 1) * rebin_factor - 1 do begin
            for y1 = y2 * rebin_factor, (y2 + 1) * rebin_factor - 1 do begin
            
               sum = sum + image_in[x1, y1]

            endfor
         endfor
                                ; Assign the mean of the pixel
                                ; attributes in the window
                                ; to the transformated pixel in the
                                ; rebinned image
         image_out[x2, y2] = sum / rebin_factor^2

      endfor
   endfor

   return, image_out

endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INTEGER OVERSAMPLING -- Expand image size by an integer factor

; Check that it is an integer factor
if ( oversample and (rebin_factor eq FIX(rebin_factor)) ) then begin

; Derive size of rebinned image
                                ; SIZE OF REBBINED IMAGE (preserves
                                ; aspect-ratio) IS EXACTLY the
                                ; ORIGINAL IMAGE'S BY REBIN_FACTOR.

                                ; That is useful for not leaving
                                ; "holes" in the rebinned image
   x_size_out = x_size_in * rebin_factor
   y_size_out = y_size_in * rebin_factor

; Create byte-type array to store rebinned image
   image_out = BYTARR(x_size_out, y_size_out)


; Scan rebinned image

                                ; Pixel attributes in original image
                                ; are replicated in rebinned image a
                                ; number of times defined by the
                                ; rebinning factor
   for x2 = 0, x_size_out - 1 do begin
      for y2 = 0, y_size_out - 1 do begin

                                ; It is done as an integer division:
                                ;   From 0/rebin_factor
                                ;   To
                                ;   (rebin_factor-1)/rebin_factor,
                                ; which are (rebin_factor) cells,
                                ; always is got the same result (0).

                                ; Idem for the rest of pixels OF
                                ; rebbinned image.
                                ; So, integer division does the job.
         image_out[x2, y2] = image_in[x2 / rebin_factor, y2 / rebin_factor]

      endfor
   endfor

endif





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OVERSAMPLING -- Expand image size by a NON-INTEGER factor via
;                 NEAREST NEIGHBOUR pixel attribute assignment

if   oversample                            and $
   ( rebin_factor ne FIX(rebin_factor) )   and $
     nearest_neighbour                     then begin

; Derive size of rebinned image
   x_size_out = ROUND(x_size_in * rebin_factor)
   y_size_out = ROUND(y_size_in * rebin_factor)

; Create byte-type array to store rebinned image
   image_out = BYTARR(x_size_out, y_size_out)
; Rebin image

; Scan rebinned image
   for x2 = 0, x_size_out - 1 do begin
      for y2 = 0, y_size_out - 1 do begin
            
                                ; Pixel attributes in original image
                                ; are replicated in rebinned image a
                                ; number of times defined by the
                                ; rebinning factor and pixel adresses
                                ; are ROUNDed  to the nearest integer
                                ; (nearest neighbour approximation)

                                ; This time rebin_factor is a float,
                                ; so division doesn't trunk the result
         x1 = ROUND(x2 / rebin_factor)
         y1 = ROUND(y2 / rebin_factor)

                                ; Now we need to control that we are
                                ; not over-riding the scanning of
                                ; original image..      
         if ( x1 gt 0 ) and ( x1 le (x_size_in - 1) ) and $
            ( y1 ge 0 ) and ( y1 le (y_size_in - 1) )     $
            
         then image_out[x2, y2] = image_in[x1, y1]        $
         else image_out[x2, y2] = 0

      endfor
   endfor

endif








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OVERSAMPLING -- Expand image size by a NON_INTEGER factor via
;                 BILINEAR INTERPOLATION in pixel attribute
;                 assignment

if (   oversample                           and $
     ( rebin_factor ne FIX(rebin_factor) )  and $
       bilinear                                 $
   ) then begin


; Derive size of rebinned image
   x_size_out = ROUND(x_size_in * rebin_factor)
   y_size_out = ROUND(y_size_in * rebin_factor)
   
; Create byte-type array to store rebinned image
   image_out = BYTARR(x_size_out, x_size_out)

; Rebin image

; Scan rebinned image
   for x2 = 0, x_size_out - 1 do begin
      for y2 = 0, y_size_out - 1 do begin
            
                                ; Pixel attributes in original image
                                ; are replicated in rebinned image a
                                ; number of times defined by the
                                ; rebinning factor and pixel adresses
                                ; are derived via bilinear
                                ; interpolation of  pixel attributes

                                ; Derive (floating) pixel address in
                                ; rebinned image
         x = x2 / rebin_factor
         y = y2 / rebin_factor
      
                                ; Extract integer part of pixel address
         xi = FLOOR(x)
         yi = FLOOR(y)

                                ; Extract fractional part of pixel address
         xf = x - xi
         yf = y - yi

                                ; If pixel address in original image
                                ; does not exceed image range.

                                ; This time we work with an aditional
                                ; pixel, so we restrict scanning one
                                ; more pixel.
         if ( x1 ge 0 ) and ( x1 le (x_size_out - 2) ) and $
            ( y1 ge 0 ) and ( y1 le (y_size_out - 2) ) then begin

                                ; Compute bilineal interpolation
                                ; coefficients from original image
                                ; pixel attributes
            c1 = image_in[xi    , yi    ]
            c2 = image_in[xi    , yi + 1]
            c3 = image_in[xi + 1, yi    ]
            c3 = image_in[xi + 1, yi + 1]
         
                                ; Apply bilineal interpolation formula
                                ; to define the pixel attribute in
                                ; rebinned image as interpolation of
                                ; pixel attributes in original image
            image_out[x2, y2] = c1 * (1 - xf) * (1 - yf) $
                              + c2 * (1 - xf) *    yf    $
                              + c3 *    xf    * (1 - yf) $
                              + c4 *    xf    *    yf
         endif else $

                                ; Pixel addres in original image
                                ; exceeds allowed range:
                                ; -- set pixel attribute in rebinned
                                ; image to zero
            image_out[x2, y2] = 0
            
      endfor
   endfor
      
endif




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRANSLATION AND ROTATION -- Shift an image via NEAREST NEIGHBOUR
;                             interpolation in pixel attribute assignment


if transrot and nearest_neighbour then begin

; Defined angular constants to minimize computations
   sin_theta = SIN(rot_value)
   cos_theta = COS(rot_value)

; Redifine translation values
   delta_x = trans_values[0]
   delta_y = trans_values[1]

; Set size of rotated image equal to size of original image
   x_size_out = x_size_in
   y_size_out = y_size_in

; Create byte-type array to store rebinned image
   image_out = BYTARR(x_size_out, y_size_out)

; Derive original image center
   x_center_in = x_size_in / 2
   y_center_in = y_size_in / 2

; Rotate image

; Scan rotated image
   for x2 = 0, x_size_out - 1 do begin
      for y2 = 0, y_size_out - 1 do begin

                                ; Image is shifted by (delta_x,
                                ; delta_y) and rotated by (theta)
                                ; around its center. Nearest neighbour
                                ; approximation is used in new image
                                ; pixel attribute assignment

                                ; Derive (floating) pixel address in
                                ; rotated image by applying inverse transformation

         x1 = ROUND(x_center_in + (x2 - x_center_in - delta_x) * cos_theta - (y2 - yc - delta_y) * sin_theta)
         y1 = ROUND(y_center_in + (x2 - x_center_in - delta_x) * sin_theta - (y2 - yc - delta_y) * cos_theta)


         if ( x1 ge 0 ) and ( x1 le (x_size_in - 2) ) and  $
            ( x1 ge 0 ) and ( y1 le (y_size_in - 2) )      $

                                ; Assign pixel attribute as
                                ; correspondent one in original image
         then image_out[x2, y2] = image_in[x1, y1] $


                                ; Pixel address in original  image
                                ; exceeds allowed range.
                                ; Set pixel attribute in rotated image
                                ; to zero
         else image_out[x2, y2] = 0

      endfor
   endfor

endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TRANSLATION AND ROTATION -- Shift and rotate an image via BILINEAR
;                             interpolation in pixel attribute
;                             assignment

if transrot and bilinear then begin


; Redifine translation offset (pxs)
   delta_x = trans_values[0]
   delta_y = trans_values[1]

; Derive original image center
   x_center_in = x_size_in / 2
   y_center_in = y_size_in / 2

; Defined angular constants to minimize computations
   sin_theta = SIN(rot_value)
   cos_theta = COS(rot_value)

; Set size of rotated image equal to size of original image
   x_size_out = x_size_in
   y_size_out = y_size_in

; Create byte-type array to store rebinned image
   image_out = BYTARR(x_size_out, y_size_out)

; Rotate image

; Scan rotated image
   for x2 = 0, x_size_out - 1 do begin
      for y2 = 0, y_size_out - 1 do begin

                                ; Image is shifted by (delta_x,
                                ; delta_y) and rotated by (theta)
                                ; around its center. Bilinear
                                ; interpolation is used in new image
                                ; pixel attribute assignment

                                ; Derive (floating) pixel address in
                                ; rotated image by applying inverse transformation
         x1 = x_center_in + (x2 - x_center_in - delta_x) * cos_theta - (y2 - yc - delta_y) * sin_theta
         y1 = y_center_in + (x2 - x_center_in - delta_x) * sin_theta - (y2 - yc - delta_y) * cos_theta

                                ; Extract integer part of pixel
                                ; address
         xi = FLOOR(x)
         yi = FLOOR(y)

                                ; Extract fractional part of pixel
                                ; address
         xf = x - xi
         yf = y - yi


                                ; Pixel address in original image
                                ; does not exceed image range
         if ( x1 gt 0 ) and ( x1 le (x_size_in - 2) ) and $
            ( y1 ge 0 ) and ( y1 le (y_size_in - 2) ) then begin

                                ; Apply binlinear interpolation
                                ; formula to define the pisel
                                ; attribute in rotated image as
                                ; interpolation of pixel attributes in
                                ; original image
            image_out[x2, y2] = c1 * (1 - xf) * (1 - yf) $
                              + c2 * (1 - xf) *    yf    $
                              + c3 *    xf    * (1 - yf) $
                              + c4 *    xf    *    yf



         endif else $
                                ; Pixel address in original  image
                                ; exceeds allowed range.
                                ; Set pixel attribute in rotated image
                                ; to zero
            image_out[x2, y2] = 0

      endfor
   endfor

endif

; Return transformated image
return, image_out

END
