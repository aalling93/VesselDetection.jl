"""
    module Model

The `Model` module in the vessel detection system encompasses a variety of functionalities for building, training, 
and evaluating models specific to satellite-based vessel detection. It includes tools for creating different types 
of models, computing performance metrics, and utilizing pre-trained models for analysis.

## Sub-modules and Components

- `metrics.jl`: Provides a comprehensive set of functions to calculate various performance metrics for the models. 
  These metrics include accuracy, precision, recall, F1-score, and others that are crucial for evaluating model performance.

- `utils.jl`: Contains utility functions that support the modeling process, such as data preprocessing, 
  normalization, and data augmentation techniques.

- `binary_model.jl`: Dedicated to building and managing binary classification models, which are pivotal in 
  distinguishing vessels from non-vessel objects in satellite imagery.

- `trained_model/Model.jl`: Deals with the utilization of pre-trained models, allowing for quick deployment and 
  fine-tuning of models on specific datasets.

## Usage Examples

```julia
using VesselDetection
VesselDetection.Ship_detector.Model


# Creating and training a binary classification model
binary_model = 
trained_model =

# Evaluating the model using various metrics
evaluation_metrics = 

# Using a pre-trained model for vessel detection
pretrained_model = 
predictions =

````

Notes
The module is integral to the vessel detection system, providing the necessary tools for building robust and
accurate models for satellite data analysis.
It is designed with extensibility in mind, allowing for future integration of additional model types
and advanced analytical techniques.

"""
module Model 

include("metrics.jl")
include("utils.jl")

include("classifyer/binary_model.jl")
include("trained_model/Model.jl")
end