using FileIO, Images, MLDataUtils
using Flux
using MLUtils: shuffleobs, splitobs
using JSON
using Random
using Flux: DataLoader

# Load and parse the JSON file
function load_json_data(json_file::String)
    try
        json_data = JSON.parsefile(json_file)
        return json_data
    catch e
        println("Error loading JSON file: ", e)
        return nothing
    end
end

function min_max_scale(data::AbstractArray{<:Real,3}; data_max::Real, data_min::Real, to_max::Real, to_min::Real)
    scaled_data = (data .- data_min) ./ (data_max - data_min) .* (to_max - to_min) .+ to_min
    return scaled_data
end

function min_max_scale(data::AbstractArray{<:Real,2}; data_max::Real, data_min::Real, to_max::Real, to_min::Real)
    scaled_data = (data .- data_min) ./ (data_max - data_min) .* (to_max - to_min) .+ to_min
    return scaled_data
end

function min_max_scale_adaptive(data::AbstractArray{<:Real,2}; to_max::Real, to_min::Real)
    scaled_data = (data .- minimum(data)) ./ (maxiumum(data) - minimum(data)) .* (to_max - to_min) .+ to_min
    return scaled_data
end



function normalize_bands(matrix::AbstractArray{<:Real,3})
    # matrix is assumed to have shape (75, 75, 2) or similar
    normalized = copy(matrix)  # Copying to avoid modifying the original array

    for i in 1:size(matrix, 3)  # Iterating over the third dimension (bands)
        band = matrix[:, :, i]
        min_val = minimum(band)
        max_val = maximum(band)

        # Normalizing the band
        normalized[:, :, i] .= (band .- min_val) ./ (max_val - min_val)
    end

    return normalized
end





function prepare_input(matrix::AbstractArray{<:Real,3})
    # scale so min max is 0 and 1 as in the training data (this is not smart, but just to show how it can be done)
    # normally, there is a global min and max for the whole dataset, but here we use the min and max of the image
    normalized = normalize_bands(matrix)
    # reshape to 4D array (batch, height, width, channels)    
    permuted_array = permutedims(scaled[1:2, :, :], [2, 3, 1])

    return reshaped_array
end





# Extract data from JSON and create dataset
function create_dataset(json_data)
    #images = Vector{Array{Float64,3}}()  # To store combined band_1 and band_2 data
    images = []
    labels = Vector{Int64}()             # To store labels (0 or 1 for iceberg or not)

    for entry in json_data
        band_1 = Float64.(entry["band_1"])
        band_2 = Float64.(entry["band_2"])
        is_iceberg = entry["is_iceberg"]
        # Reshape band_1 and band_2 into 75x75x1 arrays
        reshaped_band_1 = reshape(band_1, (75, 75, 1))
        reshaped_band_2 = reshape(band_2, (75, 75, 1))
        # Combine band_1 and band_2 into a 75x75x2 array
        combined_image = cat(reshaped_band_1, reshaped_band_2, dims=3)
        push!(images, Float32.(normalize_bands(combined_image)))
        push!(labels, is_iceberg)
    end


    return images, labels
end



# Shuffle and split the dataset
function shuffle_and_split_data(images, labels, train_ratio, val_ratio)
    data = shuffleobs(collect(zip(images, labels)))

    n = length(data)
    train_end = Int(round(train_ratio * n))
    val_end = train_end + Int(round(val_ratio * n))

    train_data = data[1:train_end]
    val_data = data[(train_end+1):val_end]
    test_data = data[(val_end+1):end]

    train_X = [x[1] for x in train_data]
    train_Y = [x[2] for x in train_data]

    val_X = [x[1] for x in val_data]
    val_Y = [x[2] for x in val_data]

    test_X = [x[1] for x in test_data]
    test_Y = [x[2] for x in test_data]

    return train_X, train_Y, val_X, val_Y, test_X, test_Y
end






