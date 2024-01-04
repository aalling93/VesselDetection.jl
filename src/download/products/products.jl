"""
    module Products

The `Products` module is specifically tailored for managing and processing satellite data products, with a 
primary focus on the Copernicus program. It provides a set of tools for retrieving, handling, and manipulating 
satellite products, ensuring efficient access and usage of satellite imagery and related data.

## Components

- `utils.jl`: A collection of utility functions that support the operations on satellite products. 
  These utilities include file management routines, data transformation functions, and other common tasks 
  that facilitate the handling of satellite data.

- `get_products_copernicus.jl`: Dedicated to retrieving and processing data products from the Copernicus 
  satellite program. It includes functionalities for querying Copernicus databases, downloading products, 
  and preparing them for analysis.

## Usage Examples

```julia
using VesselDetection
.... VesselDetection.Download.Products....

# Retrieve a list of Copernicus products based on specific criteria

# Download a specific product from the Copernicus program

# Apply utility functions to process or transform the downloaded product

````
Notes
This module is an integral part of a broader remote sensing data processing framework, designed to streamline
the workflow from data acquisition to analysis.
The current focus is on Copernicus data products, but the module is structured for easy extension to include
other satellite programs.

"""
module Products

include("utils.jl")
include("get_products_copernicus.jl")

end