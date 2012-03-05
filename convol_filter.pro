FUNCTION CONVOL_FILTER, image_in, FILTER=filter_name, HIST_EQUAL=hist_equal, BYTSCL=bytscl

; This procedure performs various spatial filtering via 2-D
; convolution with linear operator kernels on a TRUE COLOR IMAGE or a
; GRAYSCALE one


; Defaults
if N_ELEMENTS(filter_name) eq 0 then begin

   MESSAGE, 'FILTER keyword is mandatory'
   return, -1

endif
if N_ELEMENTS(hist_equal) eq 0 then hist_equal = 0
if N_ELEMENTS(bytscl)     eq 0 then bytscl     = 0


; Define linear opearator kernels
CASE filter_name of

   'boxcar_blur' : $
      filter    = (1/ 9.) * [[1, 1, 1], $ ; Boxcar      Blurring
                             [1, 1, 1], $
                             [1, 1, 1]]

   'blur_50pc' : $
      filter    = (1/10.) * [[1, 1, 1], $ ; 50%         Blurring
                             [1, 2, 1], $
                             [1, 1, 1]]

   'light_blur' : $
      filter    = (1/16.) * [[1, 1, 1], $ ; Light       Blurring
                             [1, 8, 1], $
                             [1, 1, 1]]

   'minimal_blur' : $
      filter    = (1/12.) * [[0, 1, 0], $ ; Minimal     Blurring
                             [1, 8, 1], $
                             [0, 1, 0]]

   'gauss3x3_blur' : $
      filter    = (1/16.) * [[1, 2, 1], $ ; 3x3 Gaussian   Blurring
                             [2, 4, 2], $
                             [1, 2, 1]]

   'holedonut_blur' : $
      filter   = (1/ 8.) * [[1, 1, 1], $  ; Hole-in-    Blurring
                            [1, 0, 1], $  ; the-donut
                            [1, 1, 1]]

   'classic_sharp' : $
      filter   = [[-1, -1, -1], $ ; Classic Sharpening
                  [-1,  9, -1], $
                  [-1, -1, -1]]

   'crispening_1' : $
      filter   = [[ 0, -1,  0], $ ; Crispening 1      
                  [-1,  5, -1], $
                  [ 0, -1,  0]]

   'crispening_2' : $
      filter   = [[ 1, -2,  1], $ ; Crispening 2      
                  [-2,  5, -2], $
                  [ 1, -2,  1]]

   'bassrelief_NW' : $
      filter   = [[-1,  0,  0], $        ; Bass-Relief NW    
                  [ 0,  1,  0], $
                  [ 0,  0,  0]]

   'bassrelief_N' : $
      filter   = [[ 0, -1,  0], $        ; Bass-Relief N     
                  [ 0,  1,  0], $
                  [ 0,  0,  0]]

   'bassrelief_NE' : $
      filter   = [[ 0,  0, -1], $        ; Bass-Relief NE    
                  [ 0,  1,  0], $
                  [ 0,  0,  0]]

   'bassrelief_E' : $
      filter   = [[ 0,  0,  0], $         ; Bass-relief E     
                  [ 0,  1, -1], $
                  [ 0,  0,  0]]

   'bassrelief_SE' : $
      filter   = [[ 0,  0,  0], $ ; Bass-Relief SE    
                  [ 0,  1,  0], $
                  [ 0,  0, -1]]

   'bassrelief_S' : $
      filter   = [[ 0,  0,  0], $ ; Bass-Relief S     
                  [ 0,  1,  0], $
                  [ 0, -1,  0]]

   'bassrelief_SW' : $
      filter   = [[ 0,  0,  0], $ ; Bass-Relief SW
                  [ 0,  1,  0], $
                  [-1,  0,  0]]

   'bassrelief_W' : $
      filter   = [[ 0,  0,  0], $ ; Bass-Relief W     
                  [-1,  1,  0], $
                  [ 0,  0,  0]]

   'emboss_NW' : $
      filter   = [[-1, -1,  0], $ ; Emboss NW         
                  [-1,  1,  1], $
                  [ 0,  1,  1]]

   'emboss_N' : $
      filter      = [[-1, -1, -1], $ ; Emboss N          
                     [ 0,  1,  0], $
                     [ 1,  1,  1]]

   'emboss_NE' : $
      filter      = [[ 0, -1, -1], $ ; Emboss NE         
                     [ 1,  1, -1], $
                     [ 1,  1,  0]]

   'emboss_E' : $
      filter      = [[ 1,  0, -1], $ ; Emboss E          
                     [ 1,  1, -1], $
                     [ 1,  0, -1]]

   'emboss_SE' : $
      filter      = [[ 1,  1,  1], $ ; Emboss SE         
                     [ 1,  1, -1], $
                     [ 0, -1, -1]]

   'emboss_S' : $
      filter      = [[ 1,  1,  1], $ ; Emboss S          
                     [ 0,  1,  0], $
                     [-1, -1, -1]]

   'emboss_SW' : $
      filter     = [[ 0,  1,  1], $ ; Emboss SW         
                    [-1,  1,  1], $
                    [-1, -1,  0]]

   'emboss_W' : $
      filter     = [[ 0,  1,  1], $ ; Emboss W          
                    [-1,  1,  1], $
                    [-1, -1,  0]]

   'sobel_H' : $
      filter     = [[-1, -2, -1], $ ; Sobel Horizontal  
                    [ 0,  0,  0], $
                    [ 1,  2,  1]]

   'sobel_V' : $
      filter     = [[-1,  0,  1], $ ; Sobel Verical     
                    [-2,  0,  2], $
                    [-1,  0,  1]]

   'kirsch_H' : $
      filter     = [[-3, -3, -3], $ ; Kirsch Horizontal 
                    [-3,  0, -3], $
                    [ 5,  5,  5]]

   'kirsch_V' : $
      filter     = [[-3, -3,  5], $ ; Kirsch Vertical   
                    [-3,  0,  5], $
                    [-3, -3,  5]]

   'prewitt_H' : $
      filter     = [[-1, -1, -1], $ ; Prewitt Horizontal
                    [ 1, -2,  1], $
                    [ 1,  1,  1]]
   
   'prewitt_V' : $
      filter     = [[-1,  1,  1], $ ; Prewitt Vertical
                    [-1, -2,  1], $
                    [-1,  1,  1]]

   'laplacian' : $
      filter     = [[-1, -1, -1], $ ; Laplacian         
                    [-1,  8, -1], $
                    [-1, -1, -1]]

   'Unsharp_Mask': $
      filter     = (1/256.) * [[  1,  4,   6,  4,  1], $ ; Unsharp Mask 
                               [  4, 16,  24, 16,  4], $
                               [  6, 24,  36, 24,  6], $
                               [  4, 16,  24, 16,  4], $
                               [  1 , 4,   6,  4,  1]]

   'Expd_Unitary' : $
      filter     = (1/256.) * [[  0,  0,   0,  0,  0], $ ; Expanded Unity Kernel
                               [  0,  0,   0,  0,  0], $
                               [  0,  0, 256,  0,  0], $
                               [  0,  0,   0,  0,  0], $
                               [  0,  0,   0,  0,  0]]

   'USP_Masking'  : $
      filter     = (1/256.) * [[ -2,  -8, -12,  -8,  -2], $ ; Unsharp Masking      
                               [ -8, -32, -48, -32,  -8], $
                               [-12, -48, 696, -48, -12], $
                               [ -8, -32, -48, -32,  -8], $
                               [ -2,  -8, -12,  -8,  -2]]  

   else : begin

      MESSAGE: 'Filter not recognised'
      return, -1

   end

endcase



; Start operations


; Create a image_out with the same dimensions that image_in
image_out = image_in


; Is it True-Color or Grayscale?
case SIZE(image_in) of

   2 : begin
      
      image_out = CONVOL(image_in, filter, /EDGE_TRUNCATE)

      if hist_equal then image_out = HIST_EQUAL(image_out)
      if bytscl     then image_out = BYTSCL(image_out)

   end

   3 : begin

      for i = 0, 2 do begin

         image_out[i, *, *] = CONVOL(REFORM(image_in[i, *, *]), filter, /EDGE_TRUNCATE)

         if hist_equal then image_out[i, *, *] = HIST_EQUAL(image_out[i, *, *])

         if bytscl     then image_out[i, *, *] =     BYTSCL(image_out[i, *, *])

      endfor

   end

return, image_out

end
