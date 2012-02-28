PRO FRONTEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This is a frontend for applying the methods studied during the IDL
; course to any image.
;
; Brief Description:
;
;    1. Load an image.
;    2. Show image.
;    3. Ask for an action to apply to the image.
;    4. Apply the action.
;    5. Show new image instead of previous.
;    6. Go to step 3
;
; In-side description:
;    * Orignal image is "image_in".
;    * Resultant image after aplying one action is "image_out"
;
;   If "add_operations=0" then actions are always applied over "image_in".
;   If "add_operations=1" then actions are applied over the last "image_out".
;
;   There is only one window for displaying.
;
;    * Image that is going to be displayed is "current_image"
;    * Image displayed is "current_vis". It is a resized (or not)
;       "current_image".
;
;   Frontend works with three types of images: {'true_color',
;                                               'mono_chrome',
;                                               'palette'}       
;
;
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

; Different operations are acumulative instead of acting
; always over the original image
add_operations       = 0

; Define ACTIONS
actions_table =                                                                 $
[                                                                               $
 ['Retain/Forget changes',             'true_color', 'mono_chrome', 'palette'], $
 ['Original size/Better adjust size',  'true_color', 'mono_chrome', 'palette'], $
 ['Binarize',                          '',           'mono_chrome', ''       ], $
 ['Quantize',                          'true_color', ''           , ''       ], $
 ['Exit',                              'true_color', 'mono_chrome', 'palette']  $
]

; Calculate numbers of actions
N_actions = (SIZE(actions_table, /DIMENSIONS))[1]



;-----------------------
; Image selection
;-----------------------

; Ask a image file
has_chosen = DIALOG_READ_IMAGE( FILE = image_in_filename,              $
                                PATH = !DIR + PATH_SEP() + 'examples'  $
                                + PATH_SEP() + 'data')

; If no one is chosen, finish execution
if not has_chosen then GOTO, FINISH_EXECUTION

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


current_image = image_in
current_type  = image_in_type





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



;------------------------------------------------------------------------------------
; MAIN LOOP: Before entering here must be set correctly CURRENT_TYPE
REFRESH_WINDOW: $




;----------------------------------------
; DIMENSIONS of image to SHOW
;----------------------------------------

; Calculate DIMENSIONS (width, height) of CURRENT IMAGE
   case current_type of

   'true_color' : begin

      net_size           = SIZE(current_image, /DIMENSIONS)
      size_indexes       = WHERE( net_size ne 3 )
      current_image_size = [ net_size[size_indexes[0]], net_size[size_indexes[1]] ]

   end

   else : current_image_size = SIZE(current_image, /DIMENSIONS)

endcase

; Get ready IMAGE to SHOW if original size is kept
if keep_original_size eq 1 then begin

   ; Image to show is efectively the same
   current_vis = current_image

   ; Set the Y-position of WINDOW depending of OS
   case !VERSION.OS_FAMILY of
      'unix'  : begin
         ypos = screen_top - screen_up_sign * current_image_size[1]
         end
      'Win32' : begin
         ypos = screen_top    - screen_up_sign *   current_image_size[1]
      end      
      else    : begin
         print, 'INTERNAL ERROR: OS Family not detected'
         GOTO, FINISH_EXECUTION
      end
   endcase 	

   ; Create WINDOW which will display the image
   WINDOW, 1,                                   $
           XSIZE = current_image_size[0], $
           YSIZE = current_image_size[1], $
           XPOS  = screen_left,                 $
           YPOS  = ypos

; Get ready IMAGE to SHOW if original size is NOT kept
endif else begin

   ; Calculate relation between image and screen sizes
   image_screen_rel = (1.0 * current_image_size) / screen_size 

   ; If proportionally to screen, X-side of image is bigger
   if image_screen_rel[0] gt image_screen_rel[1] $
   then limited_component = 0                      $
   else limited_component = 1

   ; If X-component is proportionally the bigger
   if limited_component eq 0 then begin

      ; Calculate size of image to show
      current_vis_size = [ image_screen_mod_rel * screen_size[0],       $
                           image_screen_mod_rel * screen_size[0] *      $
                           current_image_size[1]/current_image_size[0]  $
                         ]
   
      ; Define image to show
      if current_type eq 'true_color'                                                         $
      then current_vis = CONGRID(current_image, 3, current_vis_size[0], current_vis_size[1])  $
      else current_vis = CONGRID(current_image,    current_vis_size[0], current_vis_size[1])
      
   ; If Y-component is proportionally the biggest
   end else begin

      ; Calculate size of image to show
      current_vis_size = [ image_screen_mod_rel * screen_size[1] *       $
                           current_image_size[0]/current_image_size[1],  $
                           image_screen_mod_rel * screen_size[1]         $
                      ]
   
      ; Define image to show
      if current_type eq 'true_color'                                                         $
      then current_vis = CONGRID(current_image, 3, current_vis_size[0], current_vis_size[1])  $
      else current_vis = CONGRID(current_image,    current_vis_size[0], current_vis_size[1])
      
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
           XPOS  = screen_left,         $
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

case current_type of

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
endcase



; ACTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define an array with a number of elements equal to the total number
; of actions
available_actions = STRARR(N_actions)

; Define a free index only to be used in next for
j = 0

; Write in this array only those actions that are allowed for our image
for i=0, N_actions - 1 do begin

   if WHERE(actions_table[1:3, i] eq current_type) ne -1 then begin

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

; Create an anonymous structure to hold widget IDs and the 
; data structure. This structure becomes the user value of the 
; top-level base widget. 
;stash = { action:action, range:range, bDone=bDone, bCancel=bCancel}

; Define the base widget that contains the buttons
;base = WIDGET_BASE()

; Define a button for any available action
; /RETURN_NAME keyword will return the name of the button in the VALUE
; field of returned events.
;bgroup = CW_BGROUP(base, available_actions, /COLUMN, /RETURN_NAME)  

; Display the widget
;WIDGET_CONTROL, base, /REALIZE

; Start managing events! 
;XMANAGER, 'frontend', base

; Define menu for selecting one action
XMENU, available_actions, $
       BASE = base,       $
       BUTTONS=B,         $
       TITLE = 'Choose an action'

; Create menu
WIDGET_CONTROL, /REALIZE, BASE

; Catch which action was choosen
event = WIDGET_EVENT(base)
current_action = available_actions[ where(b eq event.id) ]

; Destroy the menu
WIDGET_CONTROL, base, /DESTROY

;----------------------
; Apply action
;----------------------

; Set current_image to original image if necessary
if not add_operations then current_image = image_in 

; This case act DIRECTLY over actions that depends only of the
; front_end. For the rest of actions, it is called FRONTEND_ACTIONS
case current_action of

   'Retain/Forget changes' : begin

      if add_operations       $
      then add_operations = 0 $
      else add_operations = 1

      image_out = current_image

   end

   'Original size/Better adjust size' : begin

      ; Alternate variable
      if keep_original_size        $
      then keep_original_size = 0  $
      else keep_original_size = 1

      image_out = current_image
   end

   'Exit' : GOTO, FINISH_EXECUTION

                                ; Execute no-inner operations
                                ; WARNING: It over-rides CURRENT_TYPE
                                ; to the correct one!
   else : image_out = FRONTEND_ACTIONS(current_image, current_action, current_type, r, g, b)

endcase

;---------------------
; Show new image
;---------------------
PRINT, 'New type of image: ', current_type
current_image = image_out
GOTO, REFRESH_WINDOW

FINISH_EXECUTION: $
   WDELETE, 1 ; Without an action here different to END there are problems on GDL (IDL?)

END

