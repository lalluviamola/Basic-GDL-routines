PRO CENTER_WINDOW_POS, x_win_size, y_win_size, x_win_pos, y_win_pos 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Return the (device) coordinates of the windows origin to center it
; on screen
;
; Input:          x_size       window x-size (pxs)
;                 y_size       window y-size (pxs)
;
; Output:         x_win_pos       window x-origin (pxs)
;                 y_win_pos       window y-origin (pxs)
;
; External calls: SCREEN_SIZE  (procedure)
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

; Derive maximum size of screen
SCREEN_SIZE, x_screen, y_screen

; Center window on screen based on OS

case !VERSION.os of
   ; In Motif (?) system the origin is at lower left screen position
   'linux' : begin
      x_win_pos = x_screen / 2. - x_win_size / 2 + 1
      y_win_pos = y_screen / 2. - y_win_size / 2 + 1
   end
   'Win32' : begin
      x_win_pos = x_screen / 2. - x_win_size / 2 + 1
      y_win_pos = y_screen / 2. + y_win_size / 2 + 1
   end
endcase

end
