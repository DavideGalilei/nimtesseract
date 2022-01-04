import pixie

import std/[os, json]
import ../src/nimtesseract

# We get a handle to the created Tesseract instance
let handle = TessBaseAPICreate()

# Initialize it
let status = TessBaseAPIInit3(
    handle = handle,
    language = cstring("eng"),
    datapath = cstring(currentSourcePath() / "../../tests"),
)

# Check if things went wrong
if int(status) == -1:
    raise newException(TesseractError, "Couldn't initialize tesseract")

# Open the image with Pixie
let imagePath = currentSourcePath.parentDir / "test.png"
var image = readImage(imagePath)

# Pixie stores images as a list of RGBA tuples, hence 4 bytes each
const bytesPerPixel = 4

# Set the image to recognize the text from
TessBaseAPISetImage(
    handle = handle,
    imagedata = addr(image.data[0]), # Note the [0], from where the actual pixels start
    width = cint(image.width),
    height = cint(image.height),
    bytes_per_pixel = cint(bytesPerPixel),
    bytes_per_line = cint(image.width * bytesPerPixel),
)

# Set the PPI
TessBaseAPISetSourceResolution(
    handle = handle,
    ppi = cint(70),
)

# Get the text. Note: since it's a cstring,
# we need to convert it back to Nim's string
# using cstring's `$` procedure.
let text = $TessBaseAPIGetUTF8Text(handle = handle)

# Don't forget to clean up to avoid memory leaks!
TessBaseAPIDelete(handle = handle)

echo "Recognized text: ", escapeJson(text)
# Should look like "Noisy image\nto test\nTesseract OCR\n"
