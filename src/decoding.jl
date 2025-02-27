"""
    avif_decode(filename::Union{AbstractString,IO}; kwargs...) -> Vector{Matrix{Colorant}}
    avif_decode(data::Vector{UInt8}; kwargs...) -> Vector{Matrix{Colorant}}

Decode the AVIF image as an array of colorant matrices. The source data can be either a filename, an IO
, or an in-memory byte sequence.The output is an array of matrices of type `Colorant`.

# parameters

- `transpose::Bool`: whether we need to permute the image's width and height dimension
  before encoding. The default value is `false`.

  !!! info "Custom Decoding parameters"
    LibAvif has a large number of decoder parameters that determine how the image is
    decoded. Most applications don't need or want to know about all these parameters. For
    more detailed information and explaination, please refer to the documents in [1]. 
    Unsupported custom parameters might cause Julia segmentation fault.

    
    The following are the default parameters used in this implementation for decoding :
    - codecChoice = libaom
    - maxThreads = Threads.nthreads()
    - speed = 4

# References

- [1] [libavif avifdec.c ](https://github.com/AOMediaCodec/libavif/blob/main/apps/avifdec.c)
"""
function avif_decode(data::Vector{UInt8};transpose::Bool=false)::Vector{Matrix{Colorant}}


  buffer_data = avifROData()
  buffer_data.data = pointer(data)
  buffer_data.size = length(data)
  !Bool(avifPeekCompatibleFileType(Ref(buffer_data))) && throw(ArgumentError("Invalid input !!"))
  decoder_ref = avifDecoderCreate()
  GC.@preserve decoder_ref decoderData = unsafe_load(decoder_ref)

  decoderData.maxThreads = Threads.nthreads()
  number_images = decoderData.imageCount
  avifDecoderSetIOMemory(decoder_ref, pointer(data), length(data))

  avifDecoderParse(decoder_ref)

  GC.@preserve decoder_ref decoderData = unsafe_load(decoder_ref)
  imagePtr = decoderData.image
  GC.@preserve imagePtr avifImg = unsafe_load(imagePtr)



  rawWidth = avifImg.width
  rawHeight = avifImg.height
  source_yuv = avifImg.yuvFormat
  dest_color = source_yuv == AVIF_PIXEL_FORMAT_YUV400 ? Gray{N0f8} : ARGB{N0f8}

  rgbImage = avifRGBImage()
  rgbImage_ref = Ref(rgbImage)
  rgbImage.width = rawWidth
  rgbImage.height = rawHeight
  rgbImage.depth = __AVIF_DEPTH
  rgbImage.maxThreads = Threads.nthreads()

  output = Array{Matrix{dest_color}}(undef, number_images)

  while (avifDecoderNextImage(decoder_ref) == avifResult(0))

    avifRGBImageSetDefaults(rgbImage_ref, imagePtr)
    avifRGBImageAllocatePixels(rgbImage_ref)
    avifImageYUVToRGB(imagePtr, rgbImage_ref)


    decoded_data_size = (sizeof(dest_color), Int(rgbImage.width), Int(rgbImage.height))
    decoded_data = unsafe_wrap(Array{UInt8,3}, rgbImage.pixels, decoded_data_size)
    image_view = colorview(dest_color, normedview(decoded_data))
    image = transpose ? image_view : PermutedDimsArray(image_view, (2, 1))

    push!(output, image)
  end



  avifRGBImageFreePixels(Ref(rgbImage))
  avifDecoderDestroy(decoder_ref)

  return output
end

function avif_decode(filename::Union{AbstractString,IO,IOStream};transpose::Bool=false,kwargs...)::Vector{Matrix{Colorant}}

    avif_decode(Base.read(filename),transpose=transpose,kwargs...)
end

avif_decode(io::IO;transpose::Bool=false, kwargs...) = avif_decode(read(io),transpose=transpose, kwargs...)
function avif_decode(filename::AbstractString;transpose::Bool=false, kwargs...)::Vector{Matrix{Colorant}}

  open(filename, "r") do io
    avif_decode(io,transpose=transpose, kwargs...)
  end
end
export avif_decode