
        
"""
    download_metadata_rcm(; area, start_datetime::String, end_datetime::String, 
                           max_records::Int64, collection::String, polarization::Array{String}, 
                           product_type::Array{String}, bean_mode::String, 
                           spatial_resolution::String, username::String, password::String, 
                           verbose::Int)::Dict

Query and download metadata for RCM (Radar Constellation Mission) products.

This function interfaces with the EODMS (Earth Observation Data Management System) RAPI (Remote API) 
to search and download metadata for RCM products based on specified parameters such as area, time range, 
and product characteristics.

# Arguments
- `area`: Area for the query.
- `start_datetime::String`: Start datetime of the query.
- `end_datetime::String`: End datetime of the query.
- `max_records::Int64`: Maximum number of records to retrieve.
- `collection::String`: Data collection to query, typically "RCM".
- `polarization::Array{String}`: Array of polarization types to include in the query.
- `product_type::Array{String}`: Array of product types to include in the query.
- `bean_mode::String`: Beam mode for the query.
- `spatial_resolution::String`: Desired spatial resolution.
- `username::String`: Username for EODMS RAPI authentication.
- `password::String`: Password for EODMS RAPI authentication.
- `verbose::Int`: Verbosity level (0 for silent, >0 for messages).

# Returns
- `Dict`: A dictionary containing the search results.

# Example
```julia
results = download_metadata_rcm(area=my_area, start_datetime="2022-10-10", end_datetime="2022-10-11", 
                                max_records=10, collection="RCM", polarization=["HH", "HH HV"],
                                product_type=["GCC", "GRD"], bean_mode="ScanSAR 50%",
                                spatial_resolution="50", username="my_username", password="my_password", verbose=1)
````
"""               
function download_metadata_rcm(; area, 
    start_datetime::String="2022-10-10", 
    end_datetime::String="2022-10-11", 
    max_records::Int64=10,
    collection::String = "RCM",
    polarization::Array{String} = ["HH", "HH HV", "HH HV VH VV", "HH VV",],
    product_type::Array{String} =  ["GCC", "GCD", "GRC", "GRD"],
    bean_mode::String = "ScanSAR 50%",
    spatial_resolution::String = "50",
    username::String = "username",
    password::String = "password",
    verbose::Int = 1)  # Adjust product type if needed
    

    return nothing
end

