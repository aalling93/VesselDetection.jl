"""
    module Binary_model

The `Binary_model` module is a specialized component of the vessel detection system, designed to handle binary 
classification tasks. It offers a comprehensive set of tools and functions to build, train, and evaluate binary 
classifiers, particularly for distinguishing between vessel and non-vessel objects in satellite imagery.

## Components

- `train_util.jl`: Provides utilities for training binary classifiers, including functions for batch processing, 
  optimization, and model updating.

- `model_util.jl`: Contains utility functions related to model management such as loading, saving, and modifying model 
  parameters.

- `loss.jl`: Dedicated to loss functions used in binary classification. These functions measure the discrepancy 
  between the predicted outputs and actual labels, guiding the training process.

## Usage Examples

```julia
using VesselDetection
VesselDetection.Ship_detector.Model.Binary_model

# Create and configure a binary classification model

# Train the model on a dataset

# Evaluate the model's performance

# Save the trained model for future use

````

"""
module Binary_model

include("train_util.jl")
include("model_util.jl")
include("loss.jl")

end