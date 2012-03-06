PRO CONVOL_FILTER_EXAMPLE

; Derive maximum screem size [pxs]
SCREEN_SIZE, x_screen, y_screen

standard_x_size = FLOOR(0.5 * 0.9 * x_screen)
standard_y_size = standard_x_size

; Set indexed CT display
DEVICE, DECOMPOSED = 0

PRINT, 'Do you want a grayscale or truecolor example?'
PRINT, ' 1) Grayscale.'
PRINT, ' 3) True-Color.'

option = 0

repeat begin

   READ, option

endrep until ( (option eq 1) || (option eq 3) )


; Get a true-color or grayscale image of Mars by direct conversions from image file

case option of

   3 : READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image_1, /TRUE
   1 : READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image_1, /GRAYSCALE

endcase


; Convert image array to floating
image_1 = FLOAT(image_1)

; Define plot labels
x_title_1 = '[pxs]'
y_title_1 = '[pxs]'
title_1   = 'Original image'
x_title_2 = x_title_1
y_title_2 = y_title_1
title_2   = 'Filtered Image'


;----- Perform filtering by 2-D convolution with revelant kernels 

filters = ['boxcar_blur',       $
           'blur_50pc',         $
           'minimal_blur',      $
           'gauss3x3_blur',     $
           'holedonut_blur'     $
          ]

for i=0, N_ELEMENTS(filters) - 1 do begin

   image_2 = CONVOL_FILTER(image_1, FILTER=filters[i])

   ; Define title of the window
   win_title = STRUPCASE( filters[i] )

   ; Draw 2-D plots
   VIS_2D, image_1, image_2,                 $
           standard_x_size, standard_y_size, $
           win_title,                        $
           title_1, x_title_1, y_title_1,    $
           title_2, x_title_2, y_title_2

   PRESS_MOUSE

endfor


; Apply other filters, but stretching the histograms 

filters = ['classic_sharp',     $
           'crispening_1',      $
           'crispening_2'       $
          ]

for i=0, N_ELEMENTS(filters) - 1 do begin

   image_2 = CONVOL_FILTER(image_1, FILTER=filters[i], /HIST_EQUAL)

   ; Define title of the window
   win_title = STRUPCASE( filters[i] )

   ; Draw 2-D plots
   VIS_2D, image_1, image_2,                 $
           standard_x_size, standard_y_size, $
           win_title,                        $
           title_1, x_title_1, y_title_1,    $
           title_2, x_title_2, y_title_2

   PRESS_MOUSE

endfor

filters = ['bassrelief_NW',     $
           'bassrelief_N',      $
           'bassrelief_NE',     $
           'bassrelief_E',      $
           'bassrelief_SE',     $
           'bassrelief_S',      $
           'bassrelief_SW',     $
           'bassrelief_W',      $
           'emboss_NW',     $
           'emboss_N',      $
           'emboss_NE',     $
           'emboss_E',      $
           'emboss_SE',     $
           'emboss_S',      $
           'emboss_SW',     $
           'emboss_W'       $
          ]

for i=0, N_ELEMENTS(filters) - 1 do begin

   image_2 = CONVOL_FILTER(image_1, FILTER=filters[i], /BYTSCL)

   ; Define title of the window
   win_title = STRUPCASE( filters[i] )

   ; Draw 2-D plots
   VIS_2D, image_1, image_2,                 $
           standard_x_size, standard_y_size, $
           win_title,                        $
           title_1, x_title_1, y_title_1,    $
           title_2, x_title_2, y_title_2

   PRESS_MOUSE

endfor

; Other filters


filters = ['sobel_H',      $
           'sobel_V',      $
           'kirsch_H',     $
           'kirsch_V',     $
           'prewitt_H',    $
           'prewitt_V',    $
           'laplacian'     $
          ]

for i=0, N_ELEMENTS(filters) - 1 do begin

   image_2 = CONVOL_FILTER(image_1, FILTER=filters[i], /HIST_EQUAL)

   ; Convert filtered image to binary
   case option of

      1 : image_3 =     BYTSCL(image_2, TOP = 1)

      3 : image_3 = COLOR_QUAN(image_2, 1, R, G, B, COLORS = 2)

   endcase

   ; Define title of the window
   win_title = STRUPCASE( filters[i] )

   ; Draw 2-D plots
   VIS_2D, image_1, image_3,                 $
           standard_x_size, standard_y_size, $
           win_title,                        $
           title_1, x_title_1, y_title_1,    $
           title_2, x_title_2, y_title_2

   PRESS_MOUSE

endfor


;----- Unsharp masking (TWO STEPS)

; Unsharp mask
unsharp_mask_1   = CONVOL_FILTER(image_1, FILTER='unsharp_mask')

expanded_unitary = CONVOL_FILTER(image_1, FILTER='expd_unitary')


; Define plot labels
win_title = 'UNSHARP MASKING (STEP 1)'
title_1   = 'Expanded Unitary'
title_2   = 'Unsharp_mask'

; Draw 2-D plots
VIS_2D, unsharp_mask_1, expanded_unitary,   $
        standard_x_size, standard_y_size,   $
        win_title,                          $
        title_1, x_title_1, y_title_1,      $
        title_2, x_title_2, y_title_2

PRESS_MOUSE

; Unsharping masking = c * expanded_unitary - (c - 1) * unsharp_mask
;                      (c - contrast factor)

case option of

   1 : image_2 = HIST_EQUAL(4. * expanded_unitary - 3. * unsharp_mask_1)

   3 : for i = 0, 2 do $
   
      image_2[i, *, *] = HIST_EQUAL(4. * expanded_unitary[i, *, *] - 3. * unsharp_mask_1[i, *, *] )

endcase

; Define plot labels
win_title = 'UNSHARP MASKING (STEP 2)'
title_1   = 'Original Image'
title_2   = 'Filtered Image'

; Draw 2-D plots
VIS_2D, image_1, image_2,                   $
        standard_x_size, standard_y_size,   $
        win_title,                          $
        title_1, x_title_1, y_title_1,      $
        title_2, x_title_2, y_title_2

PRESS_MOUSE


; ------- Unsharp masking (ONE STEP: Combined kernel)


image_2 = CONVOL_FILTER(image_1, FILTER='usp_masking', /HIST_EQUAL)

; Define plot labels
win_title = 'UNSHARP MASKING (Only one step: Combined kernel)'

; Draw 2-D plots
VIS_2D, image_1, image_2,                   $
        standard_x_size, standard_y_size,   $
        win_title,                          $
        title_1, x_title_1, y_title_1,      $
        title_2, x_title_2, y_title_2

PRESS_MOUSE


; ---- Deleting window
WDELETE



END
