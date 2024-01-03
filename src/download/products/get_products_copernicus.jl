using HTTP
using ProgressMeter
using HTTP
using FileIO


"""
    download_product_copernicus(; access_token::String, product_id::String, filename::String)

Download a specific product from the Copernicus data service.

The function fetches a product specified by `product_id` using the provided `access_token`, 
and saves it to a local file named `filename`.

# Arguments
- `access_token::String`: Access token for authentication.
- `product_id::String`: Unique identifier of the product to download.
- `filename::String`: Name of the file where the downloaded product will be saved.


# Example
```julia
download_product_copernicus(access_token="your_access_token", product_id="product_id", filename="local_filename")
```
"""
function download_product_copernicus(; access_token::String, product_id::String, filename::String)
    @assert !isempty(access_token) "Access token cannot be empty"
    @assert !isempty(product_id) "Product ID cannot be empty"
    @assert !isempty(filename) "Filename cannot be empty"
    # URL of the file
    url = "https://zipper.dataspace.copernicus.eu/odata/v1/Products($product_id)/\$value"

    # Authorization header
    headers = Dict("Authorization" => "Bearer $access_token")

    try
        # Make an HTTP GET request with the specified headers
        response = HTTP.get(url, headers=headers, request_timeout=30)
        
        # Check if the response status is successful
        if HTTP.status(response) == 200
            open(filename, "w") do file
                write(file, response.body)
            end
            println("File downloaded successfully.")
        else
            println("Failed to download the file. Status code: ", HTTP.status(response))
        end
    catch e
        println("Error: ", e)
    end

end

