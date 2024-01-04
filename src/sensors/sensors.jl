
"""
    module Sensors

The `Sensors` module is designed for handling and processing data from different types of remote sensing sensors, with a particular focus on satellite sensors like Sentinel-1. It provides utilities for parsing sensor data, extracting relevant metadata, and preparing data for further analysis and processing.

## Components

- `types.jl`: Defines custom types and structures used to represent sensor data and metadata.
- `util.jl`: Contains utility functions for common operations such as data conversion, formatting, and extraction.
- `sentinel1/sentinel1.jl`: Dedicated sub-module for handling Sentinel-1 satellite data. It includes functionalities for reading Sentinel-1 specific file formats, interpreting satellite metadata, and preprocessing the raw data for various applications in remote sensing.
- can actually handle RCM data as well, but is dependant on pycall... 
## Dependencies

The module relies on the following external packages:
- `EzXML`: For parsing XML files, which are commonly used in sensor data formats.
- `XMLDict`: For converting XML data into Julia dictionaries.
- `Dates`: For handling date and time operations, essential for time-series sensor data analysis.

## Usage

```julia
using VesselDetection

# Example: Loading Sentinel-1 data
sentinel_data = VesselDetection.Sensors.Sentinel1.load_data("path/to/sentinel1/data")
# Processing and extracting information
...
```

Notes
This module is part of a larger suite for remote sensing data analysis and is optimized for handling specific sensor types.
Contributions and extensions to include additional sensor types are welcome.

"""
module Sensors



using EzXML
using XMLDict
using Dates


include("types.jl")
include("util.jl")
include("sentinel1/sentinel1.jl")




end