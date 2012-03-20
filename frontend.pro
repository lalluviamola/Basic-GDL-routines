;
; NAME:
;       FRONTEND
;
; PURPOSE:
;
;       This program is "jail" or interface which, first, asks the
;       user for selecting some image that IDL can understand. Then,
;       the program displays the image beside a menu which some
;       operations that are suitable for the kind of chosen
;       image. After selecting any operation, if needed, a widget will
;       appear asking for the settings of that particular
;       operation. When operation is applied, user is asked again for
;       a new operation to apply, according to the type of the new
;       image. 
;
;       The structure of the program is intended to be easy for the
;       inclusion of new operations so, without a lot of effort, you
;       can add or modify the available actions. 
;
; AUTHOR:
;
;       Daniel Molina García
;       Email: unomas@correo.ugr.es
;
; CATEGORY:
;
;       Utilities
;
; CALLING SEQUENCE:
;
;       FRONTEND
;
; ARGUMENTS:
;       None
;
; KEYWORDS:
;       None
;
; EXTERNAL CALLS:
;
;       FRONTEND_ACTIONS
;
; MODIFICATION HISTORY:
;
;
; LICENSE:
;
;**********************************************************************
;          Copyright 2011 Daniel Molina García 
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
;***********************************************************************
;
; BRIEF DESCRIPTION:
;
;    1. Load an image.
;    2. Show image.
;    3. Ask for an operation to apply to the image.
;    4. Apply the operation.
;    5. Show new image instead of previous.
;    6. Go to step 3 using this new image
;
; INDEED DESCRIPTION:
;
;  NOTE: We'll use the term ACTION when we mean OPERATION
;          over an image
;
;  Names of used variables: 
;
;    * Original image is IMAGE_IN.
;    * Actions are always applied over CURRENT_IMAGE
;    * Image which is the result of applying any ACTION over
;      CURRENT_IMAGE is IMAGE_OUT
;    * Displayed image is CURRENT_VIS. It is a resized (or not)
;      IMAGE_OUT
;
;  Types of images that this program understands: 
;
;       * 'true_color'
;       * 'mono_chrome'
;       * 'palette'
;       * 'binary'   
;
;  IMAGE_IN_TYPE  is the type of IMAGE_IN
;  IMAGE_OUT_TYPE is the type of IMAGE_OUT
;  CURRENT_TYPE   is the type of CURRENT_IMAGE
;
;  "PREVIEW" mode:  
;
;       * This mode is indicated with the variable NOT_PREVIEW as 0
;       * This mode is available for those ACTIONs which use a widget
;           for setting the parameters of ACTION
;       * This mode finishes when user Accepts the ACTION
;       * In this mode, it's also possible to Cancel the
;           application of ACTION
;       * In this mode, some ACTION is applied to CURRENT_IMAGE
;           creating IMAGE_OUT, as normal, but
;
;            * IMAGE_OUT is not copied to CURRENT_IMAGE
;            * New ACTIONs aren't asked. Instead, other parameters.
;
;  When displaying, IMAGE_OUT and IMAGE_OUT_TYPE are the variables
;    always checked.
;
;*************************************************************************
;----------------------
; Default variables
;----------------------

; Keep original size of image when displaying?
keep_original_size   = 1

; By default, image is showed 1:1, but if chosen, it is resized
; to a "nicer" size. This variable controls the GREATER proportion
; between the height and width of the image and the height and width
; of the screen 
; The scaling factor REALLY applied over the image is SCALE_FACTOR and
; must be defined after knowing the image size.
image_screen_mod_rel = 0.8

; This varaible control the "Preview" mode (must be activated inside a
; widget)
not_preview = 1

; This variable remembers the state of the widget in mode "Preview"
info = {option:0, value:0, status:'Init'}

; Define ACTIONS.

;  * First value is the Name of the ACTION, it must match the ACTIONS
;  located below or in FRONTEND_ACTIONS function
;  * The rest of values indicate if ACTION is defined for images of
;  certain types or not.
;  * It's more easy to add new actions following the scheme
;  with common sense than explaining it in detail ;)
actions_table =                                                                           $
[                                                                                         $
 ['Open new image...',                 'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Restart',                           'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Original size/Better adjust size',  'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Undersample',                       'true_color', 'mono_chrome', 'palette', 'binary'], $
 ['Oversample',                        'true_color', 'mono_chrome', 'palette', 'binary'], $
;['Rotate',                            'true_color', 'mono_chrome', 'palette', 'binary'], $
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

; Ask the user to select a readable image or finish execution
repeat begin

   go_forward = DIALOG_READ_IMAGE(FILE = image_in_filename, $
                                  PATH = !DIR + PATH_SEP() + 'examples' + PATH_SEP() + 'data')

   ; If 'Cancel' clicked, finish execution
   if go_forward eq 0 then GOTO, FINISH_EXECUTION

   ; Query image
   known_format = QUERY_IMAGE(image_in_filename, image_in_info)

   ; Report that selected image was not readable
   if known_format ne 1 then MESSAGE, 'Error: Unreadable image.'

endrep until known_format eq 1


; Load image
image_in = READ_IMAGE(image_in_filename, r_in, g_in, b_in)

; Save the image type
case image_in_info.channels of
   1 : begin

      if image_in_info.has_palette then begin

         image_in_type = 'palette'  

         ; Initialize here the CT for output_image and current_image
         r_out     = r_in & g_out     = g_in &     b_out = b_in
         current_r = r_in & current_g = g_in & current_b = b_in 

      end else begin

         image_in_type = 'mono_chrome'

      endelse

   end
   3 : image_in_type = 'true_color'
      else : begin

         MESSAGE, 'This program is not ready for images with ' $
                  + STRTRIM(STRING(image_in_info.channels), 2) $
                  + ' channels.'
         MESSAGE, 'Ask the programmer to implement it!!!'
         GOTO, FINISH_EXECUTION

      end
endcase

;--------------------------
; Get DIMENSIONS of SCREEN
;--------------------------

; Get size of the screen
screen_size = GET_SCREEN_SIZE()

; Coordinates of the windows:
;   In Motif IEEE standard (used by Xs) (0,0) is the lower left and windows
;     are pointed by their lower left corner.
;   MS Windows uses the convention that (0,0) is the top left and
;     windows are pointed by their top left corner. 

; Define screen coordinates for easier reference
case !VERSION.OS_FAMILY of
   'unix'  : begin
      screen_up_sign = 1 ; It marks if y-coordinate increase when going up on the screen
      screen_top     = screen_size[1] - 1
      screen_bottom  = 0
   end
   'Windows' : begin
      screen_up_sign = -1 ; It marks if y-coordinate increase when going up on the screen
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




;-----------------------------------------
; Translate initial values into the loop 
;-----------------------------------------

; Set image variables equal to the loaded image at the first iteration
image_out      = image_in
current_image  = image_in
image_out_type = image_in_type
current_type   = image_in_type

; NOTE: r_out, current_r, etc. have been defined before




REFRESH_WINDOW: $
;------------------------------------------------------------------------------------
; MAIN LOOP:
;
; Before entering here, no matter which way, IMAGE_OUT,
; IMAGE_OUT_TYPE and, if needed, R_OUT, G_OUT and B_OUT must be
; defined correctly.
;------------------------------------------------------------------------------------

   ; Notice in terminal the type of image that will be displayed
   PRINT, 'It is going to be displayed a image of type: ', image_out_type



;----------------------------------------
; DIMENSIONS of image to SHOW
;----------------------------------------

; Calculate DIMENSIONS (width, height) of IMAGE_OUT and maybe
; interleave type
case image_out_type of

   'true_color' : begin

      net_size = SIZE(image_out, /DIMENSIONS)

      ; Number of channels is 3 since it is 'true_color'
      interleav_type = WHERE( net_size eq 3 ) + 1 

      if N_ELEMENTS(interleav_type) ne 1 then begin
         MESSAGE, 'Error determining Interleaving of the image.'
         GOTO, FINISH_EXECUTION
      endif

      ; Avoid dimension which marks the interleaving
      size_indexes       = WHERE( net_size ne 3 )
      image_out_size = [ net_size[size_indexes[0]], net_size[size_indexes[1]] ]

   end

   ; For any other kind of image, it's easy
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
      'Windows' : begin
         ypos = screen_top
      end      
      else    : begin
         MESSAGE, 'INTERNAL ERROR: OS Family not detected'
         GOTO, FINISH_EXECUTION
      end
   endcase 	

   ; Create WINDOW which will display the image
   WINDOW, 1,                                                 $
           XSIZE = image_out_size[0],                         $
           YSIZE = image_out_size[1],                         $
           XPOS  = screen_right - image_out_size[0],          $
           YPOS  = ypos

; Adjust IMAGE to SHOW if original size is NOT desired
endif else begin

   ; Calculate relation between image and screen sizes
   image_screen_rel = (1.0 * image_out_size) / screen_size 

   ; If, proportionally to screen, X-side of image is bigger than Y-side
   if image_screen_rel[0] gt image_screen_rel[1] $
   then limited_component = 0                    $
   else limited_component = 1

   ; If X-component is proportionally the bigger...
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
      'Windows' : ypos = screen_top
      else    : print, 'INTERNAL ERROR: OS Family not detected'
   endcase 	
   
   ; Create window
   WINDOW, 1,                                          $
           XSIZE = current_vis_size[0],                $
           YSIZE = current_vis_size[1],                $
           XPOS  = screen_right - current_vis_size[0], $
           YPOS  = ypos

endelse


;----------------------------
; SHOW Image
;----------------------------

case image_out_type of

   ; Show image with Palette
   'palette' : begin
      DEVICE, DECOMPOSED = 0 
      TVLCT, r_out, g_out, b_out
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
      TVSCL, current_vis ; ..and do an intensity balance (maybe it is not the best idea)
   end

   'binary' : begin ; A better idea?????

      DEVICE, DECOMPOSED = 0
      LOADCT, 0
      TVSCL, current_vis

   end

endcase


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ACTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if not_preview then begin

   ;Define an array with a number of elements equal to the total number
   ; of actions
   available_actions = STRARR(N_actions)

   ; Define a free index only to be used in next for
   j = 0

   ; Write in this array only those actions that are allowed for our image
   for i=0, N_actions - 1 do begin

      ; Avoid the name of the action in the checking [1:4]
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




;----------------------
; CHOOSE action
;----------------------

; Text-Mode --------------

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


; CW_BGROUP-Mode -------------------

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


; XMENU - Mode ----------------------
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

; This case act DIRECTLY over not really ACTIONs but options for
; modificating the behavoir of this FRONTEND.
; For the rest of actions, FRONTEND_ACTIONS is called.
case current_action of

   'Open new image...' : begin

      GOTO, SELECT_IMAGE

   end

   ; Discard any ACTION applied
   'Restart' : begin

      image_out = image_in
      image_out_type = image_in_type
      if N_ELEMENTS(r_in) ne 0 then begin

         r_out = r_in & g_out = g_in & b_out = b_in

      endif

   end

   ; Switch between 1:1 and "nicer" mode
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


   ; NOTE!: We are passing CURRENT_IMAGE instead of IMAGE_OUT!

   ; WARNING: It over-rides IMAGE_OUT, NOT_PREVIEW, R_OUT, ..., and INFO
   else : image_out = FRONTEND_ACTIONS(current_image, current_action,   $
                                       current_type,                    $
                                       image_out_type,                  $
                                       current_r, current_g, current_b, $
                                       r_out, g_out, b_out,             $
                                       not_preview,                     $
                                       info)

endcase

;---------------------
; UPGRADE image_out to CURRENT_IMAGE or not
;---------------------

; If were are not in "Preview" mode, current_type/_image are set to 
if not_preview then begin

   current_image = image_out
   current_type  = image_out_type
   if N_ELEMENTS(r_out) ne 0 then begin

      current_r = r_out & current_g = g_out & current_b = b_out

   endif

endif

; Display image_out
GOTO, REFRESH_WINDOW


FINISH_EXECUTION: $
   WDELETE, 1 ; Without a command after a label (different to END) there are problems in both GDL and IDL

END

