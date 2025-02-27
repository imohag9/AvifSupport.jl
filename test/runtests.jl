using AvifSupport
using Random
using Test

using ImageCore



Random.seed!(1122)
mat_rgb = rand(20, 15)
mat_rgb2 = rand(15, 15)


img_rgb1 = RGB.(mat_rgb)
const tmpdir = mktempdir()
tmp_avif_file = joinpath(tmpdir, "test_data1.avif")

@testset "AvifSupport.jl" begin
    @testset "setup" begin
        @test write_avif(tmp_avif_file, img_rgb1) > 0
    end


    @testset "basic" begin
        for CT in [Gray, BGR, RGBA, BGRA, ABGR, ARGB]
            img = CT.(img_rgb1)
            data = avif_decode(avif_encode(img))
            @test eltype(eltype(data)) <: Colorant
            @test size(data[1]) == size(img)

        end


    end

    @testset "encoding_options" begin

        img_rgb_diff_dim = RGB.(mat_rgb2)
        img_rgb2 = BGR.(mat_rgb)


        @test_throws ArgumentError("Invalid input !! A vector of Matrix{Colorant} is needed .") avif_encode([])

        @test_throws ArgumentError("Invalid value for quality !! quality is an integer between  0 and 100 ") avif_encode(img_rgb1, quality=500)


        @test_throws ArgumentError("Invalid mode for this input !!") avif_encode(img_rgb1, mode="seq")
        @test_throws ArgumentError("Invalid mode for this input !!") avif_encode(img_rgb1, mode="layered")

        @test_throws ArgumentError("Invalid mode for this input !!!") avif_encode([img_rgb1, img_rgb2], mode="one_frame")

        @test_throws ArgumentError("images need to have same dimensions !!") avif_encode([img_rgb1, img_rgb_diff_dim], mode="grid")
        @test_throws ArgumentError("images need to have same dimensions !!") avif_encode([img_rgb1, img_rgb_diff_dim], mode="layered")
        @test_throws ArgumentError("images need to have same dimensions !!") avif_encode([img_rgb1, img_rgb_diff_dim], mode="seq")
        @test_throws ArgumentError("Invalid gridCols , gridRows values for grid Encoding") avif_encode([img_rgb1, img_rgb2], mode="grid",grid_cols=3,grid_rows=2)
        @test_throws ArgumentError("Invalid value for timescale !! 1 ≤ timescale ≤ 240 ") avif_encode([img_rgb1, img_rgb2], mode="seq",grid_cols=3,grid_rows=2,timescale=500)






    end

    @testset "decoding_options" begin
        data = avif_decode(avif_encode(img_rgb1))
        @test size(data[1]) == size(img_rgb1)
        @test eltype(eltype(data)) <: Colorant
        @test isempty(avif_decode(tmp_avif_file,transpose=false)) == false
        @test isempty(avif_decode(tmp_avif_file, transpose=true)) == false
    end


    @testset "util_functions" begin

        @test is_valid_avif(tmp_avif_file) == true
        @test_nowarn version_info()

    end
end
