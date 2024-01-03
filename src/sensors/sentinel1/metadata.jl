"""
    Sentinel1MetaData

Metadata structure for the Sentinel-1 satellite for each burst in the swath.

General metadata info is kept in the following structures:
- `Sentinel1Header`
- `Sentinel1ProductInformation`
- `Sentinel1ImageInformation`
- `Sentinel1SwathTiming`
- `Sentinel1GeolocationGrid`
`Sentinel1BurstInformation` specific Info is kept in
- `Vector{Sentinel1BurstInformation}`

# Example
    slcMetadata = Sentinel1MetaData(meta_dict)

# Input
- `meta_dict`: xml file.

Can be accessed as, e.g.,
    slcMetadata.product.radar_frequency --> 5.40500045433435e9::Float64
    slcMetadata.header.swath --> 1::Int
    slcMetadata.header.mode --> "IW"::String
    slcMetadata.header.polarisation --> "VH"::String
"""
Base.@kwdef struct Sentinel1GRDMetaData <: Sentinel1MetaData
    reference_time::DateTime
    header::Sentinel1Header
    image::Sentinel1ImageInformation
    geolocation::Sentinel1GeolocationGrid
    coordinate_conversion::Sentinel1CoordinateConversion
end


function Sentinel1GRDMetaData(meta_dict)

    reference_time = get_reference_time(meta_dict)
    header = Sentinel1Header(meta_dict);
    imageinfo = Sentinel1ImageInformation(meta_dict);
    geolocation = Sentinel1GeolocationGrid(meta_dict);
    coordinate_conversion = Sentinel1CoordinateConversion(meta_dict);

    metadata = Sentinel1GRDMetaData(
        reference_time,
        header,
        imageinfo,
        geolocation,
        coordinate_conversion
    )
    return metadata
end
