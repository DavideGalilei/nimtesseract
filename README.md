> # ⚠️ NOT WORKING YET - Work in progress

# Nim Tesseract
Nim Tesseract is a Nim wrapper for the [Tesseract](https://github.com/tesseract-ocr/tesseract/) OCR library, via its dynamic library.

#TODO
 - Working library
 -  - Recognize text
 -  - Choose between pixie (I don't know how to get a proper imagedata and pixel depth) or nim cv2 lib (outdated)
 - Better description
 - Fix memory leaks
 - Fix `=destroy` maybe
 - Rename modules from `nim_tesseract` to `nimtesseract`
 - Remove bindings directory (failed attempts to create bindings via futhark of tesseract's `capi.h`)

## Installation
```bash
$ nimble install https://github.com/DavideGalilei/nimtesseract
```

## Usage
Install (lib)tesseract via your packet manager or put the tesseract so/dll/dylib file in the project directory.

E.g. for Arch Linux (from AUR):
```bash
$ yay -Sy tesseract
```

## Example
```nim
discard "#TODO"
```

## Credits
Inspired from https://github.com/Altabeh/tesseract-ocr-wrapper

## License
#TODO ...
