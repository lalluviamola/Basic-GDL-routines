PRO FFT_IMAGE_ANALYZER
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure performs image filtering in the Fourier domain via
; Low-pass and High-pass Butterworth frequenzy filters
;
; Input:          -
; Output:         -
; External calls: CREATE_SHAPE   procedure
;                 ??
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

; Set device to operate in indexed mode
DEVICE, DECOMPOSED = 0

; Load Blue_white palette
LOADCT, 1

; Analyze DIST pattern
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'DIST'

; Analyze rotated DIST pattern
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'DIST', ROTATION = 45

; Analyze Filled circle
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'CIRCLE', CHSIZE = 10

; Analyze Filled square
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'SQUARE', CHSIZE = 10

; Analyze Filled square rotated by 45 deg
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'SQUARE', CHSIZE = 10, ROTATION = 45

; Analyze Filled rectangle
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'RECTANGLE', CHSIZE=20

; Analyze Filled rectangle rotated by 45 deg
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'RECTANGLE', CHSIZE=20, ROTATION = 45

; Analyze Filled cross
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'CROSS', CHSIZE = 25

; Analyze Filled cross rotated by 45 deg
FFT_CALLS_CREATE_SHAPE, 256, 256, SHAPE = 'CROSS', CHSIZE = 25, ROTATION = 45


; ----------------------------- Second Part: ANALYZE A SINUSUAL PATTERN

; Analize a sinusual variation of graylevels in x-direcction
FFT_ANALYZE_SIN_PATTERN, DIMENSION = 1

; Analize a sinusual variation of graylevels in y-direcction
FFT_ANALYZE_SIN_PATTERN, DIMENSION = 2

; Analyze a sinusual variation of graylevels at +45º
FFT_ANALYZE_SIN_PATTERN, DIMENSION = 1, ROTATION = 45

; Analyze a sinusual variation of graylevels at -45º
FFT_ANALYZE_SIN_PATTERN, DIMENSION = 1, ROTATION = -45

; Analize a sinusual variation of graylevels in x and y-direcction
FFT_ANALYZE_SIN_PATTERN, DIMENSION = 0

; Analize a sinusual variation of graylevels in x and y-direcction
; rotated by 45º
FFT_ANALYZE_SIN_PATTERN, DIMENSION = 0, ROTATION = 45

END
