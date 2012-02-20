PRO PSEUDO_COLOR, image_in, image_out, r, g, b, PSEUDO_GRAYSCALE = grayscale, $
                  GRAY_COMPONENT = gray_component
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Obtain a indexed image using COLOR_QUAN. It returns indexed image
; and the Color Table by components. It can also return a indexed grayscaled
; image in different ways. See available keywords for more information.
;
; Input:          image_in  (3 channels image) [3,w,h]
;                 image_out (indexed image)    [w,h]
;                 r         (red array of the Color Table)
;                 g         (green         "             )
;                 b         (blue          "             )
;
;                 PSEUDO_GRAYSCALE (keyword)
;                    Average all array components by default. If
;                    PSEUDO_GRAYSCALE_WITH is passed then this keyword
;                    has no effect.
;
;                 GRAY_COMPONENT={'R','r','G','g','B','b','0'} (keyword)
;                    Return 3 times the red, green OR blue component of the Color
;                     Table.
;                    '0' means that GRAY_COMPONENT keyword is not used at all 
;                    This keyword over-rides PSEUDO_GRAYSCALE's one.
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

if N_ELEMENTS(grayscale)      eq 0   then grayscale      = 0
if N_ELEMENTS(gray_component) eq 0   then gray_component = '0'

; It works as keywords are defined at top.
if gray_component             ne '0' then begin
   if ((gray_component ne 'r') and (gray_component ne 'R') and $
       (gray_component ne 'g') and (gray_component ne 'G') and $
       (gray_component ne 'b') and (gray_component ne 'B')) then begin

      print, 'WARNING: GRAY_COMPONENT has not a valid value.'
      print, '         Valid values: {R,r,G,g,B,b,0}'
      gray_component = '0'
      grayscale = 1             ; Force PSEUDO_GRAYSCALE if a bad option is used
      
   endif else grayscale = 0     ; Over-ride PSEUDO_GRAYSCALE if GRAY_COMPONENT is used
endif

;-------------------
; QUANTIZATION
;-------------------

; Convert true color image to a indexed image through COLOR_QUAN
image_out = COLOR_QUAN(image_in, 1, r, g, b, COLORS = 255)

;-------------------
; PSEUDO_GRAYSCALE based on previous quantization
;-------------------

; If a array of the Color Table has been chosen to define the
; grayscale palette
case gray_component of
   '0' : break
   'r' : begin
      g = r & b = r
   end
   'R' : begin
      g = r & b = r
   end
   'g' : begin
      r = g & b = g
   end
   'G' : begin
      r = g & b = g
   end
   'b' : begin
      r = b & g = b
   end
   'B' : begin
      r = b & g = b
   end
endcase  

; If not, use the average value of every component
; (I have not better ideas)
if grayscale then begin
   average_component = (r+g+b)/3
   r = average_component
   g = average_component
   b = average_component
endif

end
