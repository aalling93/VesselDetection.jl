using Dates
using JSON
using LibGEOS

"""
    to_rcm_time(time::String)::String

Convert a given time string to the RCM (Radar Constellation Mission) specific time format.

This function accepts a time string in various common formats and converts it to the format 
used by RCM ("yyyyMMdd_HHmmss"). It is flexible in handling multiple input formats.

# Arguments
- `time::String`: Time string in various acceptable formats.

# Returns
- `String`: Time string formatted to the RCM-specific format.

# Examples
```julia
rcm_time = to_rcm_time("2022-10-10T12:30:00")
```
"""
function to_rcm_time(time::String)::String
    # List of potential input formats
    formats = [
        "yyyy-MM-dd_HH:mm:ss",  # Format like YYYY-MM-DD_HH:MM:SS
        "yyyy-MM-ddTHH:MM:SS",  # Format like YYYY-MM-DDTHH:MM:SS
        "yyyy-MM-dd",           # Just date
        "yyyyMMdd_HHmmss",      # Already in the desired format
        "yyyy/MM/dd HH:mm:ss",  # Other common formats
        "yyyy/MM/dd",
        "dd-MM-yyyy HH:mm:ss",
        "dd/MM/yyyy HH:mm:ss",
        "dd.MM.yyyy HH:mm:ss",
        "dd-MM-yyyy",
        "dd/MM/yyyy",
        "dd.MM.yyyy"
        # Add other formats as needed
    ]

    # Attempt to parse the input time string using each format
    for fmt in formats
        try
            parsed_time = DateTime(time, fmt)
            return Dates.format(parsed_time, "yyyyMMdd_HHmmss")
        catch
            continue
        end
    end

    error("Unable to parse time string with known formats")
end




"""
    get_bbox(input)

Construct a bounding box string from various input formats.

This function processes different input types to create a standardized bounding box string. 
It supports both array and string inputs, converting them into a "minLat, minLon, maxLat, maxLon" format.

# Arguments
- `input`: Input in the form of an array or string representing coordinates.

# Returns
- `String`: Bounding box string in "minLat, minLon, maxLat, maxLon" format.

# Examples
```julia
bbox_str = get_bbox([45, -75])
bbox_str = get_bbox("45,-75,46,-74")
```
"""
function get_bbox(input)
    # Helper function to format the bbox string
    format_bbox(values) = join(string.(values), ",")

    # Processing different input types
    if isa(input, Array)
        if length(input) == 2
            # [lat, long] format
            bbox = [input..., input...]  # Duplicate values for min and max
        elseif length(input) == 4
            # [lat min, lon min, lat max, lon max] format
            bbox = input
        else
            error("Invalid list input. List must have 2 or 4 elements.")
        end
    elseif isa(input, String)
        split_input = split(input, ',')
        if length(split_input) == 2
            # "lat, lon" format
            bbox = [parse(Float64, s) for s in split_input]
            bbox = bbox..., bbox...  # Duplicate values for min and max
        elseif length(split_input) == 4
            # "lat min, lon min, lat max, lon max" format
            bbox = [parse(Float64, s) for s in split_input]
        else
            error("Invalid string input. String must have 2 or 4 comma-separated values.")
        end
    else
        error("Unsupported input type. Input must be a list or string.")
    end

    # Validate the bbox values
    all(x -> isa(x, Number), bbox) || error("All values in the bounding box must be numeric.")
    length(bbox) == 4 || error("Bounding box must contain exactly 4 values.")

    # Ensure each value is a floating-point number
    bbox = float.(bbox)

    return format_bbox(bbox)
end




"""
    bounding_box_to_geojson(; lat_min, lat_max, lon_min, lon_max)

Converts bounding box coordinates to a GeoJSON string.

This function creates a GeoJSON representation of a bounding box defined by its 
minimum and maximum latitude and longitude values.

# Keyword Arguments
- `lat_min`, `lat_max`, `lon_min`, `lon_max`: Coordinates defining the bounding box.

# Returns
- `String`: GeoJSON string representing the bounding box.

# Example
```julia
geojson_string = bounding_box_to_geojson(lat_min=45.39, lat_max=45.40, lon_min=-75.71, lon_max=-75.69)
````
"""
function bounding_box_to_geojson(; lat_min, lat_max, lon_min, lon_max)
    # Define the GeoJSON structure
    geojson = Dict(
        "type" => "Polygon",
        "coordinates" => [[
            [lon_min, lat_min],
            [lon_min, lat_max],
            [lon_max, lat_max],
            [lon_max, lat_min],
            [lon_min, lat_min]  # Close the polygon
        ]]
    )

    # Convert the GeoJSON object to a string
    return ("within", geojson)
end


"""
    coordinate_to_geojson(lat::T, lon::T) where T<:Real

Create a GeoJSON string by generating a square area around a given coordinate.

This function constructs a square bounding box around a specified latitude and longitude 
and returns its GeoJSON representation. It is useful for creating area queries around a point.

# Arguments
- `lat::T`: Latitude of the center point.
- `lon::T`: Longitude of the center point.

# Returns
- GeoJSON representation of the bounding box around the given coordinate.

# Example
```julia
geojson_str = coordinate_to_geojson(45.41, -75.71)
```

"""
function coordinate_to_geojson(lat::T, lon::T) where T<:Real
    # Define a small offset to create a square area
    offset = 0.01

    # Define the corners of the square
    top_left = (lon - offset, lat + offset)
    top_right = (lon + offset, lat + offset)
    bottom_right = (lon + offset, lat - offset)
    bottom_left = (lon - offset, lat - offset)

    # Create the feature structure
    feats = [
        ("contains", [
            top_left,
            top_right,
            bottom_right,
            bottom_left,
            top_left  # Close the loop
        ])
    ]

    return feats
end




"""
    wkt_to_tuples(wkt_file)

Convert WKT (Well-Known Text) geometries from a file to a list of tuples.

This function reads WKT geometries from a specified file and converts them into a list of tuples, 
which can be used for spatial queries or further processing.

# Arguments
- `wkt_file`: File containing WKT geometries.

# Returns
- A list of tuples representing the geometries.

# Example
```julia
tuples = wkt_to_tuples("path_to_wkt_file.wkt")
```
"""
function wkt_to_tuples(wkt_file)
    # Read the WKT file
    wkt_data = read(wkt_file, String)

    # Split the data into individual geometries (assuming each geometry is on a new line)
    geometries = split(wkt_data, '\n')

    # Create tuples for each geometry
    feats = [("intersects", geom) for geom in geometries if !isempty(geom)]

    return feats
end




"""
    flatten_dict(d::Dict, parent_key::String="", sep::String="_")

Recursively flatten a nested dictionary into a single-level dictionary.

This function flattens a dictionary with nested structures into a single-level dictionary with 
concatenated keys, useful for data processing and transformation.

# Arguments
- `d::Dict`: The dictionary to flatten.
- `parent_key::String`: The base key for nested items (used internally).
- `sep::String`: Separator for concatenated keys.

# Returns
- `Dict{String, Any}`: Flattened dictionary.

# Example
```julia
flat_dict = flatten_dict(nested_dict)
```
"""
function flatten_dict(d::Dict, parent_key::String="", sep::String="_")
    flattened = Dict{String, Any}()
    for (k, v) in d
        if v isa Dict
            flattened = merge(flattened, flatten_dict(v, string(parent_key, k, sep)))
        elseif v isa Array
            for (i, item) in enumerate(v)
                if item isa Dict
                    flattened = merge(flattened, flatten_dict(item, string(parent_key, k, sep, i, sep)))
                else
                    flattened[string(parent_key, k, sep, i)] = item
                end
            end
        else
            flattened[string(parent_key, k)] = v
        end
    end
    return flattened
end

"""
    vector_of_dicts_to_dataframe(vec_of_dicts::Vector)

Convert a vector of dictionaries to a DataFrame.

This function transforms a vector containing dictionaries (each representing a data row) into a DataFrame. 
It's particularly useful when dealing with JSON data or similar structured data.

# Arguments
- `vec_of_dicts::Vector`: A vector containing dictionaries.

# Returns
- `DataFrame`: A DataFrame constructed from the vector of dictionaries.

# Example
```julia
df = vector_of_dicts_to_dataframe(my_data)
```
"""
function vector_of_dicts_to_dataframe(vec_of_dicts::Vector)
    rows = [flatten_dict(d) for d in vec_of_dicts]
    return DataFrame(rows)
end



# Function to convert a vector of dictionaries to a DataFrame
function dict_to_dataframe(vec_of_dicts::Vector)
    rows = [flatten_dict(d) for d in vec_of_dicts]
    return DataFrame(rows)
end


"""
    datetime_to_jd(dt::DateTime)

Convert a DateTime object to Julian Date (JD).

This function converts a given DateTime object to its corresponding Julian Date, 
a continuous count of days since the start of the Julian Period.

# Arguments
- `dt::DateTime`: DateTime object to convert.

# Returns
- `Float64`: Julian Date corresponding to the given DateTime.

# Example
```julia
jd = datetime_to_jd(DateTime(2022, 10, 10))
```
"""
function datetime_to_jd(dt::DateTime)
    a = div(14 - month(dt), 12)
    y = year(dt) + 4800 - a
    m = month(dt) + 12a - 3
    jd = day(dt) + div(153m + 2, 5) + 365y + div(y, 4) - div(y, 100) + div(y, 400) - 32045
    jd += (hour(dt) - 12) / 24 + minute(dt) / 1440 + second(dt) / 86400
    return jd
end


function tle_epoch_to_jd(tle::String)
    # Extracting year and day-of-year from the TLE
    year = parse(Int, tle[19:20]) + 2000  # Adjust based on TLE format
    day_of_year = parse(Float64, tle[21:32])

    # Convert to DateTime
    epoch_start = DateTime(year, 1, 1)
    epoch_datetime = epoch_start + Dates.Day(floor(day_of_year) - 1) + Dates.Millisecond(round((day_of_year % 1) * 86400000))

    # Convert DateTime to JD
    return datetime_to_jd(epoch_datetime), epoch_datetime
end





