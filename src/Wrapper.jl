module Wrapper

using libavif_jll
export libavif_jll

using CEnum

const avifBool = Cint

@cenum avifPlanesFlag::UInt32 begin
    AVIF_PLANES_YUV = 1
    AVIF_PLANES_A = 2
    AVIF_PLANES_ALL = 255
end

const avifPlanesFlags = UInt32

@cenum avifChannelIndex::UInt32 begin
    AVIF_CHAN_Y = 0
    AVIF_CHAN_U = 1
    AVIF_CHAN_V = 2
    AVIF_CHAN_A = 3
end

function avifVersion()
    ccall((:avifVersion, libavif), Ptr{Cchar}, ())
end

function avifCodecVersions(outBuffer)
    ccall((:avifCodecVersions, libavif), Cvoid, (Ptr{Cchar},), outBuffer)
end

function avifLibYUVVersion()
    ccall((:avifLibYUVVersion, libavif), Cuint, ())
end

function avifAlloc(size)
    ccall((:avifAlloc, libavif), Ptr{Cvoid}, (Csize_t,), size)
end

function avifFree(p)
    ccall((:avifFree, libavif), Cvoid, (Ptr{Cvoid},), p)
end

@cenum avifResult::UInt32 begin
    AVIF_RESULT_OK = 0
    AVIF_RESULT_UNKNOWN_ERROR = 1
    AVIF_RESULT_INVALID_FTYP = 2
    AVIF_RESULT_NO_CONTENT = 3
    AVIF_RESULT_NO_YUV_FORMAT_SELECTED = 4
    AVIF_RESULT_REFORMAT_FAILED = 5
    AVIF_RESULT_UNSUPPORTED_DEPTH = 6
    AVIF_RESULT_ENCODE_COLOR_FAILED = 7
    AVIF_RESULT_ENCODE_ALPHA_FAILED = 8
    AVIF_RESULT_BMFF_PARSE_FAILED = 9
    AVIF_RESULT_MISSING_IMAGE_ITEM = 10
    AVIF_RESULT_DECODE_COLOR_FAILED = 11
    AVIF_RESULT_DECODE_ALPHA_FAILED = 12
    AVIF_RESULT_COLOR_ALPHA_SIZE_MISMATCH = 13
    AVIF_RESULT_ISPE_SIZE_MISMATCH = 14
    AVIF_RESULT_NO_CODEC_AVAILABLE = 15
    AVIF_RESULT_NO_IMAGES_REMAINING = 16
    AVIF_RESULT_INVALID_EXIF_PAYLOAD = 17
    AVIF_RESULT_INVALID_IMAGE_GRID = 18
    AVIF_RESULT_INVALID_CODEC_SPECIFIC_OPTION = 19
    AVIF_RESULT_TRUNCATED_DATA = 20
    AVIF_RESULT_IO_NOT_SET = 21
    AVIF_RESULT_IO_ERROR = 22
    AVIF_RESULT_WAITING_ON_IO = 23
    AVIF_RESULT_INVALID_ARGUMENT = 24
    AVIF_RESULT_NOT_IMPLEMENTED = 25
    AVIF_RESULT_OUT_OF_MEMORY = 26
    AVIF_RESULT_CANNOT_CHANGE_SETTING = 27
    AVIF_RESULT_INCOMPATIBLE_IMAGE = 28
    AVIF_RESULT_NO_AV1_ITEMS_FOUND = 10
end

function avifResultToString(result)
    ccall((:avifResultToString, libavif), Ptr{Cchar}, (avifResult,), result)
end

mutable struct avifROData
    data::Ptr{UInt8}
    size::Csize_t
    avifROData() = new()
end
function Base.getproperty(x::Ptr{avifROData}, f::Symbol)
    f === :data && return Ptr{Ptr{UInt8}}(x + 0)
    f === :size && return Ptr{Csize_t}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{avifROData}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


mutable struct avifRWData
    data::Ptr{UInt8}
    size::Csize_t
end
function Base.getproperty(x::Ptr{avifRWData}, f::Symbol)
    f === :data && return Ptr{Ptr{UInt8}}(x + 0)
    f === :size && return Ptr{Csize_t}(x + 8)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{avifRWData}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


function avifRWDataRealloc(raw, newSize)
    ccall((:avifRWDataRealloc, libavif), avifResult, (Ptr{avifRWData}, Csize_t), raw, newSize)
end

function avifRWDataSet(raw, data, len)
    ccall((:avifRWDataSet, libavif), avifResult, (Ptr{avifRWData}, Ptr{UInt8}, Csize_t), raw, data, len)
end

function avifRWDataFree(raw)
    ccall((:avifRWDataFree, libavif), Cvoid, (Ptr{avifRWData},), raw)
end

function avifGetExifTiffHeaderOffset(exif, exifSize, offset)
    ccall((:avifGetExifTiffHeaderOffset, libavif), avifResult, (Ptr{UInt8}, Csize_t, Ptr{Csize_t}), exif, exifSize, offset)
end

function avifGetExifOrientationOffset(exif, exifSize, offset)
    ccall((:avifGetExifOrientationOffset, libavif), avifResult, (Ptr{UInt8}, Csize_t, Ptr{Csize_t}), exif, exifSize, offset)
end

@cenum avifPixelFormat::UInt32 begin
    AVIF_PIXEL_FORMAT_NONE = 0
    AVIF_PIXEL_FORMAT_YUV444 = 1
    AVIF_PIXEL_FORMAT_YUV422 = 2
    AVIF_PIXEL_FORMAT_YUV420 = 3
    AVIF_PIXEL_FORMAT_YUV400 = 4
    AVIF_PIXEL_FORMAT_COUNT = 5
end

function avifPixelFormatToString(format)
    ccall((:avifPixelFormatToString, libavif), Ptr{Cchar}, (avifPixelFormat,), format)
end

mutable struct avifPixelFormatInfo
    monochrome::avifBool
    chromaShiftX::Cint
    chromaShiftY::Cint
    avifPixelFormatInfo() = new()
end

function avifGetPixelFormatInfo(format, info)
    ccall((:avifGetPixelFormatInfo, libavif), Cvoid, (avifPixelFormat, Ptr{avifPixelFormatInfo}), format, info)
end

@cenum avifChromaSamplePosition::UInt32 begin
    AVIF_CHROMA_SAMPLE_POSITION_UNKNOWN = 0
    AVIF_CHROMA_SAMPLE_POSITION_VERTICAL = 1
    AVIF_CHROMA_SAMPLE_POSITION_COLOCATED = 2
end

@cenum avifRange::UInt32 begin
    AVIF_RANGE_LIMITED = 0
    AVIF_RANGE_FULL = 1
end

@cenum var"##Ctag#230"::UInt32 begin
    AVIF_COLOR_PRIMARIES_UNKNOWN = 0
    AVIF_COLOR_PRIMARIES_BT709 = 1
    AVIF_COLOR_PRIMARIES_IEC61966_2_4 = 1
    AVIF_COLOR_PRIMARIES_UNSPECIFIED = 2
    AVIF_COLOR_PRIMARIES_BT470M = 4
    AVIF_COLOR_PRIMARIES_BT470BG = 5
    AVIF_COLOR_PRIMARIES_BT601 = 6
    AVIF_COLOR_PRIMARIES_SMPTE240 = 7
    AVIF_COLOR_PRIMARIES_GENERIC_FILM = 8
    AVIF_COLOR_PRIMARIES_BT2020 = 9
    AVIF_COLOR_PRIMARIES_XYZ = 10
    AVIF_COLOR_PRIMARIES_SMPTE431 = 11
    AVIF_COLOR_PRIMARIES_SMPTE432 = 12
    AVIF_COLOR_PRIMARIES_EBU3213 = 22
end

const avifColorPrimaries = UInt16

function avifColorPrimariesGetValues(acp, outPrimaries)
    ccall((:avifColorPrimariesGetValues, libavif), Cvoid, (avifColorPrimaries, Ptr{Cfloat}), acp, outPrimaries)
end

function avifColorPrimariesFind(inPrimaries, outName)
    ccall((:avifColorPrimariesFind, libavif), avifColorPrimaries, (Ptr{Cfloat}, Ptr{Ptr{Cchar}}), inPrimaries, outName)
end

@cenum var"##Ctag#231"::UInt32 begin
    AVIF_TRANSFER_CHARACTERISTICS_UNKNOWN = 0
    AVIF_TRANSFER_CHARACTERISTICS_BT709 = 1
    AVIF_TRANSFER_CHARACTERISTICS_UNSPECIFIED = 2
    AVIF_TRANSFER_CHARACTERISTICS_BT470M = 4
    AVIF_TRANSFER_CHARACTERISTICS_BT470BG = 5
    AVIF_TRANSFER_CHARACTERISTICS_BT601 = 6
    AVIF_TRANSFER_CHARACTERISTICS_SMPTE240 = 7
    AVIF_TRANSFER_CHARACTERISTICS_LINEAR = 8
    AVIF_TRANSFER_CHARACTERISTICS_LOG100 = 9
    AVIF_TRANSFER_CHARACTERISTICS_LOG100_SQRT10 = 10
    AVIF_TRANSFER_CHARACTERISTICS_IEC61966 = 11
    AVIF_TRANSFER_CHARACTERISTICS_BT1361 = 12
    AVIF_TRANSFER_CHARACTERISTICS_SRGB = 13
    AVIF_TRANSFER_CHARACTERISTICS_BT2020_10BIT = 14
    AVIF_TRANSFER_CHARACTERISTICS_BT2020_12BIT = 15
    AVIF_TRANSFER_CHARACTERISTICS_SMPTE2084 = 16
    AVIF_TRANSFER_CHARACTERISTICS_SMPTE428 = 17
    AVIF_TRANSFER_CHARACTERISTICS_HLG = 18
end

const avifTransferCharacteristics = UInt16

function avifTransferCharacteristicsGetGamma(atc, gamma)
    ccall((:avifTransferCharacteristicsGetGamma, libavif), avifResult, (avifTransferCharacteristics, Ptr{Cfloat}), atc, gamma)
end

function avifTransferCharacteristicsFindByGamma(gamma)
    ccall((:avifTransferCharacteristicsFindByGamma, libavif), avifTransferCharacteristics, (Cfloat,), gamma)
end

@cenum var"##Ctag#232"::UInt32 begin
    AVIF_MATRIX_COEFFICIENTS_IDENTITY = 0
    AVIF_MATRIX_COEFFICIENTS_BT709 = 1
    AVIF_MATRIX_COEFFICIENTS_UNSPECIFIED = 2
    AVIF_MATRIX_COEFFICIENTS_FCC = 4
    AVIF_MATRIX_COEFFICIENTS_BT470BG = 5
    AVIF_MATRIX_COEFFICIENTS_BT601 = 6
    AVIF_MATRIX_COEFFICIENTS_SMPTE240 = 7
    AVIF_MATRIX_COEFFICIENTS_YCGCO = 8
    AVIF_MATRIX_COEFFICIENTS_BT2020_NCL = 9
    AVIF_MATRIX_COEFFICIENTS_BT2020_CL = 10
    AVIF_MATRIX_COEFFICIENTS_SMPTE2085 = 11
    AVIF_MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL = 12
    AVIF_MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL = 13
    AVIF_MATRIX_COEFFICIENTS_ICTCP = 14
    AVIF_MATRIX_COEFFICIENTS_LAST = 15
end

const avifMatrixCoefficients = UInt16

struct avifDiagnostics
    error::NTuple{256, Cchar}
end

function avifDiagnosticsClearError(diag)
    ccall((:avifDiagnosticsClearError, libavif), Cvoid, (Ptr{avifDiagnostics},), diag)
end

struct avifFraction
    n::Int32
    d::Int32
end

@cenum avifTransformFlag::UInt32 begin
    AVIF_TRANSFORM_NONE = 0
    AVIF_TRANSFORM_PASP = 1
    AVIF_TRANSFORM_CLAP = 2
    AVIF_TRANSFORM_IROT = 4
    AVIF_TRANSFORM_IMIR = 8
end

const avifTransformFlags = UInt32

struct avifPixelAspectRatioBox
    hSpacing::UInt32
    vSpacing::UInt32
end

struct avifCleanApertureBox
    widthN::UInt32
    widthD::UInt32
    heightN::UInt32
    heightD::UInt32
    horizOffN::UInt32
    horizOffD::UInt32
    vertOffN::UInt32
    vertOffD::UInt32
end

struct avifImageRotation
    angle::UInt8
end

struct avifImageMirror
    axis::UInt8
end

struct avifCropRect
    x::UInt32
    y::UInt32
    width::UInt32
    height::UInt32
end

function avifCropRectConvertCleanApertureBox(cropRect, clap, imageW, imageH, yuvFormat, diag)
    ccall((:avifCropRectConvertCleanApertureBox, libavif), avifBool, (Ptr{avifCropRect}, Ptr{avifCleanApertureBox}, UInt32, UInt32, avifPixelFormat, Ptr{avifDiagnostics}), cropRect, clap, imageW, imageH, yuvFormat, diag)
end

function avifCleanApertureBoxConvertCropRect(clap, cropRect, imageW, imageH, yuvFormat, diag)
    ccall((:avifCleanApertureBoxConvertCropRect, libavif), avifBool, (Ptr{avifCleanApertureBox}, Ptr{avifCropRect}, UInt32, UInt32, avifPixelFormat, Ptr{avifDiagnostics}), clap, cropRect, imageW, imageH, yuvFormat, diag)
end

struct avifContentLightLevelInformationBox
    maxCLL::UInt16
    maxPALL::UInt16
end

struct avifImage
    width::UInt32
    height::UInt32
    depth::UInt32
    yuvFormat::avifPixelFormat
    yuvRange::avifRange
    yuvChromaSamplePosition::avifChromaSamplePosition
    yuvPlanes::NTuple{3, Ptr{UInt8}}
    yuvRowBytes::NTuple{3, UInt32}
    imageOwnsYUVPlanes::avifBool
    alphaPlane::Ptr{UInt8}
    alphaRowBytes::UInt32
    imageOwnsAlphaPlane::avifBool
    alphaPremultiplied::avifBool
    icc::avifRWData
    colorPrimaries::avifColorPrimaries
    transferCharacteristics::avifTransferCharacteristics
    matrixCoefficients::avifMatrixCoefficients
    clli::avifContentLightLevelInformationBox
    transformFlags::avifTransformFlags
    pasp::avifPixelAspectRatioBox
    clap::avifCleanApertureBox
    irot::avifImageRotation
    imir::avifImageMirror
    exif::avifRWData
    xmp::avifRWData
end
function Base.getproperty(x::Ptr{avifImage}, f::Symbol)
    f === :width && return Ptr{UInt32}(x + 0)
    f === :height && return Ptr{UInt32}(x + 4)
    f === :depth && return Ptr{UInt32}(x + 8)
    f === :yuvFormat && return Ptr{avifPixelFormat}(x + 12)
    f === :yuvRange && return Ptr{avifRange}(x + 16)
    f === :yuvChromaSamplePosition && return Ptr{avifChromaSamplePosition}(x + 20)
    f === :yuvPlanes && return Ptr{NTuple{3, Ptr{UInt8}}}(x + 24)
    f === :yuvRowBytes && return Ptr{NTuple{3, UInt32}}(x + 48)
    f === :imageOwnsYUVPlanes && return Ptr{avifBool}(x + 60)
    f === :alphaPlane && return Ptr{Ptr{UInt8}}(x + 64)
    f === :alphaRowBytes && return Ptr{UInt32}(x + 72)
    f === :imageOwnsAlphaPlane && return Ptr{avifBool}(x + 76)
    f === :alphaPremultiplied && return Ptr{avifBool}(x + 80)
    f === :icc && return Ptr{avifRWData}(x + 88)
    f === :colorPrimaries && return Ptr{avifColorPrimaries}(x + 104)
    f === :transferCharacteristics && return Ptr{avifTransferCharacteristics}(x + 106)
    f === :matrixCoefficients && return Ptr{avifMatrixCoefficients}(x + 108)
    f === :clli && return Ptr{avifContentLightLevelInformationBox}(x + 110)
    f === :transformFlags && return Ptr{avifTransformFlags}(x + 116)
    f === :pasp && return Ptr{avifPixelAspectRatioBox}(x + 120)
    f === :clap && return Ptr{avifCleanApertureBox}(x + 128)
    f === :irot && return Ptr{avifImageRotation}(x + 160)
    f === :imir && return Ptr{avifImageMirror}(x + 161)
    f === :exif && return Ptr{avifRWData}(x + 168)
    f === :xmp && return Ptr{avifRWData}(x + 184)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{avifImage}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


function avifImageCreate(width, height, depth, yuvFormat)
    ccall((:avifImageCreate, libavif), Ptr{avifImage}, (UInt32, UInt32, UInt32, avifPixelFormat), width, height, depth, yuvFormat)
end

function avifImageCreateEmpty()
    ccall((:avifImageCreateEmpty, libavif), Ptr{avifImage}, ())
end

function avifImageCopy(dstImage, srcImage, planes)
    ccall((:avifImageCopy, libavif), avifResult, (Ptr{avifImage}, Ptr{avifImage}, avifPlanesFlags), dstImage, srcImage, planes)
end

function avifImageSetViewRect(dstImage, srcImage, rect)
    ccall((:avifImageSetViewRect, libavif), avifResult, (Ptr{avifImage}, Ptr{avifImage}, Ptr{avifCropRect}), dstImage, srcImage, rect)
end

function avifImageDestroy(image)
    ccall((:avifImageDestroy, libavif), Cvoid, (Ptr{avifImage},), image)
end

function avifImageSetProfileICC(image, icc, iccSize)
    ccall((:avifImageSetProfileICC, libavif), avifResult, (Ptr{avifImage}, Ptr{UInt8}, Csize_t), image, icc, iccSize)
end

function avifImageSetMetadataExif(image, exif, exifSize)
    ccall((:avifImageSetMetadataExif, libavif), avifResult, (Ptr{avifImage}, Ptr{UInt8}, Csize_t), image, exif, exifSize)
end

function avifImageSetMetadataXMP(image, xmp, xmpSize)
    ccall((:avifImageSetMetadataXMP, libavif), avifResult, (Ptr{avifImage}, Ptr{UInt8}, Csize_t), image, xmp, xmpSize)
end

function avifImageAllocatePlanes(image, planes)
    ccall((:avifImageAllocatePlanes, libavif), avifResult, (Ptr{avifImage}, avifPlanesFlags), image, planes)
end

function avifImageFreePlanes(image, planes)
    ccall((:avifImageFreePlanes, libavif), Cvoid, (Ptr{avifImage}, avifPlanesFlags), image, planes)
end

function avifImageStealPlanes(dstImage, srcImage, planes)
    ccall((:avifImageStealPlanes, libavif), Cvoid, (Ptr{avifImage}, Ptr{avifImage}, avifPlanesFlags), dstImage, srcImage, planes)
end

@cenum avifRGBFormat::UInt32 begin
    AVIF_RGB_FORMAT_RGB = 0
    AVIF_RGB_FORMAT_RGBA = 1
    AVIF_RGB_FORMAT_ARGB = 2
    AVIF_RGB_FORMAT_BGR = 3
    AVIF_RGB_FORMAT_BGRA = 4
    AVIF_RGB_FORMAT_ABGR = 5
    AVIF_RGB_FORMAT_RGB_565 = 6
    AVIF_RGB_FORMAT_COUNT = 7
end

function avifRGBFormatChannelCount(format)
    ccall((:avifRGBFormatChannelCount, libavif), UInt32, (avifRGBFormat,), format)
end

function avifRGBFormatHasAlpha(format)
    ccall((:avifRGBFormatHasAlpha, libavif), avifBool, (avifRGBFormat,), format)
end

@cenum avifChromaUpsampling::UInt32 begin
    AVIF_CHROMA_UPSAMPLING_AUTOMATIC = 0
    AVIF_CHROMA_UPSAMPLING_FASTEST = 1
    AVIF_CHROMA_UPSAMPLING_BEST_QUALITY = 2
    AVIF_CHROMA_UPSAMPLING_NEAREST = 3
    AVIF_CHROMA_UPSAMPLING_BILINEAR = 4
end

@cenum avifChromaDownsampling::UInt32 begin
    AVIF_CHROMA_DOWNSAMPLING_AUTOMATIC = 0
    AVIF_CHROMA_DOWNSAMPLING_FASTEST = 1
    AVIF_CHROMA_DOWNSAMPLING_BEST_QUALITY = 2
    AVIF_CHROMA_DOWNSAMPLING_AVERAGE = 3
    AVIF_CHROMA_DOWNSAMPLING_SHARP_YUV = 4
end

mutable struct avifRGBImage
    width::UInt32
    height::UInt32
    depth::UInt32
    format::avifRGBFormat
    chromaUpsampling::avifChromaUpsampling
    chromaDownsampling::avifChromaDownsampling
    avoidLibYUV::avifBool
    ignoreAlpha::avifBool
    alphaPremultiplied::avifBool
    isFloat::avifBool
    maxThreads::Cint
    pixels::Ptr{UInt8}
    rowBytes::UInt32
    avifRGBImage() = new()
end
function Base.getproperty(x::Ptr{avifRGBImage}, f::Symbol)
    f === :width && return Ptr{UInt32}(x + 0)
    f === :height && return Ptr{UInt32}(x + 4)
    f === :depth && return Ptr{UInt32}(x + 8)
    f === :format && return Ptr{avifRGBFormat}(x + 12)
    f === :chromaUpsampling && return Ptr{avifChromaUpsampling}(x + 16)
    f === :chromaDownsampling && return Ptr{avifChromaDownsampling}(x + 20)
    f === :avoidLibYUV && return Ptr{avifBool}(x + 24)
    f === :ignoreAlpha && return Ptr{avifBool}(x + 28)
    f === :alphaPremultiplied && return Ptr{avifBool}(x + 32)
    f === :isFloat && return Ptr{avifBool}(x + 36)
    f === :maxThreads && return Ptr{Cint}(x + 40)
    f === :pixels && return Ptr{Ptr{UInt8}}(x + 48)
    f === :rowBytes && return Ptr{UInt32}(x + 56)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{avifRGBImage}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


function avifRGBImageSetDefaults(rgb, image)
    ccall((:avifRGBImageSetDefaults, libavif), Cvoid, (Ptr{avifRGBImage}, Ptr{avifImage}), rgb, image)
end

function avifRGBImagePixelSize(rgb)
    ccall((:avifRGBImagePixelSize, libavif), UInt32, (Ptr{avifRGBImage},), rgb)
end

function avifRGBImageAllocatePixels(rgb)
    ccall((:avifRGBImageAllocatePixels, libavif), avifResult, (Ptr{avifRGBImage},), rgb)
end

function avifRGBImageFreePixels(rgb)
    ccall((:avifRGBImageFreePixels, libavif), Cvoid, (Ptr{avifRGBImage},), rgb)
end

function avifImageRGBToYUV(image, rgb)
    ccall((:avifImageRGBToYUV, libavif), avifResult, (Ptr{avifImage}, Ptr{avifRGBImage}), image, rgb)
end

function avifImageYUVToRGB(image, rgb)
    ccall((:avifImageYUVToRGB, libavif), avifResult, (Ptr{avifImage}, Ptr{avifRGBImage}), image, rgb)
end

function avifRGBImagePremultiplyAlpha(rgb)
    ccall((:avifRGBImagePremultiplyAlpha, libavif), avifResult, (Ptr{avifRGBImage},), rgb)
end

function avifRGBImageUnpremultiplyAlpha(rgb)
    ccall((:avifRGBImageUnpremultiplyAlpha, libavif), avifResult, (Ptr{avifRGBImage},), rgb)
end

function avifFullToLimitedY(depth, v)
    ccall((:avifFullToLimitedY, libavif), Cint, (UInt32, Cint), depth, v)
end

function avifFullToLimitedUV(depth, v)
    ccall((:avifFullToLimitedUV, libavif), Cint, (UInt32, Cint), depth, v)
end

function avifLimitedToFullY(depth, v)
    ccall((:avifLimitedToFullY, libavif), Cint, (UInt32, Cint), depth, v)
end

function avifLimitedToFullUV(depth, v)
    ccall((:avifLimitedToFullUV, libavif), Cint, (UInt32, Cint), depth, v)
end

@cenum avifCodecChoice::UInt32 begin
    AVIF_CODEC_CHOICE_AUTO = 0
    AVIF_CODEC_CHOICE_AOM = 1
    AVIF_CODEC_CHOICE_DAV1D = 2
    AVIF_CODEC_CHOICE_LIBGAV1 = 3
    AVIF_CODEC_CHOICE_RAV1E = 4
    AVIF_CODEC_CHOICE_SVT = 5
    AVIF_CODEC_CHOICE_AVM = 6
end

@cenum avifCodecFlag::UInt32 begin
    AVIF_CODEC_FLAG_CAN_DECODE = 1
    AVIF_CODEC_FLAG_CAN_ENCODE = 2
end

const avifCodecFlags = UInt32

function avifCodecName(choice, requiredFlags)
    ccall((:avifCodecName, libavif), Ptr{Cchar}, (avifCodecChoice, avifCodecFlags), choice, requiredFlags)
end

function avifCodecChoiceFromName(name)
    ccall((:avifCodecChoiceFromName, libavif), avifCodecChoice, (Ptr{Cchar},), name)
end

# typedef void ( * avifIODestroyFunc ) ( struct avifIO * io )
const avifIODestroyFunc = Ptr{Cvoid}

# typedef avifResult ( * avifIOReadFunc ) ( struct avifIO * io , uint32_t readFlags , uint64_t offset , size_t size , avifROData * out )
const avifIOReadFunc = Ptr{Cvoid}

# typedef avifResult ( * avifIOWriteFunc ) ( struct avifIO * io , uint32_t writeFlags , uint64_t offset , const uint8_t * data , size_t size )
const avifIOWriteFunc = Ptr{Cvoid}

struct avifIO
    destroy::avifIODestroyFunc
    read::avifIOReadFunc
    write::avifIOWriteFunc
    sizeHint::UInt64
    persistent::avifBool
    data::Ptr{Cvoid}
end

function avifIOCreateMemoryReader(data, size)
    ccall((:avifIOCreateMemoryReader, libavif), Ptr{avifIO}, (Ptr{UInt8}, Csize_t), data, size)
end

function avifIOCreateFileReader(filename)
    ccall((:avifIOCreateFileReader, libavif), Ptr{avifIO}, (Ptr{Cchar},), filename)
end

function avifIODestroy(io)
    ccall((:avifIODestroy, libavif), Cvoid, (Ptr{avifIO},), io)
end

@cenum avifStrictFlag::UInt32 begin
    AVIF_STRICT_DISABLED = 0
    AVIF_STRICT_PIXI_REQUIRED = 1
    AVIF_STRICT_CLAP_VALID = 2
    AVIF_STRICT_ALPHA_ISPE_REQUIRED = 4
    AVIF_STRICT_ENABLED = 7
end

const avifStrictFlags = UInt32

struct avifIOStats
    colorOBUSize::Csize_t
    alphaOBUSize::Csize_t
end

@cenum avifDecoderSource::UInt32 begin
    AVIF_DECODER_SOURCE_AUTO = 0
    AVIF_DECODER_SOURCE_PRIMARY_ITEM = 1
    AVIF_DECODER_SOURCE_TRACKS = 2
end

struct avifImageTiming
    timescale::UInt64
    pts::Cdouble
    ptsInTimescales::UInt64
    duration::Cdouble
    durationInTimescales::UInt64
end

@cenum avifProgressiveState::UInt32 begin
    AVIF_PROGRESSIVE_STATE_UNAVAILABLE = 0
    AVIF_PROGRESSIVE_STATE_AVAILABLE = 1
    AVIF_PROGRESSIVE_STATE_ACTIVE = 2
end

function avifProgressiveStateToString(progressiveState)
    ccall((:avifProgressiveStateToString, libavif), Ptr{Cchar}, (avifProgressiveState,), progressiveState)
end

const avifDecoderData = Cvoid

mutable struct avifDecoder
    codecChoice::avifCodecChoice
    maxThreads::Cint
    requestedSource::avifDecoderSource
    allowProgressive::avifBool
    allowIncremental::avifBool
    ignoreExif::avifBool
    ignoreXMP::avifBool
    imageSizeLimit::UInt32
    imageDimensionLimit::UInt32
    imageCountLimit::UInt32
    strictFlags::avifStrictFlags
    image::Ptr{avifImage}
    imageIndex::Cint
    imageCount::Cint
    progressiveState::avifProgressiveState
    imageTiming::avifImageTiming
    timescale::UInt64
    duration::Cdouble
    durationInTimescales::UInt64
    repetitionCount::Cint
    alphaPresent::avifBool
    ioStats::avifIOStats
    diag::avifDiagnostics
    io::Ptr{avifIO}
    data::Ptr{avifDecoderData}
    avifDecoder() = new()
end
function Base.getproperty(x::Ptr{avifDecoder}, f::Symbol)
    f === :codecChoice && return Ptr{avifCodecChoice}(x + 0)
    f === :maxThreads && return Ptr{Cint}(x + 4)
    f === :requestedSource && return Ptr{avifDecoderSource}(x + 8)
    f === :allowProgressive && return Ptr{avifBool}(x + 12)
    f === :allowIncremental && return Ptr{avifBool}(x + 16)
    f === :ignoreExif && return Ptr{avifBool}(x + 20)
    f === :ignoreXMP && return Ptr{avifBool}(x + 24)
    f === :imageSizeLimit && return Ptr{UInt32}(x + 28)
    f === :imageDimensionLimit && return Ptr{UInt32}(x + 32)
    f === :imageCountLimit && return Ptr{UInt32}(x + 36)
    f === :strictFlags && return Ptr{avifStrictFlags}(x + 40)
    f === :image && return Ptr{Ptr{avifImage}}(x + 48)
    f === :imageIndex && return Ptr{Cint}(x + 56)
    f === :imageCount && return Ptr{Cint}(x + 60)
    f === :progressiveState && return Ptr{avifProgressiveState}(x + 64)
    f === :imageTiming && return Ptr{avifImageTiming}(x + 72)
    f === :timescale && return Ptr{UInt64}(x + 112)
    f === :duration && return Ptr{Cdouble}(x + 120)
    f === :durationInTimescales && return Ptr{UInt64}(x + 128)
    f === :repetitionCount && return Ptr{Cint}(x + 136)
    f === :alphaPresent && return Ptr{avifBool}(x + 140)
    f === :ioStats && return Ptr{avifIOStats}(x + 144)
    f === :diag && return Ptr{avifDiagnostics}(x + 160)
    f === :io && return Ptr{Ptr{avifIO}}(x + 416)
    f === :data && return Ptr{Ptr{avifDecoderData}}(x + 424)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{avifDecoder}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


function avifDecoderCreate()
    ccall((:avifDecoderCreate, libavif), Ptr{avifDecoder}, ())
end

function avifDecoderDestroy(decoder)
    ccall((:avifDecoderDestroy, libavif), Cvoid, (Ptr{avifDecoder},), decoder)
end

function avifDecoderRead(decoder, image)
    ccall((:avifDecoderRead, libavif), avifResult, (Ptr{avifDecoder}, Ptr{avifImage}), decoder, image)
end

function avifDecoderReadMemory(decoder, image, data, size)
    ccall((:avifDecoderReadMemory, libavif), avifResult, (Ptr{avifDecoder}, Ptr{avifImage}, Ptr{UInt8}, Csize_t), decoder, image, data, size)
end

function avifDecoderReadFile(decoder, image, filename)
    ccall((:avifDecoderReadFile, libavif), avifResult, (Ptr{avifDecoder}, Ptr{avifImage}, Ptr{Cchar}), decoder, image, filename)
end

function avifDecoderSetSource(decoder, source)
    ccall((:avifDecoderSetSource, libavif), avifResult, (Ptr{avifDecoder}, avifDecoderSource), decoder, source)
end

function avifDecoderSetIO(decoder, io)
    ccall((:avifDecoderSetIO, libavif), Cvoid, (Ptr{avifDecoder}, Ptr{avifIO}), decoder, io)
end

function avifDecoderSetIOMemory(decoder, data, size)
    ccall((:avifDecoderSetIOMemory, libavif), avifResult, (Ptr{avifDecoder}, Ptr{UInt8}, Csize_t), decoder, data, size)
end

function avifDecoderSetIOFile(decoder, filename)
    ccall((:avifDecoderSetIOFile, libavif), avifResult, (Ptr{avifDecoder}, Ptr{Cchar}), decoder, filename)
end

function avifDecoderParse(decoder)
    ccall((:avifDecoderParse, libavif), avifResult, (Ptr{avifDecoder},), decoder)
end

function avifDecoderNextImage(decoder)
    ccall((:avifDecoderNextImage, libavif), avifResult, (Ptr{avifDecoder},), decoder)
end

function avifDecoderNthImage(decoder, frameIndex)
    ccall((:avifDecoderNthImage, libavif), avifResult, (Ptr{avifDecoder}, UInt32), decoder, frameIndex)
end

function avifDecoderReset(decoder)
    ccall((:avifDecoderReset, libavif), avifResult, (Ptr{avifDecoder},), decoder)
end

function avifDecoderIsKeyframe(decoder, frameIndex)
    ccall((:avifDecoderIsKeyframe, libavif), avifBool, (Ptr{avifDecoder}, UInt32), decoder, frameIndex)
end

function avifDecoderNearestKeyframe(decoder, frameIndex)
    ccall((:avifDecoderNearestKeyframe, libavif), UInt32, (Ptr{avifDecoder}, UInt32), decoder, frameIndex)
end

function avifDecoderNthImageTiming(decoder, frameIndex, outTiming)
    ccall((:avifDecoderNthImageTiming, libavif), avifResult, (Ptr{avifDecoder}, UInt32, Ptr{avifImageTiming}), decoder, frameIndex, outTiming)
end

function avifDecoderDecodedRowCount(decoder)
    ccall((:avifDecoderDecodedRowCount, libavif), UInt32, (Ptr{avifDecoder},), decoder)
end

struct avifExtent
    offset::UInt64
    size::Csize_t
end

function avifDecoderNthImageMaxExtent(decoder, frameIndex, outExtent)
    ccall((:avifDecoderNthImageMaxExtent, libavif), avifResult, (Ptr{avifDecoder}, UInt32, Ptr{avifExtent}), decoder, frameIndex, outExtent)
end

struct avifScalingMode
    horizontal::avifFraction
    vertical::avifFraction
end

const avifEncoderData = Cvoid

const avifCodecSpecificOptions = Cvoid

mutable struct avifEncoder
    codecChoice::avifCodecChoice
    maxThreads::Cint
    speed::Cint
    keyframeInterval::Cint
    timescale::UInt64
    repetitionCount::Cint
    extraLayerCount::UInt32
    quality::Cint
    qualityAlpha::Cint
    minQuantizer::Cint
    maxQuantizer::Cint
    minQuantizerAlpha::Cint
    maxQuantizerAlpha::Cint
    tileRowsLog2::Cint
    tileColsLog2::Cint
    autoTiling::avifBool
    scalingMode::avifScalingMode
    ioStats::avifIOStats
    diag::avifDiagnostics
    data::Ptr{avifEncoderData}
    csOptions::Ptr{avifCodecSpecificOptions}
    avifEncoder() = new()
end
function Base.getproperty(x::Ptr{avifEncoder}, f::Symbol)
    f === :codecChoice && return Ptr{avifCodecChoice}(x + 0)
    f === :maxThreads && return Ptr{Cint}(x + 4)
    f === :speed && return Ptr{Cint}(x + 8)
    f === :keyframeInterval && return Ptr{Cint}(x + 12)
    f === :timescale && return Ptr{UInt64}(x + 16)
    f === :repetitionCount && return Ptr{Cint}(x + 24)
    f === :extraLayerCount && return Ptr{UInt32}(x + 28)
    f === :quality && return Ptr{Cint}(x + 32)
    f === :qualityAlpha && return Ptr{Cint}(x + 36)
    f === :minQuantizer && return Ptr{Cint}(x + 40)
    f === :maxQuantizer && return Ptr{Cint}(x + 44)
    f === :minQuantizerAlpha && return Ptr{Cint}(x + 48)
    f === :maxQuantizerAlpha && return Ptr{Cint}(x + 52)
    f === :tileRowsLog2 && return Ptr{Cint}(x + 56)
    f === :tileColsLog2 && return Ptr{Cint}(x + 60)
    f === :autoTiling && return Ptr{avifBool}(x + 64)
    f === :scalingMode && return Ptr{avifScalingMode}(x + 68)
    f === :ioStats && return Ptr{avifIOStats}(x + 88)
    f === :diag && return Ptr{avifDiagnostics}(x + 104)
    f === :data && return Ptr{Ptr{avifEncoderData}}(x + 360)
    f === :csOptions && return Ptr{Ptr{avifCodecSpecificOptions}}(x + 368)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{avifEncoder}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


function avifEncoderCreate()
    ccall((:avifEncoderCreate, libavif), Ptr{avifEncoder}, ())
end

function avifEncoderWrite(encoder, image, output)
    ccall((:avifEncoderWrite, libavif), avifResult, (Ptr{avifEncoder}, Ptr{avifImage}, Ptr{avifRWData}), encoder, image, output)
end

function avifEncoderDestroy(encoder)
    ccall((:avifEncoderDestroy, libavif), Cvoid, (Ptr{avifEncoder},), encoder)
end

@cenum avifAddImageFlag::UInt32 begin
    AVIF_ADD_IMAGE_FLAG_NONE = 0
    AVIF_ADD_IMAGE_FLAG_FORCE_KEYFRAME = 1
    AVIF_ADD_IMAGE_FLAG_SINGLE = 2
end

const avifAddImageFlags = UInt32

function avifEncoderAddImage(encoder, image, durationInTimescales, addImageFlags)
    ccall((:avifEncoderAddImage, libavif), avifResult, (Ptr{avifEncoder}, Ptr{avifImage}, UInt64, avifAddImageFlags), encoder, image, durationInTimescales, addImageFlags)
end

function avifEncoderAddImageGrid(encoder, gridCols, gridRows, cellImages, addImageFlags)
    ccall((:avifEncoderAddImageGrid, libavif), avifResult, (Ptr{avifEncoder}, UInt32, UInt32, Ptr{Ptr{avifImage}}, avifAddImageFlags), encoder, gridCols, gridRows, cellImages, addImageFlags)
end

function avifEncoderFinish(encoder, output)
    ccall((:avifEncoderFinish, libavif), avifResult, (Ptr{avifEncoder}, Ptr{avifRWData}), encoder, output)
end

function avifEncoderSetCodecSpecificOption(encoder, key, value)
    ccall((:avifEncoderSetCodecSpecificOption, libavif), avifResult, (Ptr{avifEncoder}, Ptr{Cchar}, Ptr{Cchar}), encoder, key, value)
end

function avifImageUsesU16(image)
    ccall((:avifImageUsesU16, libavif), avifBool, (Ptr{avifImage},), image)
end

function avifImageIsOpaque(image)
    ccall((:avifImageIsOpaque, libavif), avifBool, (Ptr{avifImage},), image)
end

function avifImagePlane(image, channel)
    ccall((:avifImagePlane, libavif), Ptr{UInt8}, (Ptr{avifImage}, Cint), image, channel)
end

function avifImagePlaneRowBytes(image, channel)
    ccall((:avifImagePlaneRowBytes, libavif), UInt32, (Ptr{avifImage}, Cint), image, channel)
end

function avifImagePlaneWidth(image, channel)
    ccall((:avifImagePlaneWidth, libavif), UInt32, (Ptr{avifImage}, Cint), image, channel)
end

function avifImagePlaneHeight(image, channel)
    ccall((:avifImagePlaneHeight, libavif), UInt32, (Ptr{avifImage}, Cint), image, channel)
end

function avifPeekCompatibleFileType(input)
    ccall((:avifPeekCompatibleFileType, libavif), avifBool, (Ptr{avifROData},), input)
end

# Skipping MacroDefinition: AVIF_HELPER_EXPORT __attribute__ ( ( visibility ( "default" ) ) )

const AVIF_HELPER_IMPORT = nothing

const AVIF_API = nothing

const AVIF_VERSION_MAJOR = 1

const AVIF_VERSION_MINOR = 0

const AVIF_VERSION_PATCH = 4

const AVIF_VERSION_DEVEL = 0

const AVIF_VERSION = AVIF_VERSION_MAJOR * 1000000 + AVIF_VERSION_MINOR * 10000 + AVIF_VERSION_PATCH * 100 + AVIF_VERSION_DEVEL

const AVIF_TRUE = 1

const AVIF_FALSE = 0

const AVIF_DIAGNOSTICS_ERROR_BUFFER_SIZE = 256

const AVIF_DEFAULT_IMAGE_SIZE_LIMIT = 16384 * 16384

const AVIF_DEFAULT_IMAGE_DIMENSION_LIMIT = 32768

const AVIF_DEFAULT_IMAGE_COUNT_LIMIT = 12 * 3600 * 60

const AVIF_QUALITY_DEFAULT = -1

const AVIF_QUALITY_LOSSLESS = 100

const AVIF_QUALITY_WORST = 0

const AVIF_QUALITY_BEST = 100

const AVIF_QUANTIZER_LOSSLESS = 0

const AVIF_QUANTIZER_BEST_QUALITY = 0

const AVIF_QUANTIZER_WORST_QUALITY = 63

const AVIF_PLANE_COUNT_YUV = 3

const AVIF_SPEED_DEFAULT = -1

const AVIF_SPEED_SLOWEST = 0

const AVIF_SPEED_FASTEST = 10

const AVIF_REPETITION_COUNT_INFINITE = -1

const AVIF_REPETITION_COUNT_UNKNOWN = -2

const AVIF_MAX_AV1_LAYER_COUNT = 4

const AVIF_DATA_EMPTY = (C_NULL, 0)

# exports
const PREFIXES = ["Avif","AVIF","avif"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
