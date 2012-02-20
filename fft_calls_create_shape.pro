PRO FFT_CALLS_CREATE_SHAPE, image_x_size, image_y_size, SHAPE=shape, CHSIZE=chsize, $
                            BINARY=binary, NEGATIVE = negative, ROTATION=rotation
;----------------------------------------- Analyze DIST pattern
; Generate DIST pattern image
image = CREATE_SHAPE(image_x_size, image_y_size, SHAPE = shape, CHSIZE = chsize, $
                    BINARY = binary, NEGATIVE = negative, ROTATION = rotation)

; Compute FFT
image_fft = FFT(image)

; Computer Power Spectrum
image_pws = ABS(image_fft)^2

; Open graphic window with 3 quadrants
WINDOW, 0, XSIZE = 3 * image_x_size, YSIZE = image_y_size, XPOS = 0, YPOS = 0, $
        TITLE = 'Original Image, Unshifted and Shifted Power Spectrum'

; Display original image in quadrant 0
TVSCL, image, 0

; Display unshifted Power Spectrum in quadrant 1
TV, HIST_EQUAL(ALOG10(image_pws)), 1

; Display shifted Power Spectrum in quadrant 2
TV, HIST_EQUAL(SHIFT(ALOG10(image_pws), image_x_size/2, image_y_size/2)), 2

PRESS_MOUSE

END
