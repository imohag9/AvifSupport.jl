```@meta
CurrentModule = AvifSupport
```
# AvifSupport

[AvifSupport.jl](https://github.com/imohag9/AvifSupport.jl) is a Julia wrapper of the C library
[libavif](https://github.com/AOMediaCodec/libavif) that provides IO support for the
JPEG image format.


## About the Avif Format

AVIF (AV1 Image File Format) is an image format designed to offer superior image compression and quality compared to traditional formats. It delivers smaller file sizes without significant loss in quality, making it ideal for web applications, image storage, and streaming. Source : [AOMedia](https://aomedia.org/specifications/avif/)



## Add the package

```julia-repl
julia> # Press ]
pkg> activate
pkg> add https://github.com/imohag9/AvifSupport.jl
```


## General parameters for encoding and decoding  

`verbose` : when set to true , Additional information are printed .Default value is `false`.

`transpose` : Default `false`

## Encoding

#### "one-frame" Encoding

You can simply encode a 2D image as an Avif file .It' the default encoding mode for still images.
The `quality` paramater controls the quality of the resulting avif image. Its value is 10 by default.
This parameter is available for all encoding modes and inputs.


```julia-repl
julia> using AvifSupport
julia> using TestImages
julia> source_image = testimage("toucan.png")
julia> avif_result = avif_encode(source_image)
julia> @show typeof(rgb_result)
julia> avif_result2 = avif_encode(source_image,quality=100)
```
#### Grid encoding

It's also possible to encode to Avif images in grid mode

```julia-repl
julia> avif_result = avif_encode(source_image,mode="grid")
```

### Encoding Arrays of images

#### Grid encoding




```julia-repl
julia> using Avif
julia> using TestImages
julia> src_img1 = testimage("fabio_color_256.png")
julia> src_img2 = testimage("fabio_gray_512.png")
julia> avif_result = avif_encode([src_img1,src_img2],mode="grid",grid_cols=1,grid_rows=2)
julia> @show typeof(rgb_result)
```

#### Sequential encoding

Timescale for image sequences. If all frames are 1 timescale in length, this is equivalent to frames per second. (Default: 30)


```julia-repl
julia> using AvifSupport
julia> using TestImages
julia> src_img1 = testimage("fabio_color_256.png")
julia> src_img2 = testimage("fabio_gray_512.png") 
julia> avif_result_seq = avif_encode([src_img1,src_img2],mode="seq",timescale=60)
julia> @show typeof(avif_result_seq)
```

#### Layered encoding

Encode a layered AVIF. Each input is encoded as one layer and at most 4 layers can be encoded. 


```julia-repl
julia> using AvifSupport
julia> using TestImages
julia> src_img1 = testimage("fabio_color_256
.png")
julia> src_img2 = testimage("fabio_gray_512.
png")
julia> avif_result_seq = avif_encode([src_im
g1,src_img2],mode="layered",timescale=60)
julia> @show typeof(avif_result_seq)        
```


## Decoding Avif files




```julia-repl
julia> using AvifSupport
julia> using Downloads
julia> avif_image = download("https://github.com/AOMediaCodec/libavif/blob/main/tests/data/io/kodim03_yuv420_8bpc.avif")
julia> rgb_result = avif_decode(avif_image)
julia> @show typeof(rgb_result)
```
File kodim03_yuv420_8bpc.avif
License: released by the Eastman Kodak Company for unrestricted usage

