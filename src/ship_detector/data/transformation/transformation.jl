"""
    module Transformation

The `Transformation` module is dedicated to performing various data transformations on remote sensing and satellite data. 
This module includes a range of functions and algorithms designed to preprocess, normalize, and modify data for 
further analysis or visualization.

## Sub-modules and Components

- `transforms.jl`: Contains a suite of transformation functions that can be applied to satellite imagery or remote sensing data. 
  These transformations might include normalization, filtering, enhancement, or conversion operations that are 
  essential in the data processing pipeline.

## Usage Examples

```julia
using VesselDetection
VesselDetection.Ship_detector.Transformation

# Apply a specific transformation to satellite data

# Example: Normalizing satellite image data


# Example: Applying a filtering transformation to enhance features

```
"""
module Transformation

include("transforms.jl")

end