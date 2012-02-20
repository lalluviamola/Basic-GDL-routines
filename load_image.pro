PRO LOAD_IMAGE, image, n_channels, x_size, y_size, has_palette, r, g, b, $
                interleav_type, pixel_type, image_index, num_images,     $
                image_type, filename
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Allows interactive selection of the image file,
; load the image and return the relevant array and image
; characteristics.
;
; 
; Input:          -
; Output:         image
;                 n_channels
;                 x_size (width in px)
;                 y_size (height in px)
;                 r
;                 g
;                 b
;                 interlav_type
;                 pixel_type
;                 index_image
;                 num_images
;                 image_type
;                 filename (the path of the file and name)
;         
; External calls: -
; 
; Programmer:    Daniel Molina García
; Creation date: 17 October 2011
; Environment:   i686 GNU/Linux Saturno 2.6.32-34-generic #77-Ubuntu
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

op_sys = !version.os

; set the proper sintax for the file search path depending of the OS
; version

case op_sys of
   'Linux' : s_path = !DIR + '/examples/data'
   'linux' : s_path = !DIR + '/examples/data'
   'win32' : s_path = !DIR + '\examples\data'
   'darwin': s_path = !DIR + '/examples/data'
endcase

; Interactive selection of the image
filename = Dialog_pickfile(/READ, PATH = s_path, FILTER = ['*.*','*.jpg', '*.tif', '*.png'])

print, 'Filename and path: ', filename

; Determine image characteristics

; The QUERY_IMAGE function determines whether a file is recognized
; as a supported image file. QUERY_IMAGE first checks the filename
; suffix, and if found, calls the corresponding QUERY_ routine.
; For example, if the specified file is image.bmp, QUERY_BMP is
; called to determine if the file is a valid .bmp file. If the file
; does not contain a filename suffix, or if the query fails on the
; specified filename suffix, QUERY_IMAGE checks against all supported
; file types. Source: http://idlastro.gsfc.nasa.gov

; Result is a long with the value of 1 if the query was successful
; or 0 on failure. If the file is a supported image file, an optional
; structure containing information about the image is returned.

known_format = query_image(filename, image_info)

; If the image is readable by GDL, print image characteristics.
; Otherwise, exit the program. 

case known_format of
   0 : print, 'Aborting: Unreadable'
   1 : begin

      ; display information
      print, '-- Image: ', filename

      ; # of channels
      print, '-- Number of channels: ', (n_channels = image_info.channels)
      case n_channels of
         1 : print, '-- It is a 2D image'
         3 : print, '-- It is a 3D image'
         4 : print, '-- It is a 4D image (transparency)'
      endcase

      ; Image size
      x_size = image_info.dimensions[0]
      y_size = image_info.dimensions[1]
      print, '-- Image size: width = ', x_size, ', height = ', y_size

      ; Associate palette
      case (has_palette = image_info.has_palette) of
         0 : print, '-- Palette: No palette'
         1 : print, '-- Palette: Associated palette'
      endcase

      print, '-- Image index: ', (image_index = image_info.image_index)
      print, '-- Number of images: ', (num_images = image_info.num_images)

      case  (pixel_type = image_info.pixel_type) of
         0  : pixtype = 'Undefined'
         1  : pixtype = 'Byte'
         2  : pixtype = 'Integer'
         3  : pixtype = 'Longword integer'
         4  : pixtype = 'Floating point'
         5  : pixtype = 'Double-precision floating'
         6  : pixtype = 'Complex floating'
         7  : pixtype = 'String'
         8  : pixtype = 'Structure'
         9  : pixtype = 'Double-precision complex'
         10 : pixtype = 'Pointer'
         11 : pixtype = 'Object reference'
         12 : pixtype = 'Unsigned Integer'
         13 : pixtype = 'Unsigned Longword Integer'
         14 : pixtype = '64-bit Integer'
         15 : pixtype = 'Unsigned 64-bit Integer'
      endcase
      print, '-- Pixel type: ', pixtype

      ; Image type
      print, '-- Image type: ', (image_type = image_info.type)
   end
endcase

; Load image into an array variable, depending on its format
case image_info.type of
   'BMP' : begin
      case n_channels of
         1 : begin
            case has_palette of
               0 : image = READ_BMP (filename) ; no palette
               1 : image = READ_BMP (filename, r, g, b) ; has palette
            endcase
         end
         3 : image = READ_BMP (filename, r, g, b) ; true-color
      endcase
   end
   'JPEG' : begin
      case n_channels of
         1 : READ_JPEG, filename, image
         3 : READ_JPEG, filename, image, /true ; true-color
      endcase
   end
   'PNG' : begin
      case n_channels of
         1 : begin
            case has_palette of
               0 : image = READ_PNG(filename); no palette
               1 : image = READ_PNG(filename, r, g, b) ; has palette
            endcase
         end
         3 : image =  READ_PNG(filename, r, g, b) ; true-color
         4 : image =  READ_PNG(filename, r, g, b) ; transparency
      endcase
   end
   'TIFF' : begin
      case n_channels of
         1 : begin
            case has_palette of
               0 : image = READ_TIFF (filename); no palette
               1 : image = READ_TIFF (filename, r, g, b) ; has palette
            endcase
         end
         3 : image =  READ_TIFF (filename, r, g, b) ; true-color
      endcase
   end
endcase


; Explanation about COLOR INTERLEAVING:
;
; RGB image arrays are made up of width, height, and three
; channels of color information.
;
; Color interleaving is a term used to describe which of the
; dimensions of an RGB image contain the three color channel
; values. Three types of color interleaving are supported by
; IDL: [3,w,h], [w,3,h], [w,h,3]

; You can determine if an image file contains an RGB image
; by querying the file. The CHANNELS tag of the resulting
; query structure will equal 3 if the file's image is RGB.
; The query does not determine which interleaving is used in
; the image, but the array returned in DIMENSIONS tag of the
; query structure can be used to determine the type of
; interleaving.
; Source: http://idlastro.gsfc.nasa.gov/idl_html_help/
;                  /Indexed_and_RGB_Image_Organization.html


; Define a vector with the dimensions of the image array,
; for example: [3, 1920, 1440]
image_dimensions = size(image, /dimensions)

; Determine the type of interleaving by comparing the image array
; with the known dimensions given by QUERY_IMAGE.
;
; 'where' function returns an array with the indices of those
; elements which match the conditions. If only one match,
; the array is really a scalar.
;
; If we check the 3-elements-array image_dimensions avoiding 
; match with x_size and y_size, we'll obtain the index of the
; element which indicates the number of channels.
;
; [3,w,h]: 1
; [w,3,h]: 2
; [w,h,3]: 3
;
;That index identifies the interleave type
interleav_type = where((image_dimensions NE x_size) AND $
                       (image_dimensions NE y_size)) + 1

; Display the interleaving type
print, '-- Type of interleaving: ', interleav_type
if interleav_type eq 1 then print, '([image, w, h])'
if interleav_type eq 2 then print, '([w, image, h])'
if interleav_type eq 3 then print, '([w, h, image])' 

end
