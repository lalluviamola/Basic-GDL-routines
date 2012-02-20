PRO DRAW_PALETTE, x_pos, y_pos, x_size, y_size, border_color
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure draws the active colortable in graphic format
;
; Input:          x_pos          lower left point
;                 y_pos          lower left point
;                 x_size         (pxs)
;                 y_size         (pxs)
;                 border_color   color of the line which will wrap 
;                                around the colortable
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
print, x_pos, y_pos, x_size, y_size, border_color

; Define average character size from system variable (pxs)
x_ch_size = !D.X_CH_SIZE
y_ch_size = !D.Y_CH_SIZE

; Set the currently open window as active
WSET, !D.WINDOW

; Draw horizontally or vertically according to selected
; aspect ratio

; Horizontal drawing
if (x_size GT y_size) then begin
   x_step = x_size / 256.
   for i = 0, 255 do begin
      POLYFILL, [x_pos, x_pos + x_step, x_pos + x_step, x_pos],        $
                [y_pos, y_pos, y_pos + y_size -1, y_pos + y_size - 1], $
                COLOR = i, /DEVICE
      x_pos = x_pos + x_step
   endfor

   x_pos = x_pos - i * x_step
   
   ; Draw border line with COLOR = border_color
   PLOTS, [x_pos, x_pos + x_size, x_pos + x_size, x_pos, x_pos], $
          [y_pos, y_pos, y_pos + y_size, y_pos + y_size, y_pos], $
          COLOR = border_color, /DEVICE

   ; Write index labels at the lower side based on the average character size
   ; in window
   XYOUTS, x_pos - x_ch_size / 2.,   $
           y_pos - y_ch_size * 1.25, $
           '0', /DEVICE
   XYOUTS, x_pos + x_size / 2. - x_ch_size * 1.5, $
           y_pos - y_ch_size * 1.25,              $
           '127', /DEVICE
   XYOUTS, x_pos + x_size - x_ch_size * 1.5, $
           y_pos - y_ch_size * 1.25,          $
           '255', /DEVICE
endif else begin

   ;Vertical drawing
   y_step = y_size / 256.
   for i = 0, 255 do begin
      POLYFILL, [x_pos, x_pos + x_size - 1, x_pos + x_size - 1, x_pos], $
                [y_pos, y_pos, y_pos + y_step, y_pos + y_step],         $
                COLOR = i, /DEVICE

      y_pos = y_pos + y_step
   endfor

   y_pos = y_pos - i * y_step

   ; Draw border line
   PLOTS, [x_pos, x_pos + x_size, x_pos + x_size, x_pos, x_pos], $
          [y_pos, y_pos, y_pos + y_size, y_pos + y_size, y_pos], $
          COLOR = border_color, /DEVICE

   ; Write index labels at the right side based on the average character size
   ; in window
   XYOUTS, x_pos + x_size + x_ch_size / 2.,       $
           y_pos - y_ch_size / 2.0,               $
           '0', /DEVICE
   XYOUTS, x_pos + x_size + x_ch_size / 2.,       $
           y_pos + y_size / 2.0 - y_ch_size / 2., $
           '127', /DEVICE
   XYOUTS, x_pos + x_size + x_ch_size / 2.,       $
           y_pos + y_size       - y_ch_size / 2., $
           '0', /DEVICE
endelse

end
