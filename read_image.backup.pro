FUNCTION READ_IMAGE, filename, r, g, b

known_format = QUERY_IMAGE(filename, image_info)

; Load image into an array variable, depending on its format
case image_info.type of
   'BMP' : begin
      case image_info.channels of
         1 : begin
            case image_info.has_palette of
               0 : image = READ_BMP (filename) ; no palette
               1 : image = READ_BMP (filename, r, g, b) ; has palette
            endcase
         end
         3 : image = READ_BMP (filename, r, g, b) ; true-color
      endcase
   end
   'JPEG' : begin
      case image_info.channels of
         1 : READ_JPEG, filename, image
         3 : READ_JPEG, filename, image, /true ; true-color
      endcase
   end
   'PNG' : begin
      case image_info.channels of
         1 : begin
            case image_info.has_palette of
               0 : image = READ_PNG(filename); no palette
               1 : image = READ_PNG(filename, r, g, b) ; has palette
            endcase
         end
         3 : image =  READ_PNG(filename, r, g, b) ; true-color
         4 : image =  READ_PNG(filename, r, g, b) ; transparency
      endcase
   end
   'TIFF' : begin
      case image_info.channels of
         1 : begin
            case image_info.has_palette of
               0 : image = READ_TIFF (filename); no palette
               1 : image = READ_TIFF (filename, r, g, b) ; has palette
            endcase
         end
         3 : image =  READ_TIFF (filename, r, g, b) ; true-color
      endcase
   end
endcase

return, image

end
