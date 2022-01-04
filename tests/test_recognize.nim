import std/[os, unittest, options, strformat]

import nimtesseract

test "Recognize text":
    let datapath = currentSourcePath().parentDir / "eng.traineddata"

    if not fileExists(datapath):
        echo "Downloading eng data..."
        discard execShellCmd(fmt"wget -q -O {quoteShell(datapath)} https://github.com/tesseract-ocr/tessdata/raw/4767ea922bcc460e70b87b1d303ebdfed0897da8/eng.traineddata")
        echo "Finished downloading data"

    putEnv("TESSDATA_PREFIX", currentSourcePath.parentDir)

    var tess = initTesseract(
        language = some "eng",
        # datapath = some "eng", # none(string)
    )

    # https://commons.wikimedia.org/wiki/File:Example_01.png
    check imageToText(currentSourcePath.parentDir / "test.png") == "Noisy image\nto test\nTesseract OCR\n"
