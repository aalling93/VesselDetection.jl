
import ONNXRunTime as OX


"""
    load_model(; model_path::String = "../src/ship_detector/model/yolov8_ship_k5_more_parms_nms.onnx")

Load an ONNX model for inference.

This function loads an ONNX model from a specified path, making it ready for performing inference.

# Keyword Arguments
- `model_path::String`: Path to the ONNX model file.

# Returns
- Loaded ONNX model.

# Example
```julia
model = load_model(model_path="path/to/model.onnx")
```
"""
function load_model(; model_path::String = "../src/ship_detector/model/yolov8_ship_k5_more_parms_nms.onnx")
    return OX.load_inference(model_path)
end





"""
    pad_image(A)

Pad an image array to ensure its dimensions are divisible by 32.

This function pads an image array along its height and width so that both are divisible by 32, 
a common requirement for many CNN-based models.

# Arguments
- `A`: The image array to be padded.

# Returns
- Padded image array.

# Example
```julia
padded_image = pad_image(image_array)
```
"""
function pad_image(A)
    # Determine the type of the input array
    T = eltype(A)

    # Size of the input array
    channels, height, width = size(A)

    # Initialize padded_A as A
    padded_A = A

    # Calculate padding for height if it's not divisible by 32
    if height % 32 != 0
        height_padding = 32 - (height % 32)
        height_pad = zeros(T, channels, height_padding, width)  # Correct dimensions for height padding
        padded_A = cat(padded_A, height_pad, dims=2)
    end

    # Update the height dimension after padding
    _, new_height, _ = size(padded_A)

    # Calculate padding for width if it's not divisible by 32
    if width % 32 != 0
        width_padding = 32 - (width % 32)
        width_pad = zeros(T, channels, new_height, width_padding)  # Correct dimensions for width padding
        padded_A = cat(padded_A, width_pad, dims=3)
    end

    return padded_A
end



"""
    extend_dims(A, which_dim)

Extend the dimensions of an array by adding a singleton dimension.

This function is useful for preparing image data for models that expect a batch dimension.

# Arguments
- `A`: The array to be reshaped.
- `which_dim`: The position where the singleton dimension is to be added.

# Returns
- Reshaped array with an additional singleton dimension.

# Example
```julia
extended_image = extend_dims(image_array, 1)
```
"""
function extend_dims(A, which_dim)
    s = [size(A)...]
    insert!(s, which_dim, 1)
    return reshape(A, s...)
end

# Main function to process the image and get results from the ONNX model
function process_image_for_onnx(model, input, confidence_threshold=0.05)
    # Pad the image if necessary
    original_dims = size(input) 
    input = pad_image(input)
 
    # Extend dimensions if the image does not have a batch dimension
    if size(input)[1] == 3
        input = extend_dims(input, 1)
    end

    # Prepare input for the ONNX model
    input_dict = Dict("images" => input)

    # Get results from the ONNX model
    res = model(input_dict)

    a, ix, prob, x, y, width, height = [], [], [], [], [], [], []

    for i in 1:size(res["output0"][1,1,:])[1]
        if res["output0"][1,5,i] > confidence_threshold
            # Extract bounding box coordinates
            bbox_x = round(Int64, res["output0"][1,1,i])
            bbox_y = round(Int64, res["output0"][1,2,i])
            bbox_width = round(Int64, res["output0"][1,3,i])
            bbox_height = round(Int64, res["output0"][1,4,i])

            # Check if the bounding box is within the original image dimensions
            if bbox_x + bbox_width <= original_dims[2] && bbox_y + bbox_height <= original_dims[3]
                push!(a, (i, [bbox_x, bbox_y, bbox_width, bbox_height], Float64(res["output0"][1,5,i])))
                push!(ix, i)
                push!(prob, Float64(res["output0"][1,5,i]))
                push!(x, bbox_x)   
                push!(y, bbox_y)   
                push!(width, bbox_width)   
                push!(height, bbox_height)
            end
        end
    end

    results = Dict(
        "index" => ix,
        "probability" => prob,
        "x" => x,
        "y" => y,
        "width" => width,
        "height" => height
    )

    return results
end


