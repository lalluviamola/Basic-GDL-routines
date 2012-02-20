PRO FFT_ANALYZE_SIN_PATTERN, DIMENSION=dimension, ROTATION=rotation 

LOADCT, 1

; Set defaults
if N_ELEMENTS(dimension) eq 0 then dimension = 0
if N_ELEMENTS(rotation) eq 0 then rotation = 0


; Generate sinusoidal pattern as a vector
N = 256                         ; N is the number of points of our pattern
x = FINDGEN(N)                  ; Create the pattern array

for i = 20, 5, -5 do begin
                                ; Create the pattern array
   y = SIN(x * !PI / i)

   ; Creating image according to dimensions and if will be rotated
   if dimension eq 0 then begin
      image_x = REBIN(y, 2*N, 2*N)
      image_y = ROT(image_x, 90, /INTERP)
      image   = image_x + image_y
   endif else begin
      ; Increase size if rotation
      if rotation eq 0 then image = REBIN(y, N, N) $
      else image = REBIN(y, 2*N, 2*N)
   endelse

   ; If we want to analyze y-direction, rotate the pattern 
   if dimension eq 2 then image = ROTATE(image, 1)

   ; Rotate and crop 
   if rotation ne 0 then begin
      image = ROT(image, rotation, /INTERP)
      image = image[(N - N/2 + 1) : (N + N/2 - 1), (N - N/2 + 1) : (N + N/2 - 1)]
   endif

   ;Show the pattern (it's neccesary for PROFILES procedure)
   WINDOW, 0, XSIZE = N, YSIZE = N, XPOS = 2*N, YPOS = 0, TITLE = 'Original Pattern'
   TVSCL, image
   PRESS_MOUSE

                                ; Interactively analyze patter with
                                ; graphic cursor
   PROFILES, image
                                ; Compute and display Fourier spectra
                                ; (global, x and y)
   M = N / 2
                                ; Global Fourier Spectra
   fft2 = FFT(image, -1)
   powersp2 = (ABS(fft2))^2
   powersp2 = SHIFT(powersp2, M, M)

                                ; x-direction Fourier Spectra
   fft2_x = FFT(image, DIMENSION = 1)
   powersp2_x = (ABS(fft2_x))^2
   powersp2_x = SHIFT(powersp2_x, M, M)

                                ; y-direction Fourier Spectra
   fft2_y = FFT(image, DIMENSION = 2)
   powersp2_y = (ABS(fft2_y))^2
   powersp2_y = SHIFT(powersp2_y, M, M)

                                ; Display Image and Spectra
   WINDOW, 0, XSIZE = 2 * N, YSIZE = 2 * N, XPOS = 2*N, YPOS = 0, $
           TITLE='Original Pattern (i=' + STRING(STRTRIM(i)) + '), Power Spectrum, (~ in x), (~ in y)'
   TVSCL, image, 0
   TVSCL, ALOG10(powersp2), 1
   TVSCL, ALOG10(powersp2_x), 2
   TVSCL, ALOG10(powersp2_y), 3
   
   PRESS_MOUSE
endfor

wdelete, 0

END
