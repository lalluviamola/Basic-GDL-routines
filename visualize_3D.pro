PRO VISUALIZE_3D
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure visualizes a 2-D pseudo-image in different ways
; in 3-D, warp an image onto the 3-D surface and generate two
; movies according to two different frame storage procedures
;
; Input:          -
; Output:         -
; External calls: GAUSSIAN_2         function
;                 SCREEN_SIZE        procedure
;                 CENTER_WINDOW_POS  procedure
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

; Define origin coordinates of text line in graphic window
x_text = 10 ; (pxs)
y_text = 10 ; (pxs)

; Define font size for text in graphic window
char_size = 1.0

; Set graphics mode to indexed ColorTable
DEVICE, DECOMPOSED = 0

; Load grayscale palette
LOADCT, 0

; Define an asymetric 2-D gaussian pseudo-image (256 * 256 pxs)
x_size = 256
y_size = 256
sigma_x = x_size / 6.
sigma_y = y_size / 9.

image = GAUSSIAN_2(x_size, y_size, sigma_x, sigma_y)

; Define centered window origin based window size
CENTER_WINDOW_POS, x_size * 2, y_size * 2, x_win_pos, y_win_pos

; Open window
WINDOW, 1, XSIZE = x_size * 2, YSIZE = y_size * 2,  $
        XPOS = x_win_pos, YPOS = y_win_pos,         $
        TITLE = '3-D Vissualization of a 2-D gaussian'

WSHOW, 1 & WSET, 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Display a wire-mesh representation of image array
SURFACE, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,     $
         XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)', $
         TITLE = '2-D Gaussian', CHARSIZE = 2

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Wire-Mesh Visualization of 2-D Gaussian', $
        CHARSIZE = char_size, /DEVICE

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load RED palette

LOADCT, 3

; Define an array of colors for the mesh based on image values
; normalize to [0, 255]
color_array = BYTSCL(image)

; Display a colored wire-mesh representation of image array

SURFACE, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,     $
         XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)', $
         TITLE = '2-D Gaussian', CHARSIZE = 2;, SHADES = color_array

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Color Wire-Mesh Visualization of 2-D Gaussian', $
        CHARSIZE = char_size, /DEVICE

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a colored wire-mesh representation of image array
; and save 3-D transformation

SURFACE, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
         XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
         TITLE = '2-D Gaussian', CHARSIZE = 2, $ ;SHADES = color_array, $
         /SAVE

; Superimpose image contours onto wire-mesh using saved 3-D
; transformation
CONTOUR, image, XSTYLE = 1, YSTYLE = 1, CHARSIZE = 2, NLEVELS = 10, $
         /NOERASE, /T3D

; Write text line in graphic window                       
XYOUTS, x_text, y_text, 'Color Wire-Mesh Visualization of  2-D Gaussian' $
        + ' with Superimposed Contours', CHARSIZE = char_size, /DEVICE

; Activate graphic cursor and wait for key pressed        
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a colored wire-mesh representation of image array
; and save 3-D transformation

SURFACE, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
         XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
         TITLE = '2-D Gaussian', CHARSIZE = 2, $;SHADES = color_array, $
         /SAVE

; Display a 2-D image contourning using saved 3-D transformation on
; top (Z = 1.0)
CONTOUR, image, XSTYLE = 1, YSTYLE = 1, CHARSIZE = 2, NLEVELS = 10, $
         /NOERASE, /T3D, ZVALUE = 1.0

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Color Wire-Mesh Visualization of  2-D Gaussian' $
        + ' with 2-D Contour Graph at Top', CHARSIZE = char_size, /DEVICE
 
; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a color-shaded representation of image array

SHADE_SURF, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
            XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
            TITLE = '2-D Gaussian', CHARSIZE = 2, SHADES = color_array

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Color-Shared Visualization of 2-D Gaussian', $
        CHARSIZE = char_size, /DEVICE

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a color-shaded representation of image array
; and save 3-D transformation

SHADE_SURF, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
            XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
            TITLE = '2-D Gaussian', CHARSIZE = 2, SHADES = color_array, $
            /SAVE

; Display a 2-D image contourning using saved 3-D transformation on
; top (Z = 1.0)
CONTOUR, image, XSTYLE = 1, YSTYLE = 1, CHARSIZE = 2, NLEVELS = 10, $
         /NOERASE, /T3D

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Color-Shared Visualization of 2-D Gaussian with Superimposed Contours', $
        CHARSIZE = char_size, /DEVICE
 
; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display a color-shaded representation of image array
; and save 3-D transformation
SHADE_SURF, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
            XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
            TITLE = '2-D Gaussian', CHARSIZE = 2, SHADES = color_array, $
            /SAVE

; Display a 2-D image contourning using saved 3-D transformation on
; top (Z = 1.0)
CONTOUR, image, XSTYLE = 1, YSTYLE = 1, CHARSIZE = 2, NLEVELS = 10, $
         /NOERASE, /T3D, ZVALUE=1.0


; Write text line in graphic window
XYOUTS, x_text, y_text, 'Color-Shared Visualization of 2-D Contour Graph at Top', $
        CHARSIZE = char_size, /DEVICE
 
; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display the 2-D image, its 3-D wire-mesh representation and a 2-D
; contouring stacked in 3-D space

SHOW3, image, E_SURFACE = {ZRANGE:[-300,300], SHADES:color_array, CHARSEIZE:1.5, $
                           XSTYLE:1, YSTYLE:1, ZSTYLE:1},                        $
       E_CONTOUR = {NLEVELS:10, CHARSIZE:1.5, XSTYLE:1, YSTYLE:1}

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Stacked 2-D Image Graph, 3-D Wire-mesh Visualization' + $
        ' and 2-D Contour Graph', CHARSIZE = char_size, /DEVICE
 
; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load the trucolor image "glowinggas.jpg" to be warped onto surface

READ_JPEG, !DIR + '/examples/data/glowing_gas.jpg', image2

; Convert trucolor image to 254-colors indexed image (2 color indexes
; are preserved for image graphics (axes, etc.)
image2 = COLOR_QUAN(image2, 1, r, g, b, COLORS = 254)

; Load CT derived from overlay image by preserving the minimum and
; maximum index level

; Define 3 vectors of 256 elements for the color components
red   = INDGEN(256)
green = red
blue  = red

; Assign the 254-elements components derived from image to the central
; part of the 256-elements vectors

red   [1 : 254]  = r
green [1 : 254] = g
blue  [1 : 254] = r

; Load the palette component vectors
TVLCT, red, green, blue

; Resize overlay image
image2 = CONGRID(image2, x_size, y_size)

; Define a color-index array based on overlay image
color_array = BYTSCL(image2)

; Display a color-shaded representation of image array with the
; overlay image warped onto surface
SHADE_SURF, image, AZ = 45, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
            XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
            TITLE = '2-D Gaussian', CHARSIZE = 2, SHADES = color_array

; Write text line in graphic window
XYOUTS, x_text, y_text, 'Color-Shared Visualization of 2-D Gaussian with' $
        + 'Image  Warper onto Surface', CHARSIZE = char_size, /DEVICE

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ANIMATION METHOD 1: frames are generated and stored in image cube
; array and sequentially displayed from array

; Create frame array
frame_array = BYTARR(15, 512, 512)

; Load RED palette
LOADCT, 3

; Frame generation
for i = 0, 14 do begin

   ; Change image azimuth angle
   az = 45. + ind

   ; Display a color shaded representation of image array and save
   ; 3-D transformation
   SHADE_SURF, image, AZ = az, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
               XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
               TITLE = '2-D Gaussian', CHARSIZE = 2, SHADES = color_array, $
               /SAVE

   ; Display a image contours superimposed onto wire-mesh usingsaved 3-D transformation on
   ; top (Z = 1.0)
   CONTOUR, image, XSTYLE = 1, YSTYLE = 1, CHARSIZE = 2, NLEVELS = 10, $
            /NOERASE, /T3D

   ; Write text line in graphic window
   XYOUTS, x_text, y_text, 'Frame' + STRTRIM(STRING(i + 1), 2), $
           CHARSIZE = char_size, /DEVICE

   ; Read graphic content of window into frame array
   frame_array[i, *, *] = TVRD()

endfor


; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4
   
; Sequentially displays stored frames
for i = 0, 14 do begin
   TVSCL, frame_array[i, *, *]
endfor

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ANIMATION METHOD 2: frames are generated and stored in pixmap window
; and sequentially displayed from pixmap window

; Create pixmap window
WINDOW, 0, /PIXMAP, XSIZE = 15 * 512, YSIZE = 512

; Load RED palette

LOADCT, 3

; Frame generation in pixmap window
WSET, 1

for i = 0, 14 do begin

   ; Change image azimuth angle
   az = 45. + i

   ; Display a color-shared representation of image array and save
   ; 3-D transformation
   SHADE_SURF, image, AZ = az, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1,         $
               XTITLE = '(pxs)', YTITLE = '(pxs)', ZTITLE = '(Value)',     $
               TITLE = '2-D Gaussian', CHARSIZE = 2, SHADES = color_array, $
               /SAVE

   ; Display a image contours superimposed onto wire-mesh using saved 3-D
   ; transformation
   CONTOUR, image, XSTYLE = 1, YSTYLE = 1, CHARSIZE = 2, NLEVELS = 10, $
            /NOERASE, /T3D

   ; Write text line in graphic window
   XYOUTS, x_text, y_text, 'Frame' + STRTRIM(STRING(i + 1), 2), $
           CHARSIZE = char_size, /DEVICE

   ; Read graphic content of window into frame array
   frame = TVRD()

   ; Write frame to pixmap windows
   WSET, 0
   TVSCL, frame, 512 * ind, 0
   WSET, 1

endfor

 
; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4


; Sequentially display frames stored in pixmap window

; Device coordinates of the lower left corner of source rectangle
x_llc_source = 0
y_llc_source = 0

; Number of columns and rows to copy
n_columns = 512
n_rows    = 512

for i = 0, 14 do begin
   tvscl
endfor

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

; Device coordinates of the lower left corner of destination rectangle
x_llc_destin = 0
y_llc_destin = 0

; Pixmap window number
pxm_win_n = 0

; Display frames
WSET, 1
for i = 0, 14 do begin
   x_llc_source = 512 * (i MOD 15)

   ; Copy frame stored in pixmap window to graphic window
   DEVICE, COPY = [x_llc_source, y_llc_source, n_columns, n_rows, $
                   x_llc_destin, y_llc_destin, pxm_win_n]

endfor

; Activate graphic cursor and wait for key pressed
PRINT, 'Press a mouse button to continue'
CURSOR, x_c_pos, y_c_pos, 4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Delete active window   
WDELETE

END
