using Interpolations



function interpolateDataoFrPoints(wanted_rows, wanted_columns, rows, columns, lats, lons, incidenceangle, height, azimuth_time, slant_range_time_seconds, elevation_angle)
    """
    Efficiently interpolate the latitude, longitude, incidence angle, height, azimuth time, slant range time, and elevation angle for given vectors of rows and columns using nearest values.

    Parameters:
    - wanted_rows: Vector of wanted row numbers.
    - wanted_columns: Vector of wanted column numbers.
    - rows: Array of row numbers.
    - columns: Array of column numbers.
    - lats: Array of latitudes.
    - lons: Array of longitudes.
    - incidenceangle: Array of incidence angles.
    - height: Array of heights.
    - azimuth_time: Array of azimuth times.
    - slant_range_time_seconds: Array of slant range times in seconds.
    - elevation_angle: Array of elevation angles.

    Returns:
    - Dictionary containing vectors for interpolated latitudes, longitudes, incidence angles, heights, azimuth times, slant range times, and elevation angles.
    """

    # Function to find the nearest points
    function find_nearest(array, value)
        idx = argmin(abs.(array .- value))
        return array[idx]
    end

    # Initialize vectors for the interpolated values
    interpolated_lats = Float64[]
    interpolated_lons = Float64[]
    interpolated_incidence = Float64[]
    interpolated_height = Float64[]
    interpolated_azimuth = Float64[]
    interpolated_slant_range = Float64[]
    interpolated_elevation = Float64[]

    # Convert the zipped iterator to an array of tuples
    row_col_pairs = collect(zip(rows, columns))

    # Iterate over each wanted row and column
    for (wanted_row, wanted_column) in zip(wanted_rows, wanted_columns)
        # Find the nearest row and column
        nearest_row = find_nearest(rows, wanted_row)
        nearest_col = find_nearest(columns, wanted_column)

        # Find the index of the nearest row and column
        idx = findfirst(isequal((nearest_row, nearest_col)), row_col_pairs)

        # Interpolate the values
        push!(interpolated_lats, lats[idx])
        push!(interpolated_lons, lons[idx])
        push!(interpolated_incidence, incidenceangle[idx])
        push!(interpolated_height, height[idx])
        push!(interpolated_azimuth, azimuth_time[idx])
        push!(interpolated_slant_range, slant_range_time_seconds[idx])
        push!(interpolated_elevation, elevation_angle[idx])
    end
    res = Dict("rows" => wanted_rows, 
            "columns"=> wanted_columns,
            "latitudes" => interpolated_lats,
            "longitudes" => interpolated_lons,
            "incidence_angles" => interpolated_incidence,
            "heights" => interpolated_height,
            "azimuth_times" => interpolated_azimuth,
            "slant_range_times" => interpolated_slant_range,
            "elevation_angles" => interpolated_elevation)


    # Return the results in a dictionary
    #return Dict("rows" => wanted_rows, "columns" => wanted_columns, "lats" => interpolated_lats, "Long" => interpolated_lons, "incidence_angles" => interpolated_incidence, "heights" => interpolated_height, "azimuth_times" => interpolated_azimuth, "slant_range_times" => interpolated_slant_range, "elevation_angles" => interpolated_elevation)
    return res
end


""""

incidenceangle, height, azimuth_time, slant_range_time_seconds, elevation_angle
(:lines, :samples, :latitude, :longitude, :azimuth_time, :slant_range_time_seconds, :elevation_angle, :incidence_angle, :height)

"""
function interpolateLatLonForPointsSentinel1(wanted_rows, wanted_columns, sentinel1_metadata)
    rows = sentinel1_metadata.geolocation.lines 
    columns = sentinel1_metadata.geolocation.samples

    lats = sentinel1_metadata.geolocation.latitude
    lons = sentinel1_metadata.geolocation.longitude

    incidenceangle = sentinel1_metadata.geolocation.incidence_angle
    height = sentinel1_metadata.geolocation.height
    azimuth_time = sentinel1_metadata.geolocation.azimuth_time
    slant_range_time_seconds = sentinel1_metadata.geolocation.slant_range_time_seconds
    elevation_angle = sentinel1_metadata.geolocation.elevation_angle


    return interpolateDataoFrPoints(wanted_rows, wanted_columns, rows, columns, lats, lons, incidenceangle, height, azimuth_time, slant_range_time_seconds, elevation_angle)
end






function interpolateLatLonForPoints(wanted_rows, wanted_columns, rows, columns, lats, lons)
    """
    Interpolate the latitude and longitude for given vectors of rows and columns.

    Parameters:
    - wanted_rows: Vector of wanted row numbers.
    - wanted_columns: Vector of wanted column numbers.
    - rows: Array of row numbers.
    - columns: Array of column numbers.
    - lats: Array of latitudes.
    - lons: Array of longitudes.

    Returns:
    - Two vectors: one for interpolated latitudes and one for interpolated longitudes.
    """

    # Create a grid for interpolation
    row_grid = unique(rows)
    col_grid = unique(columns)
    lat_grid = reshape(lats, length(row_grid), length(col_grid))
    lon_grid = reshape(lons, length(row_grid), length(col_grid))

    # Interpolation functions
    lat_interp = interpolate((row_grid, col_grid), lat_grid, Gridded(Linear()))
    lon_interp = interpolate((row_grid, col_grid), lon_grid, Gridded(Linear()))

    # Initialize vectors for latitudes and longitudes
    interpolated_lats = Float64[]
    interpolated_lons = Float64[]

    # Interpolate for each pair of wanted rows and columns
    for (row, col) in zip(wanted_rows, wanted_columns)
        push!(interpolated_lats, lat_interp(row, col))
        push!(interpolated_lons, lon_interp(row, col))
    end

    return Dict("rows" =>wanted_rows, "column"=>wanted_columns,   "lats" => interpolated_lats, "Long" => interpolated_lons)
end





function interpolateLatLon(wanted_row, wanted_column, rows, columns, lats, lons)
    """
    Interpolate the latitude and longitude for a given row and column.

    Parameters:
    - wanted_row: The row number to find.
    - wanted_column: The column number to find.
    - rows: Array of row numbers.
    - columns: Array of column numbers.
    - lats: Array of latitudes.
    - lons: Array of longitudes.

    Returns:
    - (latitude, longitude) interpolated values.
    """

    # Create a grid for interpolation
    row_grid = unique(rows)
    col_grid = unique(columns)
    lat_grid = reshape(lats, length(row_grid), length(col_grid))
    lon_grid = reshape(lons, length(row_grid), length(col_grid))

    # Interpolation functions
    lat_interp = interpolate((row_grid, col_grid), lat_grid, Gridded(Linear()))
    lon_interp = interpolate((row_grid, col_grid), lon_grid, Gridded(Linear()))

    # Interpolate latitude and longitude
    interpolated_lat = lat_interp(wanted_row, wanted_column)
    interpolated_lon = lon_interp(wanted_row, wanted_column)

    return interpolated_lat, interpolated_lon
end



function interpolateLatLonGrid(rows, columns, lats, lons)
    """
    Interpolate the latitude and longitude for the entire grid.

    Parameters:
    - rows: Array of row numbers.
    - columns: Array of column numbers.
    - lats: Array of latitudes.
    - lons: Array of longitudes.

    Returns:
    - Two matrices: one for interpolated latitudes and one for interpolated longitudes.
    """

    # Create a grid for interpolation
    row_grid = unique(rows)
    col_grid = unique(columns)
    lat_grid = reshape(lats, length(row_grid), length(col_grid))
    lon_grid = reshape(lons, length(row_grid), length(col_grid))

    # Interpolation functions
    lat_interp = interpolate((row_grid, col_grid), lat_grid, Gridded(Linear()))
    lon_interp = interpolate((row_grid, col_grid), lon_grid, Gridded(Linear()))

    # Define the full grid for interpolation
    full_row_grid = minimum(row_grid):maximum(row_grid)
    full_col_grid = minimum(col_grid):maximum(col_grid)

    # Initialize matrices for latitudes and longitudes
    lat_matrix = Array{Float64}(undef, length(full_row_grid), length(full_col_grid))
    lon_matrix = Array{Float64}(undef, length(full_row_grid), length(full_col_grid))

    # Populate the matrices
    for (i, row) in enumerate(full_row_grid)
        for (j, col) in enumerate(full_col_grid)
            lat_matrix[i, j] = lat_interp(row, col)
            lon_matrix[i, j] = lon_interp(row, col)
        end
    end

    return lat_matrix, lon_matrix
end