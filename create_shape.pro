FUNCTION CREATE_SHAPE, image_x_size, image_y_size, SHAPE=shape, CHSIZE=chsize, $
                       ROTATION=rotation, NEGATIVE=negative, BINARY=binary
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure creates a grayscale image with a centered
; shape rotated by an angle. The procedure will force that
; shape doesn't exceed the greater side of the image (although
; the smaller could be exceeded).
;
; Input:          image_x_size    x-size of image (pxs)
;                 image_y_size    y-size of image (pxs)
;                 SHAPE           flag which select the shape
;                                   'SQUARE'    -- square            -----(default)
;                                   'RECTANGLE' -- rectangle
;                                   'CIRCLE'    -- circle
;                                   'CROSS'     -- cross
;                                   'DIST'      -- use the DIST procedure
;
;                 CHSIZE          characteristic size of the image (pxs)
;                                 if CHSIZE gt MAX(image_x_size, image_y_size),
;                                                  CHSIZE = -1
;                                 if CHSIZE eq -1, CHSIZE = 0.95 *
;                                                  MAX(image_x_size, image_y_size)
;                                   'SQUARE'    -- side
;                                   'RECTANGLE' -- long side
;                                   'CIRCLE'    -- diameter
;                                   'CROSS'     -- half lenght = 5 * thickness
;                                   'DIST'      -- -- (image_x_size, image_y_size)
;
;                 ROTATION        shape clockwise rotation angle (deg)
;
;                 NEGATIVE        if NEGATIVE = 1, then invert image levels
;
;                 BINARY          if BINARY   = 1, then binary image
;                                                  (else, grayscale)
;
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

; Set defaults
if N_ELEMENTS(shape)    eq 0 then shape    = 'SQUARE'
if N_ELEMENTS(chsize)   eq 0 then chsize   = -1
if N_ELEMENTS(rotation) eq 0 then rotation = 0
if N_ELEMENTS(binary)   eq 0 then binary   = 0
if N_ELEMENTS(negative) eq 0 then negative = 0

; Derive maximum image size in x or y direction
image_max_size = MAX([image_x_size, image_y_size])

; Shape will not exceed bigger side of the image.
if chsize gt image_max_size then chsize = ROUND(image_max_size * 0.95)

; Define output byte array (set to 0)
image_out = BYTARR(image_x_size, image_y_size)

; Open graphic window as invisible pixmap
WINDOW, 31, XSIZE=image_x_size, YSIZE = image_y_size, /PIXMAP

; Case SHAPE

; Build up filled square shape by setting image array elements
case shape of
   'SQUARE'    : $
      image_out[(image_x_size / 2 - chsize / 2) : (image_x_size / 2 + chsize / 2 - 1), $
                (image_y_size / 2 - chsize / 2) : (image_y_size / 2 + chsize / 2 - 1)  $
               ] = 255

   'RECTANGLE' : $
      image_out[(image_x_size / 2 - chsize / 2) : (image_x_size / 2 + chsize / 2 - 1), $
                (image_y_size / 2 - chsize / 4) : (image_y_size / 2 + chsize / 4 - 1)  $
               ] = 255

   'CIRCLE'    : begin
      x_center  = image_x_size / 2
      y_center  = image_y_size / 2
      perimeter = FLOOR(2. * !PI * chsize)

                                ; Create buffer arrays to store circunference coordinate values
      x_buf = FLTARR(perimeter)
      y_buf = FLTARR(perimeter)

                                ; Initializate index for a loop
      i = 0
                                ; Compute coordinates of circunference
                                ; upper half
      for x = image_x_size / 2. - chsize / 2., image_x_size / 2. + chsize / 2. do begin
         x_buf[i] = x
         y_buf[i] = y_center - SQRT(chsize^2 - (x - x_center)^2)

         i = i + 1
      endfor
                                ; Define the number of pixels of your circumference
      i_max = i - 1
                                ; Create circunferences coordinates array
      x_circ_coord = BYTARR(i_max + 1)
      y_circ_coord = BYTARR(i_max + 1)
                                ; Extract from buffer arrays the valid circunference coordinates
      x_circ_coord = x_buf[0 : i_max]
      y_circ_coord = y_buf[0 : i_max]
                                ; Graphically join circumferences pixels
      PLOTS, x_circ_coord[0],          y_circ_coord[0], COLOR = 255, /DEVICE
      PLOTS, x_circ_coord,             y_circ_coord,    COLOR = 255, /DEVICE, /CONTINUE
      PLOTS, REVERSE(x_circ_coord),   -y_circ_coord,    COLOR = 255, /DEVICE, /CONTINUE
;     PLOTS, x_circ_coord[i_max : 0],-y_circ_coord,    COLOR = 255, /DEVICE, /CONTINUE
                                ; Graphically fill inner region of
                                ; circle
      POLYFILL, x_circ_coord, y_circ_coord, COLOR = 255, /DEVICE
                                ; Grab graphic window content and
                                ; assign to image array
      image_out = TVRD()
   end

   'CROSS' : begin
      image_out [(image_x_size / 2 - chsize / 2 ) : (image_x_size / 2 + chsize / 2  - 1), $
                 (image_y_size / 2 - chsize / 10) : (image_y_size / 2 + chsize / 10 - 1)  $
                ] = 255
      image_out [(image_x_size / 2 - chsize / 10) : (image_x_size / 2 + chsize / 10  - 1), $
                 (image_y_size / 2 - chsize /  2) : (image_y_size / 2 + chsize / 2   - 1)  $
                ] = 255
   end
   
   'DIST' : image_out = DIST(image_x_size, image_y_size)

   else   : if shape ne 'DIST' then PRINT, 'Error: SHAPE not available. (Blank image)'
endcase

; Do modifications
if rotation ne 0 then image_out = ROT(image_out, rotation, /INTERP)
if negative then image_out = 255 - image_out
if binary   then image_out = BYTSCL(image_out, TOP = 1)

; Delete pixmap window
WDELETE, 31

RETURN, image_out

END
