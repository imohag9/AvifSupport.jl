__format_rgb_image(::Type{CT}) where {CT<:Gray} = AVIF_RGB_FORMAT_ARGB
__format_rgb_image(::Type{CT}) where {CT<:RGBA} = AVIF_RGB_FORMAT_RGBA
__format_rgb_image(::Type{CT}) where {CT<:BGRA} = AVIF_RGB_FORMAT_BGRA
__format_rgb_image(::Type{CT}) where {CT<:ABGR} = AVIF_RGB_FORMAT_ABGR
__format_rgb_image(::Type{CT}) where {CT<:ARGB} = AVIF_RGB_FORMAT_ARGB
__format_rgb_image(::Type{CT}) where {CT<:RGB} = AVIF_RGB_FORMAT_RGB
__format_rgb_image(::Type{CT}) where {CT<:BGR} = AVIF_RGB_FORMAT_BGR
__format_rgb_image(::Any) = AVIF_RGB_FORMAT_ARGB



function __rgb_image_utils(image::AbstractMatrix{TColor}, transpose::Bool) where {TColor<:Colorant}

    if !(TColor <: AbstractRGB || TColor <: AbstractGray)
        ARGB.(image)
    end
    (dest_color, yuv) = TColor <: Colorant ? (n0f8(alphacolor(base_color_type(eltype(image)))), AVIF_PIXEL_FORMAT_YUV444) : (Gray{N0f8}, AVIF_PIXEL_FORMAT_YUV400)
    dest_image_type = Array{dest_color,ndims(image)}
    data = transpose ? convert(dest_image_type, image) : convert(dest_image_type, PermutedDimsArray(image, (2, 1)))


    height, width = size(data)

    rawImage = reinterpret.(UInt8, channelview(data))
    rgb = avifRGBImage()
    rgb.width = width
    rgb.height = height
    rgb.depth = __AVIF_DEPTH
    rgb.format = __format_rgb_image(dest_color)
    rgb.maxThreads = Threads.nthreads()
    pixels = pointer(rawImage)

    return (rgb, pixels, yuv)


end



function __check_quality(quality::Integer)::Bool

    return 0 ≤ quality ≤ 100
end

function __check_dims(image::AbstractMatrix{<:Colorant}; rows=1, cols=1)::Bool
    height = size(image, 1) * rows
    width = size(image, 2) * cols
    dimension_limit = height < AVIF_DEFAULT_IMAGE_DIMENSION_LIMIT || width < AVIF_DEFAULT_IMAGE_DIMENSION_LIMIT
    size_limit = height * width < AVIF_DEFAULT_IMAGE_SIZE_LIMIT
    return dimension_limit && size_limit
    # Verify the math !!!!
end

function __same_size(arr::AbstractArray)::Bool

    return length(unique(size.(arr))) == 1
end


"""
    avif_encode(image::AbstractMatrix{TColor}) -> Vector{UInt8}
    avif_encode(image_arr::AbstractArray) -> Vector{UInt8}


Encode 2D image `img`or an array of 2D images `image_arr` as an AVIF byte sequence . The return value is a vector of bytes.

# Parameters for avif_encode(image::AbstractMatrix{TColor})

  - `transpose::Bool`: whether we need to permute the image's width and height dimension
  before encoding. The default value is `false`.
- `quality::Int`: The quality value is between 0..100 . The
  default value is `10`.
  - `transpose::Bool`: whether we need to permute the image's width and height dimension
  before encoding. The default value is `false`.
- `mode::String`: Determines the type of encoding of the input image .For 2D images , 
  the encoding mode is one of two values : "one_frame" which is the default and "grid".

  # Parameters for avif_encode(image_arr::AbstractArray)

  - `transpose::Bool`: whether we need to permute the image's width and height dimension
  before encoding. The default value is `false`.
  - `quality::Int`: The quality value is between 0..100 . The
  default value is `10`.
  - `mode::String`: Determines the type of encoding of the input .For arrays of 2D images , 
  the encoding mode is one of three values : `"seq"` (for sequential) which is the default , `"grid"` or `"layered"` .
  - `grid_cols::Int`: - ONLY RELEVANT TO GRID ENCODING - Determines the number of columns of the resulting image .
  The grid_cols value depends on the length of the input vector. 
  The default value is `1`.
  - `grid_rows::Int`: - ONLY RELEVANT TO GRID ENCODING - Determines the number of rows of the resulting image .
  The grid_rows value depends on the length of the input vector. The default value is `1`.
  - `timescale::Int`: - ONLY RELEVANT TO LAYERED ENCODING - 
  default value is `1`.

!!! info "Custom Encoding parameters"
    LibAvif has a large number of encoder parameters that determine how the image is
    encoded. Most applications don't need or want to know about all these parameters. For
    more detailed information and explaination, please refer to the document [1]. 
    Unsupported custom parameters might cause Julia segmentation fault.
    
    
    The following are the default parameters used in this implementation for decoding :
    - codecChoice = libaom
    - maxThreads = Threads.nthreads()
    - speed = 4
!!! danger "For Grid Encoding"
        grid_cols * grid_rows = length(image_arr)

# References

- [1] [libavif avifenc.c ](https://github.com/AOMediaCodec/libavif/blob/main/apps/avifenc.c)
"""
function avif_encode(image::AbstractMatrix{TColor};quality=10,verbose=false,transpose=false,mode="one_frame",kwargs...)::Vector{UInt8} where TColor <: Colorant

    if prod(size(image)) == 0
        throw(ArgumentError("Empty image is not allowed !!"))
    end

    !(__check_quality(quality)) && throw(ArgumentError("Invalid value for quality !! quality is an integer between  0 and 100 ")) 



    !(mode in ["one_frame","grid"]) && throw(ArgumentError("Invalid mode for this input !!")) 
    
    !__check_dims(image) && throw(ArgumentError("Invalid dimensions for the image input  !! Maximum dimension = 32768, Maximum size in pixels =  $(16384 * 16384)")) 
    
    (rgb,pixels,yuv) = __rgb_image_utils(image,transpose)

    ptrRgb = pointer_from_objref(rgb)


    avifImage = avifImageCreate(rgb.height,rgb.width,__AVIF_DEPTH, yuv)


    GC.@preserve avifImage avifPtrContent = unsafe_load(avifImage)

    avifRGBImageSetDefaults(ptrRgb, avifImage)

    avifRGBImageAllocatePixels(ptrRgb)

    rgb.pixels = pixels
    encoder = avifEncoderCreate()
    GC.@preserve encoder encoderData = unsafe_load(encoder)
    encoderData.quality = quality
    avifOutput = avifRWData(C_NULL,0)

    ptrOutput = Ref(avifOutput)


    avifImageRGBToYUV(avifImage, ptrRgb)

    if mode == "grid"
        verbose && @info "Beginning the grid encoding ..."
        avifEncoderAddImageGrid(encoder, 1,1, Ref(avifImage),AVIF_ADD_IMAGE_FLAG_SINGLE)
    else
        verbose && @info "Beginning the still encoding ..."
        avifEncoderAddImage(encoder,avifImage , 1, AVIF_ADD_IMAGE_FLAG_SINGLE)

    end

    avifEncoderFinish(encoder, ptrOutput)
    verbose && @info "Finishing the encoding ..."
    output_view = unsafe_wrap(Vector{UInt8}, avifOutput.data, avifOutput.size)
    output = collect(output_view)

    avifEncoderDestroy(encoder)
    avifRWDataFree(ptrOutput)
    return output

end

function avif_encode(image_arr::TVector;quality=10,verbose=false,transpose=false,mode="seq",grid_cols=1,grid_rows=1,timescale=1)::Vector{UInt8} where {TVector <: AbstractVector}

    !(__check_quality(quality)) && throw(ArgumentError("Invalid value for quality !! quality is an integer between  0 and 100 ")) 
    !(1 ≤ timescale ≤ 240) && throw(ArgumentError("Invalid value for timescale !! 1 ≤ timescale ≤ 240 ")) 

    !(eltype(image_arr) <: AbstractMatrix{<: Colorant}) && throw(ArgumentError("Invalid input !! A vector of Matrix{Colorant} is needed ."))

    length(unique(size.(image_arr))) != 1 && throw(ArgumentError("images need to have same dimensions !!"))

    !(mode in ["seq","grid","layered"]) && throw(ArgumentError("Invalid mode for this input !!!"))
    valid_dims = __check_dims(image_arr[1])
    if mode == "grid"
        grid_cols * grid_rows != length(image_arr) && throw(ArgumentError("Invalid gridCols , gridRows values for grid Encoding"))
        valid_dims = __check_dims(image_arr[1],rows=grid_rows,cols=grid_cols)
    end
    if mode == "layered"
        length(image_arr) > 4 && throw(ArgumentError("Invalid number of images . In layered Mode ,Maximum number of images is  4"))
    end
    !valid_dims && throw(ArgumentError("Invalid dimensions for the image input  !! Maximum dimension = 32768, Maximum size in pixels =  $(16384 * 16384)")) 

    avif_arr = Array{Ptr{avifImage}}(undef,length(image_arr))

    for i in eachindex(image_arr)
        frame = image_arr[i]
        (rgb,pixels,yuv) = __rgb_image_utils(frame,transpose)

        ptrRgb = pointer_from_objref(rgb)


        avifImg = avifImageCreate(rgb.height,rgb.width,__AVIF_DEPTH, yuv)

        avifRGBImageSetDefaults(ptrRgb, avifImg)

        avifRGBImageAllocatePixels(ptrRgb)

        rgb.pixels = pixels
        avifImageRGBToYUV(avifImg, ptrRgb)
        
        avif_arr[i] = avifImg        
    end
    encoder = avifEncoderCreate()
    GC.@preserve encoder encoderData = unsafe_load(encoder)
    encoderData.quality = quality

    
    avifOutput = avifRWData(C_NULL,0)

    ptrOutput = Ref(avifOutput)
    verbose && @info "Beginning the $(mode) encoding ..."

    if mode == "grid"
        # grid Encoding Logic

        avifEncoderAddImageGrid(encoder,grid_rows,grid_cols, avif_arr,AVIF_ADD_IMAGE_FLAG_SINGLE)
        
    elseif mode == "seq"
        # Layered Encoding Logic

        encoderData.timescale = timescale
        encoderData.repetitionCount = -1
        for i in eachindex(avif_arr)
            verbose && @info "Encoding Frame $i/$(length(avif_arr)).."
            avifEncoderAddImage(encoder, avif_arr[i], 1, AVIF_ADD_IMAGE_FLAG_NONE)
        end
    else
        # Layered Encoding Logic
    encoderData.extraLayerCount = length(image_arr) -1

    for i in eachindex(avif_arr)
        verbose && @info "Encoding Layer $i/$(length(image_arr)).."
        i==1 ? avifEncoderAddImage(encoder, avif_arr[i], 1, AVIF_ADD_IMAGE_FLAG_FORCE_KEYFRAME) : avifEncoderAddImage(encoder,  avif_arr[i], 1, AVIF_ADD_IMAGE_FLAG_NONE)
    end     

    end

    avifEncoderFinish(encoder, ptrOutput)
    verbose && @info "Finishing the encoding ..."
    output_view = unsafe_wrap(Vector{UInt8}, avifOutput.data, avifOutput.size)
    output = collect(output_view)

    avifEncoderDestroy(encoder)
    avifRWDataFree(ptrOutput)
    return output
end
export avif_encode







"""
    write_avif(dest_file::AbstractString, image::AbstractMatrix{<:Colorant}; kwargs...) -> Integer
    write_avif(dest_file::AbstractString, image_arr::TVector; kwargs...) -> Integer

Utility function that encodes a matrix of `Colorant` or an array of matrices of `Colorant` into a `dest_file` Avif image.
"""
function write_avif(dest_file::AbstractString, image::AbstractMatrix{<:Colorant}; quality=10, verbose=false, transpose=false, mode="one_frame", kwargs...)


    output = avif_encode(image, quality=quality, verbose=verbose, transpose=transpose, mode=mode)
    write(dest_file,output)
    verbose && @info "$dest_file Written with Success !!"

    return length(output)
end

function write_avif(dest_file::AbstractString, image_arr::TVector; quality=10, verbose=false, transpose=false, mode="seq", grid_cols=1, grid_rows=1, timescale=1, kwargs...) where {TVector<:AbstractVector}
    output = avif_encode(image_arr, quality=quality, verbose=verbose, transpose=transpose, mode=mode, grid_cols=grid_cols, grid_rows=grid_rows, timescale=timescale)
    write(dest_file, output)
    verbose && @info "$dest_file Written with Success !!"
    return length(output)
end


export write_avif