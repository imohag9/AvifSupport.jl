module AvifSupport

using ImageCore
#using TOML



#const project_info = TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
const __AVIF_DEPTH = 8


include("Wrapper.jl")
using .Wrapper


include("encoding.jl")
include("decoding.jl")
include("avif_utils.jl")


end
