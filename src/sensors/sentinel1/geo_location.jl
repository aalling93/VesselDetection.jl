
"""
    Sentinel1GeolocationGrid

returns structure of Sentinel1GeolocationGrid from metadata in .xml
"""
Base.@kwdef struct Sentinel1GeolocationGrid
    lines::Vector{Int64}
    samples::Vector{Int64}
    latitude::Vector{Float64}
    longitude::Vector{Float64}
    azimuth_time::Vector{Float64}
    slant_range_time_seconds::Vector{Float64} # are stored as float because of accuracy
    elevation_angle::Vector{Float64}
    incidence_angle::Vector{Float64}
    height::Vector{Float64}
end


""""
Sentinel1GeolocationGrid

Constructors for the Sentinel1GeolocationGrid structure.

It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1GeolocationGrid as a structure. Input in the Sentinel1GeolocationGrid file:
- `lines`: Reference image MDS line to which this geolocation grid point applies.
- `samples`,
- `latitude`: Geodetic latitude of grid point [degrees].
- `longitude`: Geodetic longitude of grid point [degrees].
- `azimuth_time`: Zero Doppler azimuth time to which grid point applies [UTC].
- `slant_range_time_seconds`: Two-way slant range time to grid point.
- `elevation_angle`: Elevation angle to grid point [degrees].
- `incidence_angle`: Incidence angle to grid point [degrees].
- `height`: Height of the grid point above sea level [m].

# Example
    # accesing the geolocation data from the full metadata.
    xmlPath = "s1a-iw1-slc-vh-20220220t144146-20220220t144211-041998-050092-001.xml"
    Metadata1 = Sentinel1MetaData(xmlPath)
    geolocation = Metadata1.geolocation

    # accessing the geolocation directly from the xml.
    meta_dict = read_xml_as_dict(xmlPath)
    geolocation = Sentinel1GeolocationGrid(meta_dict)

# Input
- `meta_dict[dict]`: a dictionary of the metadata.

# Output
- `Sentinel1GeolocationGrid[structure of Sentinel1GeolocationGrid]`

"""
function Sentinel1GeolocationGrid(meta_dict)::Sentinel1GeolocationGrid

    reference_time = get_reference_time(meta_dict)

    geolocation = meta_dict["product"]["geolocationGrid"]["geolocationGridPointList"]["geolocationGridPoint"]

    lines = [parse(Int, elem["line"]) for elem in geolocation] .+ 1
    samples = [parse(Int, elem["pixel"]) for elem in geolocation] .+ 1
    latitude = [parse(Float64, elem["latitude"]) for elem in geolocation]
    longitude = [parse(Float64, elem["longitude"]) for elem in geolocation]
    azimuth_time = [parse_delta_time(elem["azimuthTime"],reference_time) for elem in geolocation]
    slant_range_time_seconds = [parse(Float64, elem["slantRangeTime"]) for elem in geolocation]
    elevation_angle = [parse(Float64, elem["elevationAngle"]) for elem in geolocation]
    incidence_angle = [parse(Float64, elem["incidenceAngle"]) for elem in geolocation]
    height = [parse(Float64, elem["height"]) for elem in geolocation]

    geolocation_grid = Sentinel1GeolocationGrid(lines,
        samples,
        latitude,
        longitude,
        azimuth_time,
        slant_range_time_seconds,
        elevation_angle,
        incidence_angle,
        height)
    return geolocation_grid
end
