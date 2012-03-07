PRO RADON_TRANSFORM_EXAMPLE

; Copy header for main procedure

; ...

; Load mono-chrome image
READ_JPEG, 'Text_Angle.jpg', image_1, /GRAYSCALE

; Derive image size
x_size = (SIZE(image_1))[1]
y_size = (SIZE(image_1))[2]

; 
