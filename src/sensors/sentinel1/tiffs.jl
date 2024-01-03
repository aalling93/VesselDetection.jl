using Images, FileIO

"""
    load_band(path::String, bits::Int64=16)
Reads a Sentinel 1 tiff file.

This function reads a tiff file from the Sentinel 1 satellite and returns the data.

# Arguments
- `filename::String`: The path to the tiff file.

# Returns
- `data::Array{Float64, 2}`: The data read from the tiff file.

"""
function load_band(; path::String,bits::Int64=16)::Array{Float64, 2}
    max_value = 2^bits - 1;
    img = load(path);
    gray_img = Gray.(img)
    int_img = map(x -> round(Int64, x * max_value), gray_img)

    int_img = convert.(Float64, int_img) # int is actually more correct, but this is easier for computations (that often require float..)
    return int_img
end




#function load_band(; path::String)
#    img = Raster(path).data
#    return img
#end
