
"""
    is_valid_avif(file_path::AbstractString)
Returns False if file_path is not a valid avif/avis file .
"""
function is_valid_avif(file_path::AbstractString)::Bool

    file_buffer = read(file_path)
    buffer_data = avifROData()
    buffer_data.data = pointer(file_buffer)
    buffer_data.size = length(file_buffer)


    buffer_data_ref = Ref(buffer_data)
  
    return Bool(avifPeekCompatibleFileType(buffer_data_ref))
  end
  
export is_valid_avif

"""
    version_info(io=stdout)

Print information about the package the libavif in use.
"""
function version_info(io=stdout)
    #println(io, "Avif.jl version: ", project_info["version"])
    println(io, "libavif version: ", unsafe_string(avifVersion())) 
    

end

export version_info


