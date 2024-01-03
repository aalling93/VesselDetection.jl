


"""
    image_statistics(img_data::AbstractArray{<:Number})

Calculate and return various statistics of the given image data.

This function computes the mean, standard deviation, minimum, maximum, median,
and specific percentiles (25th and 75th) of the image data.

# Arguments
- `img_data::AbstractArray{<:Number}`: Image data as a numerical array.

# Returns
`Dict{String, Float64}`: Dictionary containing various statistics of the image.

# Examples
```julia
img = load("path/to/image.png")
stats = image_statistics(img)
```
"""
function image_statistics(img_data)
    # Calculate various statistics
    mean_value = mean(img_data)
    std_deviation = std(img_data)
    min_value = minimum(img_data)
    max_value = maximum(img_data)
    median_value = median(img_data)

    # Calculate specific percentiles (e.g., 25th and 75th percentiles)
    percentile25 = quantile(reshape(img_data,:), 0.25)
    percentile75 = quantile(reshape(img_data,:), 0.75)


    # Store the statistics in a dictionary
    statistics_dict = Dict(
        "Mean" => mean_value,
        "Standard Deviation" => std_deviation,
        "Minimum" => min_value,
        "Maximum" => max_value,
        "Median" => median_value,
        "25th Percentile" => percentile25,
        "75th Percentile" => percentile75,
    )

    return statistics_dict
end