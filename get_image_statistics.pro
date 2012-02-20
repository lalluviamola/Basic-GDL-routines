PRO GET_IMAGE_STATISTICS
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Fill me.
;
; Input:          -
; Output:         -
; External calls: -
; 
; Programmer:    Daniel Molina García (based on M. Messerotti examples)
; Creation date: -
; Environment:   i686 GNU/Linux Saturno 2.6.32-34-generic #77-Ubuntu
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

READ_JPEG, !DIR + '/examples/data/marsglobe.jpg', image

IMAGE_STATISTICS, image,                                 $
                  COUNT              = TotalPixelNumber, $
                  DATA_SUM           = PixelValueSum,    $
                  MINIMUM            = PixelMin,         $
                  MAXIMUM            = PixelMax,         $
                  MEAN               = PixelMean,        $
                  STDDEV             = PixelSTDev,       $
                  SUM_OF_SQUARES     = PixelSquareSum,   $
                  VARIANCE           = PixelVariance

; Show image in left quadrant


TV, image, /TRUE, 0


; Write statistics in right quadrant

y_pos_step= 0.1
XYOUTS, 0.550, 1.0 - 0.5 * y_pos_step, 'IMAGE STATISTICS', /NORM

;XYOUTS, 0.550, 1.0 - 1.5 * y_pos_step, 'Size X x Y [pxs]= '                       $
;        + STRTRIM(STRING(x_size), 2) + ' x ' + STRTRIM(STRING(y_size), 2), /NORM

XYOUTS, 0.550, 1.0 - 2.5 * y_pos_step, 'Total pixel numbers = '                   $
        + STRTRIM(STRING(TotalPixelNumber), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 3.5 * y_pos_step, 'Sum of pixel values = '                   $
        + STRTRIM(STRING(PixelValueSum), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 4.5 * y_pos_step, 'Min pixel values = '                      $
        + STRTRIM(STRING(PixelMin), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 5.5 * y_pos_step, 'Max Pixel value = '                       $
        + STRTRIM(STRING(PixelMax), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 6.5 * y_pos_step, 'Mean pixel value = '                      $
        + STRTRIM(STRING(PixelMean), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 7.5 * y_pos_step, 'Pixel STD deviation = '                   $
        + STRTRIM(STRING(PixelSTDev), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 8.5 * y_pos_step, 'Pixel square sum = '                      $
        + STRTRIM(STRING(PixelSquareSum), 2), /NORM                   

XYOUTS, 0.550, 1.0 - 9.5 * y_pos_step, 'Pixel variance = '                        $
        + STRTRIM(STRING(PixelVariance), 2), /NORM                   

END
