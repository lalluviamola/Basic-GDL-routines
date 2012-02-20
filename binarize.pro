FUNCTION BINARIZE, image_in, threshold_level, MODE=mode
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This function transforms a monocrhome image into a binary image
; obtained by aplying binary thresholding.
;
; WARNING: Grayscale image expected.
;
; Input:          image_in         array,   2-D indexed image
;                 threshold_level  scalar, threshold level index
;                 mode             scalar, thresholding mode:
;                                               0 -- LE thresholding (default)
;                                               1 -- GT thresholding
; Output:         image_out
; External calls: -
; 
; Programmer:    Daniel Molina García (based on M. Messerotti examples)
; Creation date: 18 October 2011
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

; Checking parameters
if (N_ELEMENTS(image_in) eq 0) or (N_ELEMENTS(threshold_level) eq 0) then begin
   print, 'Error. Use: BINARIZE, image, threshold_level [,MODE={0,1}]'
   return, image_in
endif

if N_ELEMENTS(mode) eq 0 then mode=0

if not ((mode eq 0) or (mode eq 1)) then begin
   print, 'WARNING: MODE keyword should be 0 or 1', mode
   print, 'Result will be equivalent to MODE=0.'
endif

; Define byte array
image_out = BYTARR((SIZE(image_in))[1], (SIZE(image_in))[2])

; Apply level thresholding according to selected mode
case mode of
   0 : image_out = image_in LE threshold_level
   1 : image_out = image_in GT threshold_level

else: image_out = image_in LE threshold_level
endcase

return, image_out
end
