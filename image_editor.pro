PRO IMAGE_EDITOR
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This is a frontend for applying the methods studied during the IDL
; course to any image. 
;
; Input:          -
; Output:         -
; External calls: A lot :D
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

; -----------------------
; LOADING THE IMAGE
; -----------------------
LOAD_IMAGE, image, channels, x_size, y_size, has_palette, r, g, b, $
            interleav_type, pixel_type, image_index, num_images,  $
            image_type, filename

;----------------------------------------------
; Array with the name of available actions
;----------------------------------------------
actions=[ $
        'CUT',$ 
        'MERGE',$
        'EXIT'$
]

;----------------------------------------------
; Choose one action
;----------------------------------------------
n = N_ELEMENTS(actions)

MENU:

print, 'Choose an action:'
for i=1, n do begin
   print, i, ,') ', action[i]
endfor

;READ action

; Launch action
GOTO ACTION1

;-------------------------------
; ACTIONS
;------------------------------- 

;-----------------------------
; ACTION1
;-----------------------------
ACTION1: 

BINARIZE
