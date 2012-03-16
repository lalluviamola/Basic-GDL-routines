FUNCTION GRAB_BUTTON, ev 

  ; Get the 'stash' structure. 
  WIDGET_CONTROL, ev.TOP, GET_UVALUE = stash 

  ; Get the value and user value (indicating block of options)
  ; from the widget that generated the event. 
  WIDGET_CONTROL, ev.ID, GET_VALUE = option, GET_UVALUE = group

  (*stash.ptrInfo).options[group] = option

  ; Reset the top-level widget's user value to the updated 
  ; 'stash' structure. 
  WIDGET_CONTROL, ev.TOP, SET_UVALUE = stash 
END 


FUNCTION WIDGET_ASK_TRANSFORMATION_PARAMETERS, $
   info,                             $
   PARAMETERS   = parameters,        $
   RANGE        = range,             $
   FRANGE       = frange,            $
   LABEL        = label,             $
   EXCL_OPTS1   = excl_options,      $
   EXCL_OPTS2   = excl_options_2,    $
   EXCL_LABEL1  = excl_label,        $
   EXCL_LABEL2  = excl_label_2

; ATENTION: I don't know why, the image window goes to background
;           when this function is called after choosen
;           'Cancel' button 
;
; Input: PARAMETERS idea is not really implemented yet

; Define a pointer for getting information about button pressed by the
; user 
ptrStatus = Ptr_New('')

; Define a pointer for getting information about chosen setting values
; but if it is a refresh, use the last values
if info.status ne 'Init' then begin

   ptrInfo   = Ptr_New({options:info.options, value:info.value})

; If not, initialize them
endif else begin

   ; Define initial value of the Slider depending of selected RANGE
   if (N_ELEMENTS(range) eq 0) && (N_ELEMENTS(frange) eq 0)      $
      then value = 0                                             $
      else value = (N_ELEMENTS(range) eq 0) ? frange[0] : range[0]

   ptrInfo   = Ptr_New( {options: [0, 0], value: value} )

endelse

; Define main base for the widget
mainBase    = WIDGET_BASE(/COLUMN)

; Define a second base for keeping slider and options
secondBase = WIDGET_BASE(mainBase, /ROW)

; Create slider, if requested
if (N_ELEMENTS(range) ne 0) || (N_ELEMENTS(frange) ne 0) then begin

   label1     = WIDGET_LABEL(secondbase, VALUE = label)

   if N_ELEMENTS(range) ne 0 $
   
   then slider = WIDGET_SLIDER(secondBase,                   $
                               VALUE = (*ptrInfo).value,     $
                               MINIMUM   = range[0],         $
                               MAXIMUM   = range[1])         $

   else slider = CW_FSLIDER(secondBase,                      $
                            VALUE = (*ptrInfo).value,        $
                            UNAME = 'fslider',               $
                            MINIMUM   = frange[0],           $
                            MAXIMUM   = frange[1])   

endif



; Create first group of options, if requested
if N_ELEMENTS(excl_options) ne 0 then begin

   options_1  = CW_BGROUP(secondBase, excl_options,           $
                          LABEL_TOP  = excl_label,            $
                          SET_VALUE  = (*ptrInfo).options[0], $
                          
                                ; UVALUE is the key for knowing which
                                ; block of options matters during
                                ; execution of EVENT_FUNC
                          UVALUE = 0,                        $
                          EVENT_FUNC = 'GRAB_BUTTON',        $ 
                          /COLUMN, /EXCLUSIVE)

   ; If requested, create a second group
   if N_ELEMENTS(excl_options_2) ne 0 then begin

      options_2  = CW_BGROUP(secondBase, excl_options_2,         $
                             LABEL_TOP  = excl_label_2,          $
                             SET_VALUE  = (*ptrInfo).options[1], $
                             UVALUE = 1,                         $
                             EVENT_FUNC = 'GRAB_BUTTON',         $ 
                             /COLUMN, /EXCLUSIVE)

   endif
   
endif

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

output = {   value:(*ptrInfo).value,         $
           options:(*ptrInfo).options,       $
            status:(*ptrStatus)}

; Free allocated memory
Ptr_Free, ptrInfo
Ptr_Free, ptrStatus

return, output

END


FUNCTION FRONTEND_ACTIONS, image, action,              $
                           image_type, image_out_type, $
                           r, g, b,                    $
                           r_out, g_out, b_out,        $
                           not_preview, info
; DESCRIPTION: This procedure select which operation is used with any action
;
; NOTE: Any action must over-write image_out_type and not_preview if
; neccesary
;
; Any action can take advantage of the above defined FUNCTION
; WIDGET_ASK_TRANSFORMATION_PARAMETERS.
;
;
; INPUT: image          Image to apply the action
;        action         Action to apply
;        image_type     Type of image
;        image_out_type Type of returned image
;        r,g,b          Palette (if any). WARNING: It can be
;                       over-written for convenience.
;        not_preview    (really an output)
;        info           (really an output, although it is used)
;        EXPLAIN ME!

case action of

   'Binarize' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS(  $
             info,                                  $
             LABEL       = 'Level of threshold:',   $
             RANGE       = [0, 100],                $
             EXCL_OPTS1  = ['LE', 'GT'],            $
             EXCL_LABEL1 = 'Mode of threshold: ')

      if info.status ne 'Cancel' then begin

         image_out = BINARIZE(image, info.value, MODE = info.options[0])
         image_out_type = 'binary'

      endif

   end

   'Quantize' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS(               $
             info,                                               $
             EXCL_OPTS1    = ['No', 'Yes'],                      $
             EXCL_LABEL1   = 'Pseudo-Grayscale?',                $
             EXCL_OPTS2    = ['Average','Red', 'Green', 'Blue'], $  
             EXCL_LABEL2   = 'If Yes, which component to use?')

      if info.status ne 'Cancel' then begin

         PSEUDO_COLOR, image, image_out, r_out, g_out, b_out,    $
                       PSEUDO_GRAYSCALE = info.options[0],       $
                       GRAY_COMPONENT =  (['3', 'r', 'g', 'b'])[ info.options[1] ]

         image_out_type = 'palette'

      endif

   end

   'Undersample' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS(               $
             info,                                               $
             RANGE = [2, 10],                                    $
             LABEL = 'Set rebin factor:')                        

      if info.status ne 'Cancel' then begin

         image_out = SPATIAL_TRANSFORMATION(image, /UNDERSAMPLE,      $
                                            REBIN_FACTOR = info.value)
         
         image_out_type = image_type

      endif

   end

   'Oversample' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS(                 $
             info,                                                 $
             RANGE = [2, 10],                                      $
             LABEL = 'Set rebin factor:',                          $
             EXCL_LABEL1 = 'Choose Method:',                       $
             EXCL_OPTS1  = ['Nearest Neighbour', 'Bilinear Interpolation'])

      if info.status ne 'Cancel' then begin

         image_out = SPATIAL_TRANSFORMATION(image, /OVERSAMPLE,               $
                                            REBIN_FACTOR = info.value,        $
                                            NEAR     = info.options[0] eq 0,  $
                                            BILINEAR = info.options[0] eq 1)

         image_out_type = image_type

      endif

   end

   'Rotate' : begin

      info = WIDGET_ASK_TRANSFORMATION_PARAMETERS(                 $
             info,                                                 $
             RANGE = [0, 360],                                     $
             LABEL = 'Set rotation angle (degrees):',              $              
             EXCL_LABEL1 = 'Choose Method:',                       $
             EXCL_OPTS1  = ['Nearest Neighbour', 'Bilinear Interpolation', 'ROT IDL procedure'])


      if info.status ne 'Cancel' then begin

         if info.options[0] eq 2 then image_out = ROT(image, info.value) else begin

            image_out = SPATIAL_TRANSFORMATION(image, /TRANSROT,                $
                                               ROT_VALUE = info.value * !DTOR,  $
                                               TRANS_VALUES = [0, 0],           $
                                               NEAR     = info.options[0] eq 0, $
                                               BILINEAR = info.options[0] eq 1)

            image_out_type = image_type

         endelse

      endif

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
   info.status = 'Init'

endif

if info.status eq 'Done' then info.status = 'Init'
   
return, image_out
end
