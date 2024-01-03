using HTTP, DataFrames, JSON3



"""
    download_metadata_copernicus(; bbox::String, start_datetime::String, end_datetime::String, 
                                  max_records::String, collection::String, product_type::String, 
                                  verbose::Int)::Dict

Download metadata for products from the Copernicus data service within a specified bounding box and time range.

This function queries the Copernicus data service for metadata of products that fall within the specified spatial and temporal parameters.

# Arguments
- `bbox::String`: Bounding box for the query in the format "minLon,minLat,maxLon,maxLat".
- `start_datetime::String`: Start datetime of the query in ISO 8601 format.
- `end_datetime::String`: End datetime of the query in ISO 8601 format.
- `max_records::String`: Maximum number of records to retrieve.
- `collection::String`: Data collection to query, e.g., "Sentinel1".
- `product_type::String`: Type of the product, e.g., "SLC".
- `verbose::Int`: Verbosity level (0 for silent, >0 for messages).

# Returns
- `Dict`: A dictionary containing the parsed JSON response.

# Example
```julia
metadata = download_metadata_copernicus(bbox="4,51,4.5,52", start_datetime="2022-06-11T00:00:00Z", 
                                        end_datetime="2022-06-22T23:59:59Z", max_records="10",
                                        collection="Sentinel1", product_type="SLC", verbose=1)
````
"""
function download_metadata_copernicus(; bbox::String="4,51,4.5,52", 
                               start_datetime::String="2022-06-11T00:00:00Z", 
                               end_datetime::String="2022-06-22T23:59:59Z", 
                               max_records::String="10",
                               collection::String = "Sentinel1",
                               product_type::String = "SLC",
                               verbose::Int = 1)  # Adjust product type if needed
    
    
    @assert !isempty(bbox) "Bounding box cannot be empty"
    @assert !isempty(start_datetime) "Start datetime cannot be empty"
    @assert !isempty(end_datetime) "End datetime cannot be empty"
    @assert !isempty(max_records) && isdigit(max_records[1]) "Max records must be a number"
    @assert !isempty(collection) "Collection cannot be empty"
    @assert !isempty(product_type) "Product type cannot be empty"

    # Define the base URL for the Sentinel-1 data collection
    base_url = "https://catalogue.dataspace.copernicus.eu/resto/api/collections/$collection/search.json?"

    # Set the query parameters for the Sentinel-1 data request
    params = Dict(
        "productType" => "$product_type",   # Change to the desired Sentinel-1 product type
        "startDate" => "$start_datetime",
        "completionDate" => "$end_datetime",
        "maxRecords" => "$max_records",
        "box" => "$bbox"   # Adjust the coordinates to your area of interest
    )
    # Convert the parameters dictionary to URL query string
    query_string = HTTP.escapeuri(params)

    # Construct the full URL for the request
    full_url = string(base_url, query_string)

    # Perform the GET request
    response = HTTP.get(full_url)

    # Parse the response body to JSON
    data = JSON.parse(String(response.body))

    # Check the status code to ensure the request was successful
    if response.status == 200
        if verbose>0
            println("Request successful.")
        end
    else
        println("Request failed with status code: ", response.status)
    end
    return data
end




