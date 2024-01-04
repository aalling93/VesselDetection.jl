
"""
    module Ship_detector

A Julia module for detecting ships in satellite imagery using image processing and machine learning techniques.

The `Ship_detector` module provides functionalities for transforming, loading, and processing image data, 
applying various filters, performing Constant False Alarm Rate (CFAR) processing, and running machine 
learning models for ship detection.

## Components

- `transformation`: Functions for image transformation and preprocessing.
- `dataloader`: Utilities for loading and handling image data.
- `model`: Definitions and functionalities for machine learning models used in ship detection.
- `filters`: Image filtering techniques specific to ship detection in satellite imagery.
- `operations`: General utility functions and operations.
- `cfar`: Implementation of CFAR algorithms for object detection in images.

## Usage

The module can be used to process satellite images, apply necessary transformations and filters, 
and utilize trained models for detecting ships. It is designed to be modular, allowing users 
to leverage specific components as needed.

## Example

```julia
using VesselDetection

VesselDetection.Ship_detector

````

Notes
This module requires the Images Julia package for handling image data.

"""
module Ship_detector 


using Images 


include("data/transformation/transformation.jl")
include("data/dataloader.jl")

include("model/model.jl")

include("filters.jl")
include("operations.jl")
include("cfar/cfar.jl")

end