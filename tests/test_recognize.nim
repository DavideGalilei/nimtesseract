import std/[os, unittest, strformat, strutils]
import pixie

import nimtesseract

test "Recognize text":
    let datapath = currentSourcePath().parentDir / "eng.traineddata"

    if not fileExists(datapath):
        echo "Downloading eng data..."
        discard execShellCmd(fmt"wget -q -O {quoteShell(datapath)} https://github.com/tesseract-ocr/tessdata/raw/4767ea922bcc460e70b87b1d303ebdfed0897da8/eng.traineddata")
        echo "Finished downloading data"

    putEnv("TESSDATA_PREFIX", currentSourcePath.parentDir)

    var tess = initTesseract(
        language = "eng",
        # datapath = "",
    )

    # https://commons.wikimedia.org/wiki/File:Example_01.png
    check imageToText(currentSourcePath.parentDir / "test.png") == "Noisy image\nto test\nTesseract OCR\n"

test "Recognize text with hOCR,ALTO output":
    let datapath = currentSourcePath().parentDir / "eng.traineddata"

    if not fileExists(datapath):
        echo "Downloading eng data..."
        discard execShellCmd(fmt"wget -q -O {quoteShell(datapath)} https://github.com/tesseract-ocr/tessdata/raw/4767ea922bcc460e70b87b1d303ebdfed0897da8/eng.traineddata")
        echo "Finished downloading data"

    putEnv("TESSDATA_PREFIX", currentSourcePath.parentDir)

    var tess = initTesseract(
        language = "eng",
    )

    let imagePath = currentSourcePath.parentDir / "test.png"
    let image = readImage(imagePath)
    
    tess.setImage(
        imagedata = addr(image.data[0]),
        image.width,
        image.height,
        4 # RGBA
    )
    
    let hocrText = tess.getHOCRText()
    
    # Check that hOCR output contains expected XML structure
    check hocrText.contains("ocr_page")
    check hocrText.contains("ocr_line")
    check hocrText.contains("ocrx_word")

    let altoText = tess.getAltoText()
    
    # Check that ALTO XML output contains expected XML structure
    check altoText.contains("<Page")
    check altoText.contains("<TextLine")
    check altoText.contains("<String")
