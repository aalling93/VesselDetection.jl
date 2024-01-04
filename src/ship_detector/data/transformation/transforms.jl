using Statistics
using Images




# Define the TransformCompose structure
struct TransformCompose
    transforms::Vector{Function}
    name::String

    TransformCompose(transforms::Vector{Function}) = new(transforms, "")
end

# Method to apply transformations to Vector{Matrix{Float64}}
function (tc::TransformCompose)(data::Vector{Matrix{Float64}})
    for t in tc.transforms
        data = t(data)
    end
    return data
end

# Transformation functions with multiple dispatch

# Min-Max Scale for Matrix
function min_max_scale(x::Vector{Matrix{Float64}}; data_max=1.0, data_min=0.0, to_max=1.0, to_min=0.0)
    [(to_max - to_min) * ((band .- data_min) ./ (data_max - data_min)) .+ to_min for band in x]
end



# Clip to Valid Range for Matrix
function clip_to_valid_range(x::Vector{Matrix{Float64}}; amin=0.0, amax=1.0)
    [clamp.(band, amin, amax) for band in x]
end

# Absolute for Matrix
function absolute(x::Vector{Matrix{Float64}})
    [abs.(band) for band in x]
end

# Two to Three Channel for Vector of Bands
function to_channels(x::Vector{Matrix{Float64}}, bands=[1, 2, 2])
    if length(bands) == 2
        band1 = bands[1] > 0 && bands[1] ≤ length(x) ? x[bands[1]] : zeros(size(x[1]))
        band2 = bands[2] > 0 && bands[2] ≤ length(x) ? x[bands[2]] : zeros(size(x[1]))
        temp = cat(band1, band2, dims=3)
        return permutedims(temp, [3, 1, 2])  
    elseif length(bands) == 3
        band1 = bands[1] > 0 && bands[1] ≤ length(x) ? x[bands[1]] : zeros(size(x[1]))
        band2 = bands[2] > 0 && bands[2] ≤ length(x) ? x[bands[2]] : zeros(size(x[1]))
        band3 = bands[3] > 0 && bands[3] ≤ length(x) ? x[bands[3]] : zeros(size(x[1]))
        temp = cat(band1, band2, band3, dims=3)
        return permutedims(temp, [3, 1, 2])
    else
        throw(ArgumentError("Input must have at least 2 bands."))
    end

end


# Two to Three Channel for Vector of Bands
function to_two_channel(x::Vector{Matrix{Float64}}, bands=[1, 2])
    # Ensure the bands vector has at least 3 elements
    if length(x) == 2
        band1 = bands[1] > 0 && bands[1] ≤ length(x) ? x[bands[1]] : zeros(size(x[1]))
        band2 = bands[2] > 0 && bands[2] ≤ length(x) ? x[bands[2]] : zeros(size(x[1]))
        temp = cat(band1, band2, dims=3)
        return permutedims(temp, [3, 1, 2])
    else
        throw(ArgumentError("Input must have 2 bands."))
    end
end


# Convert to Float32 for 3D Arrays
function to_float32(x::Array{Float64, 3})
    return Float32.(x)
end



"""
This is very wrong, since each pixel has a different calibration constant and noise constant.
These should be interpolated from the LUT. However, since I am only using this for the two-stage ship detector example, I am implementing it like this for now.
"""
function to_linear(x::Vector{Matrix{Float64}}, calibration_constant::Float64 = 474.0000, noise_constant::Float64 = 5.0000 )
    [ (band.^2  .- noise_constant)/ (calibration_constant.^2) for band in x]
end


# Convert to Decibels for Matrix
function to_db(x::Vector{Matrix{Float64}})
    [10 .* log10.(abs.(band) .+ 1e-16) for band in x]
end


# Define example transformation compose
s1_iw_vv = TransformCompose([
    absolute,
    x -> clip_to_valid_range(x, amin=1, amax=65535),
    to_db,
    x -> min_max_scale(x, data_max=48.17, data_min=0, to_max=1, to_min=0),
    x -> two_to_three_channel(x, [1, 2, 2]),
    to_float32,
])
