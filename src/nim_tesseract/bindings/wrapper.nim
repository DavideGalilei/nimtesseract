# libtesseract

import os, futhark

# Tell futhark where to find the C libraries you will compile with, and what
# header files you wish to import.
importc:
  absPath "/usr/include/c++/11.1.0"
  path "/usr/include/c++/11.1.0"
  path currentSourcePath().parentDir / "tesseract/include/tesseract"
  define API_CAPI_H
  "capi.h"

# Tell Nim how to compile against the library. If you have a dynamic library
# this would simply be a `--passL:"-l<library name>`
static:
  writeFile("test.c", """
  #define API_CAPI_H_
  #include "./tesseract/include/tesseract/capi.h"
  """)
{.compile: "test.c".}

# Use the library just like you would in C!
var width, height, channels: cint

var image = stbi_load("futhark.png", width.addr, height.addr, channels.addr, STBI_default.cint)
if image == nil:
  echo "Error in loading the image"
  quit 1

echo "Loaded image with a width of ", width, ", a height of ", height, " and ", channels, " channels"
stbi_image_free(image)
