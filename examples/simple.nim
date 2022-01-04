import std/[os, json, options]
import ../src/nimtesseract

# Make sure you downloaded eng.traineddata file
let recognized = imageToText(
    "test.png",
    language = some "eng",
    datapath = some currentSourcePath() / "../../tests"
)
echo "Recognized text: ", escapeJson(recognized)
# Should look like "Noisy image\nto test\nTesseract OCR\n"
