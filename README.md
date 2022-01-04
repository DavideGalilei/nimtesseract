# Nim Tesseract 👑👁
![banner](/assets/banner.jpg)
Nim Tesseract is a Nim wrapper for the [Tesseract](https://github.com/tesseract-ocr/tesseract/) OCR library, via its dynamic library.

## Installation 👇
```bash
$ nimble install https://github.com/DavideGalilei/nimtesseract
```

## Usage 🌷
1. Install (lib)tesseract via your packet manager or put the tesseract so/dll/dylib file in the project directory
E.g. for Arch Linux (from AUR):
```bash
$ yay -Sy tesseract
```
2. Download trained data from https://github.com/tesseract-ocr/tessdata or https://github.com/tesseract-ocr/tessdata_fast
3. Done ✅

## Example 🤔
```nim
import nimtesseract

echo imageToText("file.png")
```
More examples in the [examples folder](/examples)

## Development 🔩
Download trained data and put it into src folder

> ⚠️ Outdated, but still useful. Don't refer to this.
> ```bash
> $ cd src
> $ TESSDATA_PREFIX=$(pwd) nim r -d:pixieUseStb nimtesseract.nim
> ```

Run tests with nimble:
```bash
$ nimble test
```

`capi.h` reference: https://github.com/tesseract-ocr/tesseract/blob/main/include/tesseract/capi.h

## Credits 👻
Inspired from https://github.com/Altabeh/tesseract-ocr-wrapper

## License 📕
This project is under the `Unlicense` license.
This is free and unencumbered software released into the public domain.
