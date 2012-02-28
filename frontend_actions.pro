FUNCTION WIDGET_ASK_VALUE, RANGE=range, LABEL=label, $
                           MINIMUM = minimum, MAXIMUM = MAXIMUM

; Define a base for the widget
wBase    = WIDGET_BASE(/COLUMN)

; Define the label at top
wLabel   = WIDGET_LABEL(wBase, VALUE = label)

; Define an slider depending on RANGE
wSlider  = WIDGET_SLIDER(wBase,                                 $
                         MINIMUM = range[0], MAXIMUM = range[1])

; Define a lonely OK button
bOK      = WIDGET_BUTTON(wbase, VALUE = 'OK')

; Define the user structure which will be associated to wBase
stash = {bOK:bOK, value:1}

; Display the widget and associate the structure to wBase
WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, wBase, SET_UVALUE = stash

; Let work FRONTEND_EVENTS until widget will be destroyed
XMANAGER, 'FRONTEND', wBase

return, value

END

FUNCTION FRONTEND_ACTIONS, image, action, current_type, r, g, b
; This procedure does the particular operation over images. It
; "stores" every action not related directly with the frontend.

case action of

   'Binarize' : begin
      value = 1
      value = WIDGET_ASK_VALUE, RANGE = [0, 100], LABEL = 'Choose Value:'
      read, PROMPT = 'Level of threshold (0-100): ', value
      image_out = BINARIZE(image, value)
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

return, image_out
end
