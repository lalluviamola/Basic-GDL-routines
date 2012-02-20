PRO DISPLAY_PALETTE
; Load default palette [0]
LOADCT, 0

; Interactive image file selection and analysis
LOAD_IMAGE, image, n_channels, x_size, y_size,    $
            has_palette, r, g, b, interleav_type, $
            pixel_type, image_index, num_images,  $
            image_type, filename

; Image display in window
win_index  = 1
win_x_size = x_size + 50
win_y_size = y_size + 50
win_x_pos  = 0
win_y_pos  = 0
image_pos  = 0
win_title  = filename

; Open window
WINDOW, win_index, XSIZE = win_x_size, YSIZE = win_y_size,    $
        XPOS = win_x_pos, YPOS = win_y_pos, TITLE = win_title

; Load image palette, if any
if ( has_palette EQ 1 ) then begin
   DEVICE, DECOMPOSED = 0
   TVLCT, r, g, b
endif

; Display image
case n_channels of
   1 : TV, image, image_pos
   3 : begin
      DEVICE, DECOMPOSED = 1
      TV, image, image_pos, /TRUE
   end
endcase

; Draw one horizontal colorbar
x_palette_size = x_size - 0.3 * x_size
y_palette_size = 20
x_palette_origin = (x_size - x_palette_size + 1) / 2.
y_palette_origin = 20
border_color = !P.COLOR

DRAW_PALETTE, x_palette_origin, y_palette_origin, $
              x_palette_size, y_palette_size,     $
              border_color

; Draw vertical colorbar
x_palette_size   = 20
y_palette_size   = y_size - 0.3 * y_size

x_palette_origin = x_size + 5
y_palette_origin = (y_size - y_palette_size + 1) / 2 + 50

border_color = !P.COLOR

DRAW_PALETTE, x_palette_org, y_palette_org,   $
              x_palette_size, y_palette_size, $
              border_color
