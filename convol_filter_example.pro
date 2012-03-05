PRO CONVOL_FILTER_EXAMPLE

; Derive maximum screem size [pxs]
SCREEN_SIZE, x_screen, y_screen

x_standard_size = FLOOR(0.5 * 0.9 * x_screen)
y_standard_size = x_standard_size

; Set indexed CT display
DEVICE, DECOMPOSED = 0

; Get a true-color image of Mars by direct conversions from image file
READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image_1, /TRUE

; Convert image array to floating
image_1 = FLOAT(image_1)

image_2 = CONVOL_FILTER(image_1, FILTER='boxcar_blur')

; Visualization

; Define plot labels

win_title = 'Boxcar Blurring'
x_title_1 = '[pxs]'
y_title_1 = '[pxs]'
title_1   = 'Original image'
x_title_2 = x_title_1
y_title_2 = y_title_1
title_2   = 'Filtered Image'

; Draw 2-D plots
VIS_2D, image_1, image_1,                 $
        standard_x_size, standard_y_size, $
        win_title,                        $
        title_1, x_title_1, y_title_1,    $
        title_2, x_title_2, y_title_2

PRESS_MOUSE

END
