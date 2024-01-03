using HTTP
using JSON

"""
    get_access_token_copernicus(; username::String, password::String)::String

Obtain an access token from the Copernicus Data Space (CDSE) authentication server.

This function makes a POST request to the CDSE authentication server with the provided credentials and retrieves an access token.

# Arguments
- `username::String`: Username for authentication.
- `password::String`: Password for authentication.

# Returns
- `String`: Access token.

# Usage
```julia
access_token = get_access_token_copernicus(username="my_username", password="my_password")
```
"""
function get_access_token_copernicus(; username::String, password::String)::String
    @assert !isempty(username) "Username cannot be empty"
    @assert !isempty(password) "Password cannot be empty"

    # Construct the body data in application/x-www-form-urlencoded format
    body_data = "client_id=cdse-public&username=$(username)&password=$(password)&grant_type=password"
    # URL for the token request
    url = "https://identity.dataspace.copernicus.eu/auth/realms/CDSE/protocol/openid-connect/token"
    # Set the Content-Type header
    headers = Dict("Content-Type" => "application/x-www-form-urlencoded")
    try
        # Make the POST request
        response = HTTP.post(url, headers, body=body_data)
        response_body = JSON.parse(String(response.body))
        # Check if the request was successful
        if HTTP.status(response) != 200
            error("Access token creation failed. Response from the server was: $(String(response.body))")
        end
        return response_body["access_token"]
    catch e
        error("Access token creation encountered an error: $e")
    end
end


"""
    make_directory_recursive(path::String)

Create a directory and all its parent directories as needed.

This function takes a file system path and creates the directory specified by the path along with all necessary parent directories.

# Arguments
- `path::String`: The path of the directory to create.

# Usage
```julia
make_directory_recursive("/path/to/directory")
````
"""
function make_directory_recursive(path::String)
    @assert !isempty(path) "Path cannot be empty"
    # Use splitpath for platform independence
    path_parts = splitpath(path)
    
    # Handle absolute paths
    partial_path = startswith(path, "/") ? "/" : ""

    # Iterate through parts of the path
    for part in path_parts
        # Update the partial path
        partial_path = joinpath(partial_path, part)

        # Check if this part of the path exists
        if !isdir(partial_path)
            # Create the directory if it doesn't exist
            mkdir(partial_path)
        end
    end
end
