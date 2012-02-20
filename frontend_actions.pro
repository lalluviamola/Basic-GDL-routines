FUNCTION FRONTEND_ACTIONS, image, action, current_type, r, g, b
; This procedure does the particular operation over images. It
; "stores" every action not related directly with the frontend.

case action of

   'Binarize' : begin
      value = 1
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
