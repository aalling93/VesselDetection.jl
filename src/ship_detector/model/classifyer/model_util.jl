using Flux 
using BSON 
using Logging 


"""
    create_model(; input_channels=1, img_size=(75, 75), filter_sizes=[3, 3, 3], 
                  num_filters=[64, 128, 256], use_maxpool=[true, true, true], 
                  use_dropout=[0.0, 0.0, 0.1], dense_layers=[128], final_dense_units=1)

Create a customizable convolutional neural network (CNN) model.

This function constructs a CNN with specified parameters including the number of convolutional layers, 
filter sizes, dropout rates, and dense layers. It's suitable for a wide range of image processing tasks.

# Keyword Arguments
- `input_channels::Int`: Number of channels in input images.
- `img_size::Tuple{Int,Int}`: Size of the input images.
- `filter_sizes::Vector{Int}`: Sizes of the convolutional filters.
- `num_filters::Vector{Int}`: Number of filters in each convolutional layer.
- `use_maxpool::Vector{Bool}`: Whether to use max pooling after each convolutional layer.
- `use_dropout::Vector{Float64}`: Dropout rates for each convolutional layer.
- `dense_layers::Vector{Int}`: Number of units in each dense layer.
- `final_dense_units::Int`: Number of units in the final dense layer.

# Returns
- `Chain`: A Flux Chain object representing the constructed CNN model.

# Example
```julia
model = create_model(input_channels=1, img_size=(75, 75), filter_sizes=[3, 3, 3])
```
"""
function create_model(; 
        input_channels=1,  # Number of channels in input images
        img_size=(75, 75), 
        filter_sizes=[3, 3, 3], 
        num_filters=[64, 128, 256], 
        use_maxpool=[true, true, true], 
        use_dropout=[0.0, 0.0, 0.1], 
        dense_layers=[128], 
        final_dense_units=1
    )
    layers = []

    # Initial image dimensions
    current_dim = img_size

    # Add convolutional layers with optional pooling and dropout
    for i in 1:length(filter_sizes)
        # Determine the number of input channels for the Conv layer
        in_channels = i == 1 ? input_channels : num_filters[i-1]

        # Add Conv layer
        push!(layers, Conv((filter_sizes[i], filter_sizes[i]), in_channels => num_filters[i], relu))
        
        # Size reduction due to convolution
        current_dim = current_dim .- (filter_sizes[i] - 1)

        # Add MaxPool layer if specified
        if use_maxpool[i]
            push!(layers, MaxPool((2,2)))
            current_dim = div.(current_dim, 2)
        end

        # Add Dropout layer if specified
        if use_dropout[i]>0.0
            push!(layers, Dropout(use_dropout[i]))
        end
    end

    # Calculate flattened size
    flattened_size = prod(current_dim) * num_filters[end]

    # Add flatten layer
    push!(layers, Flux.flatten)

    # Add additional dense layers
    for dense_units in dense_layers
        push!(layers, Dense(flattened_size, dense_units, relu))
        flattened_size = dense_units  # Update for the next layer
    end

    # Add final dense layer
    push!(layers, Dense(flattened_size, final_dense_units))
    push!(layers, sigmoid)

    return Chain(layers...)
end








"""
    create_model_simple(; img_size=(75, 75), filter_size=3, num_filters=16, dense_units=128)

Create a simplified convolutional neural network (CNN) model.

This function constructs a basic CNN with two convolutional layers, followed by max pooling, flattening, 
and dense layers. It's useful for quick experiments or baseline model creation.

# Keyword Arguments
- `img_size::Tuple{Int,Int}`: Size of the input images.
- `filter_size::Int`: Size of the convolutional filters.
- `num_filters::Int`: Number of filters in each convolutional layer.
- `dense_units::Int`: Number of units in the dense layer.

# Returns
- `Chain`: A Flux Chain object representing the CNN model.

# Example
```julia
simple_model = create_model_simple(img_size=(75, 75), filter_size=3, num_filters=16)
```
"""
function create_model_simple(; img_size=(75, 75), filter_size=3, num_filters=16, dense_units=128)
    # Calculate the size after first Conv and MaxPool
    conv1_size = div.(img_size .- (filter_size - 1), 2)
    
    # Calculate the size after second Conv and MaxPool
    conv2_size = div.(conv1_size .- (filter_size - 1), 2)

    # Number of features after flattening
    flattened_size = prod(conv2_size) * 2 * num_filters  # 2 * num_filters is the number of output channels

    return Chain(
        Flux.Conv((filter_size, filter_size), 1 => num_filters, relu),
        MaxPool((2,2)),
        Flux.Conv((filter_size, filter_size), num_filters => 2 * num_filters, relu),
        MaxPool((2,2)),
        Flux.flatten,
        Dense(flattened_size, dense_units, relu),
        Dense(dense_units, 1),
        sigmoid
    )
end



"""
    load_model(model_path::String)

Load a neural network model from a file.

This function reads a model stored in BSON format from the given file path. Note that BSON format may not 
be compatible with certain Julia versions (e.g., Julia 1.8).

# Arguments
- `model_path::String`: Path to the BSON file containing the model.

# Returns
- Loaded model.

# Example
```julia
model = load_model("path/to/model.bson")
```
"""
function load_model(model_path::String)
    if occursin("bson", "model.bson")
        @warn "bson model detected. Bson does not work for Julia 1.8."
    end


    BSON.@load "$(model_path)" model

    return model 
end


"""
    classify(; input, model, threshold::Float64=0.25)

Classifies the input as ship or no using the given model and threshold.

This is mainly for JuliaEO2024, and assumes that the model was trained on C-CORE data.
The model retusn a ship=True is the probability is lower than the threshold. 

# Arguments
- `input`: The input data to be classified.
- `model`: The model used for classification.
- `threshold`: The threshold value for classifying the input. Default is 0.25.

# Returns
A dictionary with the classification result and the probability.
- `ship::Bool`: Whether the input is classified as ship or not.
- `probability::Float64`: The probability of the input not being a ship.

# Example
```julia
...
```
"""
function classify(; input,model,threshold::Float64=0.25)
    if model(input)[1].<threshold
        return Dict("ship"=>true, "probability"=>model(input)[1])
    else
        return Dict("ship"=>false, "probability"=>model(input)[1])
    end
end
