PRO VIS_3D, win_x_size, win_y_size, win_title,                           $
            image_1, x_size_1, y_size_1, title_1, x_title_1, y_title_1, $
            image_2, x_size_2, y_size_2, title_2, x_title_2, y_title_2
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure visualizes 2 arrays in adjacent quadrants of a unique
; graphic window as colored 3-D wire-mesh in "Lego" mode
;
; Input:          win_x_size
;                 win_y_size
;                 win_title
;                 image_1
;                 x_size_1      x-size of 1st image
;                 y_size_1      y-size of 1st image
;                 title_1
;                 x_title_1
;                 y_title_1
;                 image_2
;                 x_size_2      x-size of 2nd image
;                 y_size_2      y-size of 2nd image
;                 title_2
;                 x_title_2
;                 y_title_2
; Output:         -
; External calls: SCREEN_SIZE
;                 CENTER_WINDOW_POS
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

; 3-D Visualization

; Define centered window origin based on twice input window x-size
CENTER_WINDOW_POS, 2 * win_x_size, y_win_size, x_win_pos, y_win_pos

; Open window
WINDOW, 2, XSIZE = 2 * win_x_size, YSIZE = win_y_size, $
           XPOS  = x_win_pos,      YPOS = y_win_pos,   $
           TITLE = win_title

; Display 1st image as a colored 3-D wire-mesh with "Lego" appearence
SURFACE, image_1,                                  $
         XTITLE   = x_title_1, YTITLE = y_title_1, $
         XSTYLE   = 1,         YSTYLE = 1,         $
         ZSTYLE   = 1,                             $
         TITLE    = title_1,                       $
         AZ       = 15,                            $
         CHARSIZE = 2.0,                           $
         POSITION = [0.05, 0.1, 0.45, 0.9],        $
         SHADES   = BYTSCL(image_1),               $
         /LEGO

; WTF??
; Redraw axes to avoid partial erasing due to wire-mesh  drawing

; SURFACE, image_1, XTITLE = x_title_1, YTITLE = y_title_1, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, $
;         TITLE = title_1, AZ = 15, CHARSIZE = 2.0, POSITION = [0.05, 0.1, 0.45, 0.9], /LEGO,  $
;         SHADES = BYTSCL(image_1), /NOERASE, /NODATA

; Display 2nd image as a colored 3-D wire-mesh with "Lego" appearance
SURFACE, image_2,                                  $
         XTITLE   = x_title_2, YTITLE = y_title_2, $
         XSTYLE   = 1,         YSTYLE = 1,         $
         ZSTYLE   = 1,                             $
         TITLE    = title_2,                       $
         AZ       = 15,                            $
         CHARSIZE = 2.0,                           $
         POSITION = [0.05, 0.1, 0.95, 0.9],        $
         SHADES   = BYTSCL(image_2),               $
         /LEGO,                                    $
         /NOERASE

; WTF ??
; Redraw axes to avoid partial erasing due to wire-mesh drawing
;SURFACE, image_2, XTITLE = x_title_2, YTITLE = y_title_2, XSTYLE = 1, YSTYLE = 1, ZSTYLE = 1, $
;         TITLE = title_2, AZ = 15, CHARSIZE = 2.0, POSITION = [0.05, 0.1, 0.45, 0.9], /LEGO,  $
;         SHADES = BYTSCL(image_2), /NOERASE, /NODATA

END
