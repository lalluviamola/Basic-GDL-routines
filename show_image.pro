PRO SHOW_IMAGE, image_to_show, n_channels, x_size, y_size, has_palette, R_vect, G_vect, $
                B_vect, interleav_type, filename, win_index, win_x_pos,       $
                win_y_pos, win_title
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This procedure displays an image in a graphic window according
; to its features
;
; Input:          image_to_show
;                 n_channels (number of channels)
;                 x_size (width in px)
;                 y_size (height in px)
;                 has_palette
;                 r (component ????)
;                 g     "
;                 b     "
;                 interlav_type
;                 filename (the path of the file)
;                 win_index (the index that we desire for the image display)
;                 win_title 

; Output:         -
; External calls: -
; 
; Programmer:    Daniel Molina García
; Creation date: 17 October 2011
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

case n_channels of
   1 : is_true_color = 0           ; The image is NOT true-color
   3 : is_true_color = 1           ; The image is true-color
endcase

; Open a graphic window properly sized and located at
; (win_x_pos, win_y_pos)
window, win_index, xsize = x_size, ysize = y_size, $
        xpos = win_x_pos, ypos = win_y_pos, title = win_title


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; About DEVICE and DECOMPOSE, LOADCT, TV and TVLCT
;
; The DEVICE procedure provides device-dependent control over the
; current graphics device (as set by the SET_PLOT routine). The IDL
; graphics procedures and functions are device-independent. That is,
; IDL presents the user with a consistent interface to all
; devices. However, most devices have extra abilities that are not
; directly available through this interface. DEVICE is used to access
; and control such abilities. It is used by specifying various
; keywords that differ from device to device. 
;
; Most keywords to the DEVICE procedure are sticky -- that is, once you
; set them, they remain in effect until you explicitly change them
; again, or end your IDL session.
;
;
; DECOMPOSE is used to control the way in which graphics
; color index values are interpreted when using displays
; with decomposed color (TrueColor or DirectColor visuals).
; This keyword has no effect on indexed-color devices,
; which generally specify color using 8 bits per pixel.
;
; DECOMPOSE=1 indicates a RGB representation of colors.
; Color values are interpreted as 3, 8-bit color
; values where the least-significant 8 bits contain the
; red value, forward green and forward blue.
;
; DECOMPOSE=0 indicates a INDEXATE representation.
; It cause the least-significant 8 bits of the color
; value to be interpreted as an index into a color lookup
; table. This setting allows users with decomposed color
; displays to use IDL programs written for
; indexed-color displays without modification. 
;
;
; The LOADCT procedure loads one of 41 predefined IDL color tables.
; The first argument is the number of the pre-defined color table
; to load, from 0 to 40. If this value is omitted, a menu of the
; available tables is printed and the user is prompted to enter a
; table number. 
;
;
; The TV procedure displays images in a Direct Graphics window without
; scaling the intensity. To display an image with scaling, use the
; TVSCL procedure.
;
;
; The TVSCL procedure scales the intensity values of Image into the
; range of the Direct Graphics image display device and outputs the
; data to the image display at the specified location. The array is
; scaled so the minimum data value becomes 0 and the maximum value
; becomes the maximum number of available colors (held in the system
; variable !D.TABLE_SIZE) as follows:
;
;   output = (!D.TABLE_SIZE-1)(DATA-DATA_min)/(DATA_max-DATA_min)
;
; where the maximum and minimum are found by scanning the array. The
; parameters and keywords of the TVSCL procedure are identical to
; those accepted by the TV procedure. (Try avoiding it under IDL:
; http://ross.iasfbo.inaf.it/IDL/Robishaw/idlcolors.html)
;
; The TVLCT procedure loads the display color translation tables from
; the specified variables. Although G/IDL uses the RGB color system
; internally, color tables can be specified to TVLCT using any of the
; following color systems: RGB (Red, Green, Blue), HLS (Hue,
; Lightness, Saturation), and HSV (Hue, Saturation, Value). Alpha
; values may also be used when using the second form of the
; command. The type and meaning of each argument is dependent upon the
; color system selected, as described below. Color arguments can be
; either scalar or vector expressions. If no color-system keywords are
; present, the RGB color system is used. 
;
; Source: http://idlastro.gsfc.nasa.gov/idl_html_help/*.html 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Display image according to type
case is_true_color of
   0 : begin
      case has_palette of
         0: begin
            print, 'Displaying non-indexed monocrome image with TVSCL...'
            DEVICE, DECOMPOSE = 0 ; Indexed image
            LOADCT, 0             ; Load linear grayscale palette
            TVSCL, image_to_show  ; 
         end
         1: begin
            print, 'Displaying indexed monocrome image with TV but loading a palette with TVLCT...'
            DEVICE, DECOMPOSE = 1         ; RGB image (not indexed)
            TVLCT, R_vect, G_vect, B_vect ; Load palette using 
            TV, image_to_show;, win_x_pos, win_y_pos
            TVLCT, R_vect, G_vect, B_vect ; Load palette using 
            TV, image_to_show;, win_x_pos, win_y_pos
            TVLCT, R_vect, G_vect, B_vect ; Load palette using 

            TV, image_to_show;, win_x_pos, win_y_pos
         end
      endcase
   end
   1 : begin
      case has_palette of
         0: begin
            print, 'Displaying a RGB color image with TV...'
            DEVICE, DECOMPOSE = 1              ; RGB image (not indexed)
            TV, image_to_show, TRUE = interleav_type
         end
         1: begin
            print, 'I am not ready to display color indexed images yet.'
         end
      endcase
   end
endcase
end
 
