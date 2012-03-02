FUNCTION GRAB_BUTTON, ev 

  ; Get the 'stash' structure. 
  WIDGET_CONTROL, ev.TOP, GET_UVALUE = stash 

  ; Get the value and user value from the widget that 
  ; generated the event. 
  WIDGET_CONTROL, ev.ID, GET_VALUE = option

  (*stash.ptrInfo).option = option

  ; Reset the top-level widget's user value to the updated 
  ; 'stash' structure. 
  WIDGET_CONTROL, ev.TOP, SET_UVALUE = stash 
END 


FUNCTION WIDGET_ASK_TRANSFORMATION_PARAMETERS, $
   info,                            $
   PARAMETERS  = parameters,        $
   RANGE       = range,             $
   LABEL       = label,             $
   EXCL_OPTS   = excl_options,      $
   EXCL_LABEL  = excl_label

; ATENTION: I don't know why, the image window goes to background
;           when this function is called after choosen
;           'Cancel' button 
;
; Input: PARAMETERS idea is not really implemented yet

; Define a pointer for getting information about button pressed by the
; user 
ptrStatus = Ptr_New('')

; Define a pointer for getting information about chosen setting values
; If it is a refresh, use the last values
if N_ELEMENTS(info) ne 0 then $

   ptrInfo   = Ptr_New({option:info.option, $
                         value:info.value}) $

; If not, initialize them
else $

   ptrInfo   = Ptr_New({option:0, value:0})

; Define main base for the widget
mainBase    = WIDGET_BASE(/COLUMN)

; Define a base for options and selecting value with an slider
if N_ELEMENTS(EXCL_OPTIONS) ne 0 then begin

   secondBase = WIDGET_BASE(mainBase, /ROW)

   label1     = WIDGET_LABEL(secondbase, VALUE = label)

   slider     = WIDGET_SLIDER(secondBase,                   $
                              VALUE = (*ptrInfo).value,     $
                              MINIMUM   = range[0],         $
                              MAXIMUM   = range[1])

   options    = CW_BGROUP(secondBase, excl_options,         $
                          LABEL_TOP  = excl_label,          $
                          SET_VALUE  = (*ptrInfo).option,   $
                          EVENT_FUNC = 'GRAB_BUTTON',       $ 
                          /COLUMN, /EXCLUSIVE)

endif else $

   slider   = WIDGET_SLIDER(mainBase, MINIMUM = range[0], MAXIMUM = range[1])


; Define a base for the buttons
bBase = WIDGET_BASE(mainBase, /ROW)

; Define the buttons
bCancel  = WIDGET_BUTTON(bBase, VALUE='Cancel') 
bRefresh = WIDGET_BUTTON(bBase, VALUE='Refresh') 
bDone    = WIDGET_BUTTON(bBase, VALUE='Done') 

; Define the user structure kept on the main widget
; 3 first will be the IDs of the buttons
; the rest are pointers which indicate useful parameters
; to be passed to the associated procedure to the ACTION
stash = {bCancel:bCancel, bRefresh:bRefresh, bDone:bDone, $
         ptrInfo:ptrInfo, ptrStatus:ptrStatus}

; Display the widget and associate the structure to wBase
WIDGET_CONTROL, mainBase, /REALIZE
WIDGET_CONTROL, mainBase, SET_UVALUE = stash

; Let work FRONTEND_EVENTS until widget be destroyed
XMANAGER, 'FRONTEND', mainBase

output = {  value:(*ptrInfo).value,         $
           option:(*ptrInfo).option,        $
           status:(*ptrStatus)}

; Free allocated memory
Ptr_Free, ptrInfo
Ptr_Free, ptrStatus

return, output

END


FUNCTION FRONTEND_ACTIONS, image, action, image_type, image_out_type, r, g, b, not_preview, info
; This procedure select which operation is used with any action

; Input: image          Image to apply the action
;        action         Action to apply
;        image_type     Type of image
;        image_out_type Type of returned image
;        r,g, b         Palette (if any)
;        not_preview    (really an output)
;        info           (really an output, although it is used)
;        EXPLAIN ME!

case action of

   'Binarize' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS( $
             info,                                 $
             LABEL      = 'Level of threshold:',   $
             RANGE      = [0, 100],                $
             EXCL_OPTS  = ['LE', 'GT'],           $
             EXCL_LABEL = 'Mode of threshold: ')

      if info.status ne 'Cancel' then begin

         image_out = BINARIZE(image, info.value, MODE = info.option)
         image_out_type = 'binary'

      endif

   end

   'Quantize' : begin
      PSEUDO_COLOR, image, image_out, r, g, b, $
                    PSEUDO_GRAYSCALE = 0,         $
                    GRAY_COMPONENT = -1
      image_out_type = 'palette'
   end

   else : begin
     print, 'Internal error: Chosen action has not instructions in FRONTEND_ACTIONS.'
  end

endcase

; Update refresh variable
not_preview =  info.status eq 'Refresh' ? 0 : 1

; If user canceled, return the incoming image
if info.status eq 'Cancel' then begin

   image_out = image
   image_out_type = image_type

endif
   
return, image_out
end
