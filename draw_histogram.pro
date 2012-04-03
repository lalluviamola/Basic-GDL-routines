PRO DRAW_HISTOGRAM, image, MIN=min_bin, MAX=max_bin, POSITION = position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Draw image histogram in selected quadrant
;
; Input:          image
;                 min_bin       minimum bin (value of minimum class of
;                                            the histogram partition)
;                                            to be plotted
;                 max_bin       maximum bin to be plotted
;                 position      norm. coordinates of lower left corner
;                               and norm. coordinates of upper right
;                               corner
;                               [x_left, y_bottom, x_right, y_top]
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

; It doesn't matter if min_bin or max_bin are not defined

; Derive image histogram
histogram = HISTOGRAM(image)

; Generate histogram bins, starting at minimum value of the image
histogram_bins = FINDGEN(N_ELEMENTS(histogram)) + MIN(image)

; Plot image histogram in quadrant
PLOT, histogram_bins, histogram, PSYM = 10,     $
      XTITLE = 'Colortable index',              $
      YTITLE = 'Index Density',                 $
      POSITION = position,                      $
      /YLOG,                                    $
      XRANGE = [min_bin, max_bin],              $
      YRANGE = [10.0^0, 10.0^4],                $
      XSTYLE = 1, YSTYLE = 1,                   $
      /NOERASE

END
