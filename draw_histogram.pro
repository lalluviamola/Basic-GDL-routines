PRO DRAW_HISTOGRAM, image, min_bin, max_bin, x0, y0, x1, y1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Draw image histogram in selected quadrant
;
; Input:          image
;                 min_bin       minimum bin to be plotted
;                 max_bin       maximum bin to be plotted
;                 x0, y0        norm. coordinates of lower left corner
;                 x1, y1        norm. coordinates of upper right corner
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

; Derive image histogram
image_histogram = HISTOGRAM(image)

; Generate histogram bins
histogram_bins = FINDGEN(N_ELEMENTS(image_histogram)) + MIN(image)

; Plot image histogram in quadrant
PLOT, histogram_bins, image_histogram, PSYM = 10, XTITLE = 'Colortable index', $
      YTITLE = 'Index Density', POSITION = [x0, y0, x1, y2], /YLOG,            $
      YRANGE = [10.0^0, 10.0^4], XRANGE = [min_bin, max_bin],                  $
      XSTYLE = 1, YSTYLE = 1, /NOERASE

END
