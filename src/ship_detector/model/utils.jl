
"""
    prepare_images(images::Vector{Matrix{Float64}})

Prepare a batch of images for processing by reshaping and converting them.

This function takes a vector of images (each as a matrix of `Float64`) and processes each image by 
converting it to `Float32`, adding singleton dimensions for channels and batches. It then concatenates 
all processed images along the batch dimension, forming a 4-dimensional array.

# Arguments
- `images::Vector{Matrix{Float64}}`: A vector of images, each represented as a 2D matrix of `Float64`.

# Returns
- 4D `Array{Float32}`: An array of processed images, concatenated along the batch dimension.

# Example
```julia
prepared_images = prepare_images([rand(64, 64), rand(64, 64)])
```
"""
function prepare_images(images::Vector{Matrix{Float64}})
    # Convert to Float32 and add a singleton dimension for the channel and batch
    reshaped_images = [reshape(Float32.(image), size(image, 1), size(image, 2), 1, 1) for image in images]
    # Concatenate all images along the 4th dimension
    return cat(reshaped_images..., dims=4)
end

