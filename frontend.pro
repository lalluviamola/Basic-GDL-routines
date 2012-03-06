PRO FRONTEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This is a frontend for applying the methods studied during the IDL
; course to any image which accept it, depending of its type.
;
; Brief Description:
;
;    1. Load an image.
;    2. Show image.
;    3. Ask for an operation to apply to the image.
;    4. Apply the action.
;    5. Show new image instead of previous.
;    6. Go to step 3 using this new image
;
; In-side description:
;
;   NOTE: We'll use the term ACTION when we mean OPERATION
;          over an image
;
;   Used images: 
;
;    * Loaded/original image is "image_in".
;    * Resultant image after aplying one action is "image_out"
;    * Actions are applied over "current_image"
;    * Image displayed is "current_vis". It is a resized (or not)
;       "image_out" (first time, image_out = image_in)
;
;   This program works thinking on the following types of images: 
;
;       * 'true_color'
;       * 'mono_chrome'
;       * 'palette'
;       * 'binary'   
;
;  * "image_in_type" is the type of "image_in"
;  * "image_out_type"   is the type of result of last action
;  * "current_type"  is the type of "current_image"
;
;  "Preview" mode:  
;
;       * This mode is marked whit the variable "not_preview" as
;           0
;       * In this mode, action is applied to "current_image", creating
;           a "image_out", but
;       * "image_out" is not copied to "current_image"
;       * New actions aren't asked. Instead, the widget is created
;           again expecting to accept parameters or try others
;       * It is available for some actions which use a widget for
;           setting the parameters of those action
;       * It is also possible to cancel the application of this action
;           through the widget
;
;
;  When displaying, "image_out_type" and "image_out" are the variables
;    always checked
;  After finshing a "Preview" mode without cancelation,
;    "current_image" and "current_type" are updated
;  
; Input:          -
; Output:         -
; External calls: FRONTEND_ACTIONS
; 
; Programmer:    Daniel Molina García
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

;----------------------
; Default variables
;----------------------

; Keep original size of image when displaying?
keep_original_size   = 1

; Factor used to rebin the original image with respect the
; SCREEN size. The scaling factor REALLY applied over the image is
; "scale_factor" and must be defined after knowing image size.
image_screen_mod_rel = 0.8

; This varaible skips or not (default) the blocks which ask for ACTIONS
not_preview = 1

; This variable keeps the state of the widget in mode "Preview"
info = {option:0, value:0, status:'Init'}

; Define ACTIONS
actions_table =                                                                           $
[                                                                                         $
 ['Open new image...',                 'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Restart',                           'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Original size/Better adjust size',  'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Binarize',                          '',           'mono_chrome', ''       , ''      ], $
 ['Quantize',                          'true_color', ''           , ''       , ''      ], $
 ['Save as...',                        'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Exit',                              'true_color', 'mono_chrome', 'palette', 'binary']  $
]

; Calculate numbers of actions
N_actions = (SIZE(actions_table, /DIMENSIONS))[1]



;-----------------------
; Image selection
;-----------------------

SELECT_IMAGE: $

; Ask a image file
   image_in_filename = DIALOG_PICKFILE(PATH = !DIR + PATH_SEP() + 'examples'  $
                                       + PATH_SEP() + 'data')

; Check if image is readable and query it
known_format = QUERY_IMAGE(image_in_filename, image_in_info)

if known_format ne 1 then begin
   MESSAGE, 'Error: Unreadable image.'
   GOTO, FINISH_EXECUTION
endif

; Load image
image_in = READ_IMAGE(image_in_filename, r_in, g_in, b_in)

; Save the image type
case image_in_info.channels of
   1 : begin

      if image_in_info.has_palette then begin

         image_in_type = 'palette'  
         r = r_in & g = g_in & b = b_in

      end else begin

         image_in_type = 'mono_chrome'

      endelse

   end
   3 : image_in_type = 'true_color'
      else : begin

         print, 'INTERNAL ERROR: This program is not ready for images with ', $
                image_in_info.channels, 'channels.'
         GOTO, FINISH_EXECUTION

      end
endcase

;That index identifies the interleave type
image_in_size = SIZE(image_in, /DIMENSIONS)

; Get interleaving 
if image_in_type eq 'true_color' then begin

   ; Number of channels is 3 since it was imposed to be 'true_color'-image_in_type
   interleav_type = where( SIZE(image_in, /DIMENSIONS) eq 3 ) + 1 

   if N_ELEMENTS(interleav_type) ne 1 then begin
      print, 'INTERNAL ERROR determining Interleaving of the image.'
      GOTO, FINISH_EXECUTION
   endif

end

;--------------------------
; Get DIMENSIONS of SCREEN
;--------------------------

; Get size of the screen
screen_size = GET_SCREEN_SIZE()

; Coordinates of the windows:
;   In Motif IEEE standard (used by Xs) (0,0) is the lower left and windows
;   are pointed by their lower left corner.
;   MS Windows uses the convention that (0,0) is the top left and
;   windows are pointed by their top left corner. 

; Define screen coordinates for easier reference
case !VERSION.OS_FAMILY of
   'unix'  : begin
      screen_up_sign = 1
      screen_top     = screen_size[1] - 1
      screen_bottom  = 0
   end
   'Win32' : begin
      screen_up_sign = -1
      screen_top     = 0
      screen_bottom  = screen_size[1] - 1
   end      
   else    : begin
      print, 'INTERNAL ERROR: OS Family not detected'
      GOTO, FINISH_EXECUTION
   end
endcase
screen_left  = 0
screen_right = screen_size[0] - 1



; Set image variables equal to the loaded image at the first iteration
image_out      = image_in
current_image  = image_in
image_out_type = image_in_type
current_type   = image_in_type

;------------------------------------------------------------------------------------
; MAIN LOOP: Before entering here must be set correctly IMAGE_OUT(_TYPE)
REFRESH_WINDOW: $

   PRINT, 'It is going to be displayed a image of type: ', image_out_type

;----------------------------------------
; DIMENSIONS of image to SHOW
;----------------------------------------

; Calculate DIMENSIONS (width, height) of IMAGE_OUT
case image_out_type of

   'true_color' : begin

      net_size           = SIZE(image_out, /DIMENSIONS)
      size_indexes       = WHERE( net_size ne 3 )
      image_out_size = [ net_size[size_indexes[0]], net_size[size_indexes[1]] ]

   end

   else : image_out_size = SIZE(image_out, /DIMENSIONS)

endcase

; Get ready IMAGE to SHOW if original size is kept
if keep_original_size eq 1 then begin

   ; Image to show is efectively the same
   current_vis = image_out

   ; Set the Y-position of WINDOW depending of OS
   case !VERSION.OS_FAMILY of
      'unix'  : begin
         ypos = screen_top - screen_up_sign * image_out_size[1]
         end
      'Win32' : begin
         ypos = screen_top
      end      
      else    : begin
         MESSAGE, 'INTERNAL ERROR: OS Family not detected'
         GOTO, FINISH_EXECUTION
      end
   endcase 	

   ; Create WINDOW which will display the image
   WINDOW, 1,                             $
           XSIZE = image_out_size[0],     $
           YSIZE = image_out_size[1],     $
           XPOS  = screen_right,          $
           YPOS  = ypos

; Adjust IMAGE to SHOW if original size is not used
endif else begin

   ; Calculate relation between image and screen sizes
   image_screen_rel = (1.0 * image_out_size) / screen_size 

   ; If proportionally to screen, X-side of image is bigger
   if image_screen_rel[0] gt image_screen_rel[1] $
   then limited_component = 0                      $
   else limited_component = 1

   ; If X-component is proportionally the bigger
   if limited_component eq 0 then begin

      ; Calculate size of image to show
      current_vis_size = [ image_screen_mod_rel * screen_size[0],       $
                           image_screen_mod_rel * screen_size[0] *      $
                           image_out_size[1]/image_out_size[0]          $
                         ]
   
      ; Define image to show
      if image_out_type eq 'true_color'                                                       $
      then current_vis = CONGRID(image_out, 3, current_vis_size[0], current_vis_size[1])      $
      else current_vis = CONGRID(image_out,    current_vis_size[0], current_vis_size[1])
      
   ; If Y-component is proportionally the biggest
   end else begin

      ; Calculate size of image to show
      current_vis_size = [ image_screen_mod_rel * screen_size[1] *       $
                           image_out_size[0]/image_out_size[1],          $
                           image_screen_mod_rel * screen_size[1]         $
                      ]
   
      ; Define image to show
      if image_out_type eq 'true_color'                                                       $
      then current_vis = CONGRID(image_out, 3, current_vis_size[0], current_vis_size[1])      $
      else current_vis = CONGRID(image_out,    current_vis_size[0], current_vis_size[1])
      
   endelse

   ; Set the Y-position of window depending of OS
   case !VERSION.OS_FAMILY of
      'unix'  : ypos = screen_top - screen_up_sign * current_vis_size[1]
      'Win32' : ypos = screen_top
      else    : print, 'INTERNAL ERROR: OS Family not detected'
   endcase 	
   
   ; Create window
   WINDOW, 1,                           $
           XSIZE = current_vis_size[0], $
           YSIZE = current_vis_size[1], $
           XPOS  = screen_right,        $
           YPOS  = ypos

endelse


;----------------------------
; SHOW Image
;----------------------------

; About DECOMPOSED: 
;   Set this keyword to 1 to cause color values to be interpreted as
;   3, 8-bit color values. This is the way IDL has always interpreted
;   pixels when using decomposed color.
;
;   Set this keyword to 0 to cause the least-significant 8 bits of the
;   color value to be interpreted as an index into a color lookup
;   table. This setting allows users with decomposed color displays to
;   use IDL programs written for indexed-color displays without
;   modification. 

case image_out_type of

   ; Show image with Palette
   'palette' : begin
      DEVICE, DECOMPOSED = 0 
      TVLCT, r, g, b
      TV, current_vis

   end

   ; Show True-color image
   'true_color' : begin
      DEVICE, DECOMPOSED = 1
      TV, current_vis, TRUE = interleav_type
   end

   ; Show Mono-chrome image
   'mono_chrome' : begin
      DEVICE, DECOMPOSED = 0 ; Use palette... 
      LOADCT, 0 ; ...grey...
      TVSCL, current_vis ; ..and do an intensity balance
   end

   'binary' : begin ; A better idea?????

      DEVICE, DECOMPOSED = 0
      LOADCT, 0
      TVSCL, current_vis

   end

endcase



; ACTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if not_preview then begin

; Define an array with a number of elements equal to the total number
; of actions
   available_actions = STRARR(N_actions)

; Define a free index only to be used in next for
   j = 0

; Write in this array only those actions that are allowed for our image
   for i=0, N_actions - 1 do begin

      if WHERE(actions_table[1:4, i] eq current_type) ne -1 then begin

         available_actions[j]= actions_table[0, i]
         j = j + 1

      endif
      
   endfor

; Define number of available actions
; (it is just j since it has increased 1 last iteration)
; N_available_actions = j

; Cut the original vector
   available_actions = available_actions[0 : j-1]

endif

;----------------------
; CHOOSE action
;----------------------
;action_index = -1

; Follow asking for an action
;REPEAT read, PROMPT='Enter index of action you wish: ', action_index $
;
; ...until it was available for current type of image
;UNTIL ( (action_index ge 0)                     and $
;        (action_index lt N_actions)             and $
;        (actions_available[action_index] ne '')     $
;      )

;current_action = actions_table[0, action_index]

if not_preview then begin

; Define the base widget that contains the buttons
   base = WIDGET_BASE()

; Define a button for any available action
   menu = CW_BGROUP(base, available_actions, /COLUMN)  

; Display the widget
   WIDGET_CONTROL, base, /REALIZE

; Catch button pressed
   event = WIDGET_EVENT(base)
   current_action = available_actions[ event.value ]

; Destroy the menu
   WIDGET_CONTROL, base, /DESTROY


; Define menu for selecting one action
;   XMENU, available_actions, $
;          BASE = base,       $
;          BUTTONS=B,         $
;          TITLE = 'Choose an action'

; Create menu
;   WIDGET_CONTROL, /REALIZE, BASE

; Catch which action was choosen
;   event = WIDGET_EVENT(base)
;   current_action = available_actions[ where(b eq event.id) ]

; Destroy the menu
;   WIDGET_CONTROL, base, /DESTROY

endif

;----------------------
; Apply action
;----------------------

; This case act DIRECTLY over main actions of the front_end.
; For the rest of actions, FRONTEND_ACTIONS is called
case current_action of

   'Open new image...' : begin

      GOTO, SELECT_IMAGE

   end

   'Restart' : begin

      image_out = image_in
      image_out_type = image_in_type

   end

   'Original size/Better adjust size' : begin

      ; Alternate variable
      if keep_original_size        $
      then keep_original_size = 0  $
      else keep_original_size = 1

      ; image_out is exactly the same one
   end

   'Save as...' : begin

      result = DIALOG_WRITE_IMAGE(current_image, r, g, b)

   end



   'Exit' : GOTO, FINISH_EXECUTION

   ; Here we make the difference:
   ; We are passing current_image instead of image_out!

                                ; WARNING: It over-rides CURRENT_TYPE,
                                ; REFRESHING and INFO
   else : image_out = FRONTEND_ACTIONS(current_image, current_action, $
                                       current_type,                  $
                                       image_out_type,                $
                                       r, g, b,                       $
                                       not_preview,                   $
                                       info)

endcase

;---------------------
; Upgrade current_image or not
;---------------------

; If were are not in "Preview" mode, current_type/_image are set to 
if not_preview then begin

   current_image = image_out
   current_type  = image_out_type

endif

; Display image_out
GOTO, REFRESH_WINDOW

FINISH_EXECUTION: $
   WDELETE, 1 ; Without an action here different to END there are problems in both GDL and IDL

END

