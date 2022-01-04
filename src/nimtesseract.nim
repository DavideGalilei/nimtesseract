import pixie
import std/[os, json, options]


const pattern* = "(|lib)tesseract(|.so|.dll|.dylib)"

type
    TesseractError* = object of CatchableError
    TessBaseAPI* = pointer

    Tesseract* = object
        handle*: TessBaseAPI


proc TessBaseAPICreate*(): TessBaseAPI {.importc, dynlib: pattern.}
proc TessBaseAPIInit3*(handle: TessBaseAPI, datapath, language: cstring): cint {.importc, dynlib: pattern.}
proc TessBaseAPIDelete*(handle: TessBaseAPI) {.importc, dynlib: pattern.}
proc TessBaseAPISetVariable*(handle: TessBaseAPI, name, value: cstring): bool {.importc, dynlib: pattern.}
proc TessBaseAPISetImage*(handle: TessBaseAPI, imagedata: pointer, width, height, bytes_per_pixel, bytes_per_line: cint) {.importc, dynlib: pattern.}
proc TessBaseAPISetSourceResolution*(handle: TessBaseAPI, ppi: cint) {.importc, dynlib: pattern.}
proc TessBaseAPIGetUTF8Text*(handle: TessBaseAPI): cstring {.importc, dynlib: pattern.}
# proc TessBaseAPI*() {.importc, dynlib: pattern.}


proc initTesseract*(language: Option[string] = some "eng", datapath: Option[string] = none(string)): Tesseract =
    result.handle = TessBaseAPICreate()

    var
        languageParam: cstring
        datapathParam: cstring

    if language.isSome():
        languageParam = cstring(language.get())

    if datapath.isSome():
        datapathParam = cstring(datapath.get())

    let status = TessBaseAPIInit3(
        handle = result.handle,
        datapath = datapathParam,
        language = languageParam,
    )
    if int(status) == -1:
        raise newException(TesseractError, "Couldn't initialize tesseract")


# https://nim-lang.org/docs/destructors.html
proc `=destroy`*(self: var Tesseract) =
    if not isNil(self.handle):
        TessBaseAPIDelete(self.handle)
        self.handle = nil


proc delete*(self: Tesseract) =
    TessBaseAPIDelete(self.handle)


proc setVariable*(self: Tesseract, name, value: string): bool =
    return TessBaseAPISetVariable(
        handle = self.handle,
        name = cstring(name),
        value = cstring(value),
    )


proc setImage*(self: Tesseract, imagedata: pointer, width, height, bytesPerPixel: int, bytesPerLine: Option[int] = none(int)) =
    var
        # imagedata: cstring = cstring(imagedata)
        width: cint = cint(width)
        height: cint = cint(height)
        bytesPerPixel: cint = cint(bytesPerPixel)

        bytesPerLine: cint = if bytesPerLine.isSome: cint(bytesPerLine.get())
            else: width * bytesPerPixel

    TessBaseAPISetImage(
        self.handle,
        imagedata,
        width,
        height,
        bytesPerPixel,
        bytesPerLine,
    )


proc setSourceResolution(self: Tesseract, ppi: int) =
    TessBaseAPISetSourceResolution(self.handle, cint(ppi))


proc getText*(self: Tesseract): string =
    return $TessBaseAPIGetUTF8Text(handle = self.handle)


proc imageToText*(path: string, language: Option[string] = some "eng", datapath: Option[string] = none(string), ppi: int = 70): string =
    if not fileExists(path):
        raise newException(TesseractError, "File not found: " & escapeJson(path))

    let
        tesseract = initTesseract(datapath = datapath, language = language)
        image = readImage(path)

    tesseract.setImage(
        imagedata = addr(image.data[0]), # https://github.com/Altabeh/tesseract-ocr-wrapper/blob/main/utils.py#L52
        image.width,
        image.height,
        4 # Pixie uses RGBA every time, 4 bytes each
    )
    tesseract.setSourceResolution(ppi)
    # Fixes annoying warning: "Warning: Invalid resolution 0 dpi. Using 70 instead."
    # https://stackoverflow.com/a/58296472

    result = tesseract.getText()
    # tesseract.delete()
    # Automatically freed by destructor
    # Leaving delete() proc for convenience, just in case
