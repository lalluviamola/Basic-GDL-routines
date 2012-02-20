PRO SCREEN_SIZE, x_screen, y_screen
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Return the maximum screen size in pixels
;
; Input:          -
; Output:         x_screen   x-screen size (pxs)
;                 y_screen   y-screen size (pxs)
;
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

; Derive maximum size of screen (pxs)
screen_size = GET_SCREEN_SIZE()
x_screen = screen_size[0]
y_screen = screen_size[1]

end
