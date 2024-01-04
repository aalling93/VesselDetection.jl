"""
    module Metadata

The `Metadata` module is designed for managing and processing metadata associated with remote sensing data, 
particularly from Copernicus and RCM (Radar Constellation Mission) sources. It includes functionalities for 
fetching metadata, performing utility operations, and visualizing the metadata for better understanding and analysis.

## Components

- `get_metadata_copernicus.jl`: Provides functions to fetch and process metadata from Copernicus satellite data. 
  It handles the specifics of Copernicus data formats and structures, allowing users to extract meaningful information efficiently.

- `util.jl`: Contains utility functions that support metadata processing. These may include format conversions, 
  data extraction tools, and common processing routines used across different satellite data sources.

- `visualise.jl`: Offers visualization tools for metadata. This is particularly useful for understanding the spatial 
  and temporal aspects of the satellite data, helping in tasks like coverage analysis and time-series studies.

- `get_metadata_rcm.jl`: Similar to its Copernicus counterpart, this file focuses on fetching and processing metadata 
  from RCM satellite data. It caters to the unique format and content of RCM data.

## Usage Examples

```julia
using VesselDetection

VesselDetection.Download.Metadata

# Fetch and process metadata from Copernicus

# Visualize Copernicus metadata


# Fetch and process metadata from RCM


# Utility function usage

````

Notes
This module is part of a broader suite focused on satellite data analysis, with specific emphasis on metadata management.
While the module currently supports Copernicus and RCM data, extensions to include other satellite data sources are envisioned.

"""
module Metadata


include("get_metadata_copernicus.jl")
include("util.jl")
include("visualise.jl")
include("get_metadata_rcm.jl")

end  