using Statistics
using HTTP
using Colors 
import Plots
using FileIO
import Makie
using Pkg, GLMakie
GLMakie.activate!(inline=true)

"""
    sar2gray(data::AbstractArray{T}; p_quantile=0.85) where {T<:Real}

Convert SAR (Synthetic Aperture Radar) data to a grayscale image.

The function maps the `data` to values between 0 and 1, with the minimum `data` value mapped to 0
and all values above the `p_quantile` threshold mapped to 1, thereby creating a grayscale image.

# Arguments
- `data::AbstractArray{T}`: Input SAR data array.
- `p_quantile=0.85`: Quantile threshold for mapping the maximum data value to 1.

# Returns
`Array{Gray{T}, 2}`: Grayscale image derived from SAR data.
"""
function sar2gray(data::AbstractArray{T}; p_quantile=0.85) where {T<:Real}
    @assert 0 <= p_quantile <= 1 "p_quantile must be between 0 and 1"

    min_value = minimum(reshape(data, :))
    factor = quantile(reshape(data, :), p_quantile) - min_value
    return Images.Gray.((data .- min_value) ./ factor)
end





"""
    plot_quicklook_from_url(data::Dict{String,Any}, index::Int)

Fetches and plots a quicklook image from a URL specified in the `data` dictionary at the given `index`.

The function extracts the image URL from the provided dictionary, fetches the image, and displays it.

# Arguments
- `data::Dict{String, Any}`: A dictionary containing image URLs.
- `index::Int`: Index to specify which image URL to use from the dictionary.

# Examples
data = Dict("features" => [...])
plot_quicklook_from_url(data, 1)
"""
function plot_quicklook_from_url(data::Dict{String,Any}, index::Int)
    @assert 1 <= index <= length(data["features"]) "Index out of bounds"
    # Extract the image URL from the data dictionary
    url = data["features"][index]["properties"]["thumbnail"]

    # Fetch and display the image
    response = HTTP.get(url)
    img = load(IOBuffer(response.body))
    Plots.plot(img, axis=false)
end





"""
    plot_combined_metrics(metrics_vector, metric_name)

Plots combined metrics for ships and icebergs based on a given metric.

The function plots metrics for ships and icebergs over varying thresholds to compare their performance.

# Arguments
- `metrics_vector`: Vector containing metric data for ships and icebergs.
- `metric_name`: Name of the metric to plot.

# Examples
plot_combined_metrics(metrics_vector, "accuracy")
"""
function plot_combined_metrics(metrics_vector, metric_name)
    # Initialize arrays to store metric values
    ships_metric = []
    icebergs_metric = []

    # Extract the metric values for ships and icebergs
    for metric in metrics_vector
        push!(ships_metric, getfield(metric.ships, metric_name))
        push!(icebergs_metric, getfield(metric.icebergs, metric_name))
    end

    # Extract thresholds for x-axis
    thresholds = [metric.threshold for metric in metrics_vector]

    # Create the plot
    plot(thresholds, ships_metric, label="Ships", title="Combined Metric Plot: " * string(metric_name), xlabel="Threshold", ylabel=string(metric_name))
    plot!(thresholds, icebergs_metric, label="Icebergs")
end







"""
    plot_image_with_boxes(; image_matrix, bbox_dict, confidence_threshold=0.5)

Plots an image with bounding boxes drawn around detected objects.

The function takes an image matrix and a dictionary containing bounding box coordinates and confidence scores,
drawing boxes around detected objects that exceed a specified confidence threshold.

# Arguments
- `image_matrix`: Matrix representing the image.
- `bbox_dict`: Dictionary containing bounding box coordinates and confidence scores.
- `confidence_threshold=0.5`: Threshold for displaying bounding boxes.

# Examples
plot_image_with_boxes(image_matrix=image, bbox_dict=bbox_data)
"""
function plot_image_with_boxes(; image_matrix, bbox_dict, confidence_threshold=0.5)
    @assert 0 <= confidence_threshold <= 1 "Confidence threshold must be between 0 and 1"
    @assert all(∈(keys(bbox_dict)), ["x", "y", "width", "height", "probability"]) "bbox_dict must contain keys: 'x', 'y', 'width', 'height', 'probability'"
    
    fig = Makie.Figure(resolution = (600, 400))
    ax = Makie.Axis(fig[1, 1], title = "Image with applied transforms")
    
    # Plot the image
    im = Makie.image!(ax, image_matrix, colormap = :greys)
    
    # Add a colorbar
    Makie.Colorbar(fig[1, 2], im, label = "Value", vertical = true)
    

    
    # Iterate through bounding boxes
    for i in 1:length(bbox_dict["x"])
        if bbox_dict["probability"][i] > confidence_threshold
            x_center = bbox_dict["x"][i]
            y_center = bbox_dict["y"][i]
            width = bbox_dict["width"][i]
            height = bbox_dict["height"][i]
    
            # Calculate the corners of the rectangle
            x_left = x_center - width / 2
            y_bottom = y_center - height / 2
    
            # Draw the rectangle
            Makie.lines!(ax,[y_bottom, y_bottom, y_bottom + height, y_bottom + height, y_bottom], [x_left, x_left + width, x_left + width, x_left, x_left],
                   color = :red)
    
            # Draw the class and confidence
            text_str = string("Ship: ", round(bbox_dict["probability"][i], digits=2))
            Makie.text!(ax,[y_bottom + height], [x_center],  text = text_str, color = :red, align = (:center, :bottom))
        end
    end
    
    display(fig)
    
end