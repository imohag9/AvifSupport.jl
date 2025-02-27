# AvifSupport


[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://imohag9.github.io/AvifSupport.jl/dev/)
[![Build Status](https://github.com/imohag9/AvifSupportSupport.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/imohag9/AvifSupport.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/imohag9/Avif.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/imohag9/AvifSupport.jl)



AvifSupport.jl is a Julia wrapper of the C library [libavif](https://github.com/AOMediaCodec/libavif) that provides IO support for the AVIF image format.

## Usage









## Acknowledgements

The purpose of this project is to introduce the AVIF file format to the Julia ecosystem. This work was very inspired by [JpegTurbo.jl](https://github.com/JuliaIO/JpegTurbo.jl) and [WebP.jl](https://github.com/stemann/WebP.jl).

[Clang.jl] is used to generate the low-level ccall wrapper [libavif_jll.jl](https://github.com/JuliaBinaryWrappers/libavif_jll.jl) provided by Julia Binary Wrappers repository. 


[Clang.jl]: https://github.com/JuliaInterop/Clang.jl