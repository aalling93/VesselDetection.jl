"""
    module OneStageDetector

The `OneStageDetector` module is an integral part of the vessel detection system, specializing in the deployment 
and utilization of one-stage models. These models are designed for efficient and effective detection of vessels 
in satellite imagery, providing rapid and accurate results.

## Components

- `utils.jl`: Contains a set of utility functions tailored to support the one-stage detection model. These utilities 
  might include preprocessing steps, data augmentation techniques, or specific methods for model optimization.

## Usage Examples

```julia
using VesselDetection
VesselDetection.Ship_detector.Model.OneStageDetector

# Load a pre-trained one-stage detection model


# Apply the model to satellite imagery for vessel detection


# Process and analyze the detection results


````
"""
module OneStageDetector

include("utils.jl")


end