PRO MORPHOLOGY_EXAMPLE
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure performs a morphological analysis of an image by
; appling various IDL functions
;
; Input:          -
; Output:         -
; External calls: CENTER_WINDOW_POS
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: 6-March-2012
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

; Set graphic mode to indexed colortable
DEVICE, DECOMPOSED = 0

; Load (Rainbow + White) colortable
LOADCT, 39

; Load image to be analyzed from IDL sample set
; Image is monochrome
filename = FILEPATH('pollens.jpg', SUBDIR = ['examples', 'demo', 'demodata'])

image = READ_IMAGE(filename)

; Determine image size
x_size = (SIZE(image))[1]
y_size = (SIZE(image))[2]

; Store image in buffer array
image0 = image

; ------------------------------------------------------------
; IDENTIFY FEATURES BY THRESHOLDING, SEARCH2D and LABELLING
; ------------------------------------------------------------

; Define center windows position with 4 quadrant
CENTER_WINDOW_POS, 2 * x_size, 2 * y_size, x_win_pos, y_win_pos

; Open graphic window with 4 quadrants
WINDOW, 0, XSIZE = 2 * x_size, YSIZE = 2 * y_size,                                    $
        TITLE = 'Feature Identification via "SEARCH2D", "LABEL_REGION" and "DEFROI"', $
        XPOS = x_win_pos, YPOS = y_win_pos

; Display image in quadrant 0
TVSCL, image, 0

XYOUTS, 0.15, 0.51, /NORM, 'Original Image', COLOR = 255

; Apply image THRESHOLDING (WTF!!!)
threshold        = WHERE(image gt 150)
image[threshold] = 255 

; Display thresholded image in quadrant 1

TVSCL, image, 1

XYOUTS, 0.65, 0.01, /NORM, 'Thresholded Image', COLOR = 255

; Apply Masking

dim  = SIZE(image, /DIM)
mask = BYTARR(dim[0], dim[1])
mask[threshold] = 1B
masked = image * mask

; Display masked image in quadrant 2
TVSCL, masked, 2
XYOUTS, 0.15, 0.01, /NORM, 'MASKED IMAGE', COLOR = 255


; FINDING FEATURES WITH "SEARCH2D" 
grain = SEARCH2D(image, 90, 100, 100, 255)
mask  = BYTARR(dim[0], dim[1])
mask[grain] = 1B

; Display identified feature in quadrant 3
TVSCL, image * mask, 3
XYOUTS, 0.65, 0.01, /NORM, 'IDENTIFIED FEATURE', COLOR = 255
PRESS_MOUSE

; Finding features with "LABEL REGION"
thresh = WHERE(image lt 150)
image[thresh] = 0B

; Display labelled features n quadrant 3
TVSCL, LABEL_REGION(image), 3
XYOUTS, 0.65, 0.01, /NORM, 'LABELLED FEATURES', COLOR = 255
PRESS_MOUSE

;--------------------------------------------------
; DEFINING REGIONS OF INTEREST (ROI) WITH "DEFROI"
;--------------------------------------------------

; Define centered window position with 2 quadrants
CENTER_WINDOW_POS, 2 * x_size, y_size, x_win_pos, y_win_pos

WINDOW, 0, XSIZE = 2 * x_size, YSIZE = y_size,              $
        TITLE = 'Feature Identification via "DEFROI"',      $
        XPOS = x_win_pos, YPOS = Y_WIN_POS

; Display image in quadrant 0
TVSCL, image0

; Allow interactive definition of Region of Interest (ROI) on original
; image via graphic cursor in left quadrant:
;   Left   Button -- mark point
;   Middle Button -- erase previous point
;   Right  Button -- close region

ROI = DEFROI(dim[0], dim[1])

; Display histogram of ROI in right quadrant
PLOT, HISTOGRAM(image0[ROI], MIN = 50, MAX = 250),           $
      XTITLE = 'Intensity', YTITLE = 'Number of pixels',     $
      POSITION = [0.60, 0.15, 0.95, 0.95],                   $
      /NOERASE


WAIT, 5
PRESS_MOUSE

;----------------------------------
; DILATION AND EROSION
; ---------------------------------

; Define centered window position with 2 quadrants
CENTER_WINDOW_POS, 2 * x_size, y_size, x_win_size, y_win_size

; Open graphic window with 2 quadrants
WINDOW, 0, XSIZE = 2 * x_size, YSIZE = y_size,          $
        TITLE = 'Dilation and Erosion Operators',       $
        XPOS = x_win_pos, YPOS = y_win_pos

; Apply DILATION operator with 4x4 kernel

; Define kernel
kernel = BYTARR(4,4) + 1B

; Display DILATED image in left quadrant
TVSCL, DILATE(masked, kernel), 0
XYOUTS, 0.15, 0.01, /NORM, 'DILATED IMAGE', COLOR = 255

; Display ERODED image in right quadrant
TVSCL, ERODE(masked, kernel), 1
XYOUTS, 0.65, 0.01, /NORM, 'ERODED IMAGE', COLOR = 255
PRESS_MOUSE

;-----------------------------
; Highlighting Image features
;-----------------------------

; Define centered window position with 3 quadrants
CENTER_WINDOW_POS, 3 * x_size, y_size, x_win_pos, y_win_pos

; Ope graphic window with 3 quadrants
WINDOW, 0, XSIZE = 3 * x_size, YSIZE = y_size,                 $
        TITLE = 'Features Highlighting with "MORPH_TOPHAT",' + $
                '"MORPH_GRADIENT", "WATERSHED"',               $
        XPOS = x_win_pos, YPOS = y_win_pos

; Highlight Peaks (quadrant 0)
TVSCL, MORPH_TOPHAT(image0, FLTARR(4,4) + 1.), 0
XYOUTS, 0.10, 0.01, /NORM, 'HIGHLIGHTED PEAKS', COLOR = 255

; Highlight Boundaries (quadrant 1)
TVSCL, MORPH_GRADIENT(image0, FLTARR(4, 4) + 1.), 1
XYOUTS, 0.42, 0.01, /NORM, 'HIGHLIGHTED BOUNDARIES', COLOR = 255

; IDENTIFY INTERSITIAL REGIONS (quadrant 2)
TVSCL, WATERSHED(MORPH_GRADIENT(image0, FLTARR(4, 4) + 1.)), 2
XYOUTS, 0.75, 0.01, /NORM, 'HIGHLIGHTED INTERSTITIAL REGIONS', COLOR = 255
PRESS_MOUSE

WDELETE

END
