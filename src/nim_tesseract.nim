import pixie
import std/[os, options]

# https://github.com/Altabeh/tesseract-ocr-wrapper

# OLD CODE - SCROLL DOWN
# type
#     TesseractError* = ref object of CatchableError
#     TessBaseAPI* = pointer
# # About patterns:
# # https://nim-lang.org/docs/manual.html#foreign-function-interface-dynlib-pragma-for-import
# let lib = loadLibPattern("(|lib)tesseract(|.so|.dll|.dylib)")
#
# if isNil(lib):
#     raise TesseractError(msg: "Tesseract is not installed.")
# let
#     TessBaseAPICreatee* = cast[proc(): TessBaseAPI {.nimcall.}](lib.symAddr("TessBaseAPICreate"))
#     TessBaseAPIDelete* = cast[proc(self: TessBaseAPI) {.nimcall.}](lib.symAddr("TessBaseAPIDelete"))
#     # TessBaseAPIInit3* = cast[](lib.symAddr("TessBaseAPIInit3"))
#
# let tess = TessBaseAPICreate()
# echo repr(tess)
# TessBaseAPIDelete(tess)

# NEW CODE:
const pattern* = "(|lib)tesseract(|.so|.dll|.dylib)"

type
    TesseractError* = object of CatchableError
    TessBaseAPI* = pointer

    Tesseract* = object
        handle*: TessBaseAPI

proc TessBaseAPICreate*(): TessBaseAPI {.cdecl, importc, dynlib: pattern.}
proc TessBaseAPIDelete*(handle: TessBaseAPI) {.cdecl, importc, dynlib: pattern.}
proc TessBaseAPIInit3*(handle: TessBaseAPI, datapath, language: ptr cstring): cint {.cdecl, importc, dynlib: pattern.}
proc TessBaseAPISetImage*(handle: TessBaseAPI, imagedata: pointer, width, height, bytes_per_pixel, bytes_per_line: cint) {.cdecl, importc, dynlib: pattern.}
proc TessBaseAPIGetUTF8Text*(handle: TessBaseAPI): cstring {.cdecl, importc, dynlib: pattern.}
proc TessBaseAPISetVariable*(handle: TessBaseAPI, name, value: ptr cstring): bool {.cdecl, importc, dynlib: pattern.}
# proc TessBaseAPI*() {.cdecl, importc, dynlib: pattern.}

proc initTesseract*(language: Option[string] = some "eng", datapath: Option[string] = none(string)): Tesseract =
    result.handle = TessBaseAPICreate()

    var
        language = language
        datapath = datapath

        languageAddr: ptr cstring = nil
        datapathAddr: ptr cstring = nil

    if language.isSome():
        var lang = cstring(language.get())
        languageAddr = addr(lang)

    if datapath.isSome():
        var data = cstring(datapath.get())
        datapathAddr = addr(data)

    let status = TessBaseAPIInit3(
        handle = result.handle,
        datapath = datapathAddr,
        language = datapathAddr,
    )
    if int(status) == -1:
        raise newException(TesseractError, "Couldn't initialize tesseract")

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

proc setVariable*(self: Tesseract, name, value: string): bool =
    var
        name: cstring = cstring(name)
        value: cstring = cstring(value)

    return TessBaseAPISetVariable(
        handle = self.handle,
        name = addr(name),
        value = addr(value),
    )

proc getText*(self: Tesseract): string =
    let x = TessBaseAPIGetUTF8Text(handle = self.handle)
    echo "Is X nil? : ", x.isNil
    # echo "X: ", repr(x)
    return $(x)

# # https://nim-lang.org/docs/destructors.html
# proc `=destroy`*(self: var Tesseract) =
#     TessBaseAPIDelete(self.handle)

proc delete*(self: Tesseract) =
    TessBaseAPIDelete(self.handle)

proc imageToText*(path: string, datapath: Option[string] = none(string)): string =
    # TODO
    # https://github.com/tesseract-ocr/tessdata
    if not fileExists(path):
        raise newException(TesseractError, "File not found")
    
    let
        tesseract = initTesseract(datapath = datapath)
        image = readImage(path)

    echo "Len image data: ", len(image.data)

    # tesseract.setImage(
    #     imagedata = addr(image.data[0]), # https://github.com/Altabeh/tesseract-ocr-wrapper/blob/main/utils.py#L52
    #     image.width,
    #     image.height,
    #     3 # cv2: image.depth. #TODO: Nim?
    # )

    return tesseract.getText()
    # finally:
    #     tesseract.delete()
    # SEGFAULT. My guess is that getText automatically
    # destroys tesseract instance


when isMainModule:
    import strutils
    var tess = initTesseract(
        language = some "eng",
        # datapath = some "eng", # none(string)
    )
    tess.delete()
    # https://commons.wikimedia.org/wiki/File:Example_01.png
    echo "Recognized text: ", escape(imageToText("test.png"))
