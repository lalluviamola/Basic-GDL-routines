FUNCTION HIST_MANIPULATION, image_in,             $
                            NEGATIVE = negative,  $
                            DECREASE_BRIGHTNESS = decrease_brightness, $
                            INCREASE_BRIGHTNESS = increase_brightness, $
                            DECREASE_CONTRAST   = decrease_contrast,   $
                            INCREASE_CONTRAST   = increase_contrast,   $
                            VALUE = value
                            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This function performs some manipulations of the histogram.
;
; Input:          -
; Output:         -
; External calls: -
; 
; Programmer:    Daniel Molina García (based on M. Messerotti's examples)
; Creation date: 3-April-2012
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
if N_ELEMENTS(negative)            eq 0 then negative            = 0
if N_ELEMENTS(decrease_brightness) eq 0 then decrease_brightness = 0 
if N_ELEMENTS(increase_brightness) eq 0 then increase_brightness = 0 
if N_ELEMENTS(decrease_contrast)   eq 0 then decrease_contrast   = 0 
if N_ELEMENTS(increase_contrast)   eq 0 then increase_contrast   = 0 

; Force a default value, if not specified
if N_ELEMENTS(value) eq 0 then value = 0.1



; Create an array with the same dimensions than the original
image_out = image_in

; Determine max value of the image
W = MAX(image_in)

; Negative
if negative            then image_out = W - image_in

; Decrease Brightness
if decrease_brightness then begin

   image_out = image_in - W * value
   image_out = (image_out ge 0) * image_out

endif

; Increase Brightness
if increase_brightness then image_out = image_in + W * value 

; Contrast Modification (look for a way intuitive of indicating it)
if decrease_contrast || increase_contrast then $
   imag_out = BYTSCL(FLOAT(image_in)^value / FLOAT(W)^(value-1))



return, image_out

END
