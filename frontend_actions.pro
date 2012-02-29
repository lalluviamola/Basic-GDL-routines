FUNCTION WIDGET_ASK_TRANSFORMATION_PARAMETERS, $
   PARAMETERS  = parameters,        $
   RANGE       = range,             $
   LABEL       = label,             $
   EXCL_OPTS   = excl_options,      $
   EXCL_OPTS_LABEL = excl_opts_label

; Input: PARAMETERS idea is not implemented yet

; Define main base for the widget
mainBase    = WIDGET_BASE(/COLUMN)

; Define a base for options and selecting value with an slider
if N_ELEMENTS(EXCL_OPTIONS) ne 0 then begin

   secondBase = WIDGET_BASE(mainBase, /ROW)
   label1     = WIDGET_LABEL(secondbase, VALUE = label)
   slider     = WIDGET_SLIDER(secondBase, MINIMUM = range[0], MAXIMUM = range[1])
   options    = CW_BGROUP(secondBase, excl_options,     $
                          LABEL_TOP = excl_opts_label,  $
                          /COLUMN, /EXCLUSIVE, /RETURN_NAME)

endif else $

   slider   = WIDGET_SLIDER(mainBase, MINIMUM = range[0], MAXIMUM = range[1])


; Define a base for the buttons
bBase = WIDGET_BASE(mainBase, /ROW)

; Define a pointer for getting information inside FRONTEND_EVENT
ptr = Ptr_New({status:'', chosenOption:0,  sliderValue:0})

; Define the buttons
bCancel  = WIDGET_BUTTON(bBase, VALUE='Cancel') 
bRefresh = WIDGET_BUTTON(bBase, VALUE='Refresh') 
bDone    = WIDGET_BUTTON(bBase, VALUE='Done') 

; Define the user structure kept on the main widget
; 3 first will be the IDs of the buttons
; the rest are pointers which indicate useful parameters
; to be passed to the associated procedure to the ACTION
stash = {bCancel:bCancel, bRefresh:bRefresh, bDone:bDone, $
         ptr:ptr}

; Display the widget and associate the structure to wBase
WIDGET_CONTROL, mainBase, /REALIZE
WIDGET_CONTROL, mainBase, SET_UVALUE = stash

; Let work FRONTEND_EVENTS until widget be destroyed
XMANAGER, 'FRONTEND', mainBase

output = {chosenOption:(*ptr).chosenOption, $
                 value:(*ptr).sliderValue,  $
                status:(*ptr).status
         }

Ptr_Free, ptr

return, output

END


FUNCTION FRONTEND_ACTIONS, image, action, current_type, r, g, b, ask_new_action
; This procedure does the particular operation over images. It
; "stores" every action not related directly with the frontend.


case action of

   'Binarize' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS(      $
             LABEL           = 'Set threshold:',        $
             RANGE           = [0, 100],                $
             EXCL_OPTS       = ['dasd', 'hggj'],        $
             EXCL_OPTS_LABEL = 'Mode of threshold: ')

      if info.status ne 'Cancel' then $
         image_out = BINARIZE(image, info.value, MODE = info.chosenOption)

   end

   'Quantize' : begin
      pseudo_grayscale = 0
      gray_component = '0'
      PSEUDO_COLOR, image, image_out, r, g, b,           $
                    PSEUDO_GRAYSCALE = pseudo_grayscale, $
                    GRAY_COMPONENT = gray_component
      current_type = 'palette'
   end

   else : begin
     print, 'Internal error: Chosen action has not instructions in FRONTEND_ACTIONS.'
  end

endcase

if info.status eq 'Refresh' $
then ask_new_action = 0     $
else ask_new_action = 1

return, image_out
end
