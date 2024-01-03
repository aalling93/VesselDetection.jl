"""
    Sentinel1Header

returns structure of Sentinel1Header from metadata in .xml
"""
Base.@kwdef struct Sentinel1Header
    mission_id::String
    product_type::String
    polarisation::Polarisation
    swath::Swath
    mode::String
    start_time::Float64
    stop_time::Float64
    absolute_orbit_number::Int
    image_number::String
end


""""
    Sentinel1Header

Constructors for the Sentinel1Header structure.

It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1Header as a structure. Input in the header file:
- `missionId`: Mission identifier for this data set.
- `productType`: Product type for this data set.
- `polarisation`: Polarisation for this data set.
- `swath`: Swath identifier for this data set. This element identifies the swath that applies to all data contained within this data set. The swath identifier "EW" is used for products in which the 5 EW swaths have been merged. Likewise, "IW" is used for products in which the 3 IW swaths have been merged.
- `mode`: Sensor mode for this data set.
- `start_time`: Zero Doppler start time of the output image [UTC].
- `stop_time`: Zero Doppler stop time of the output image [UTC].
- `absolute_orbit_number`: Absolute orbit number at data set start time.
- `image_number`: Image number. For WV products the image number is used to distinguish between vignettes. For SM, IW and EW modes the image number is still used but refers instead to each swath and polarisation combination (known as the 'channel') of the data.

# Input
- `meta_dict[dict]`: a dictionary of the metadata.

# Output
- `Sentinel1Header[structure of Sentinel1Header]`

"""
function Sentinel1Header(meta_dict)::Sentinel1Header

    reference_time = get_reference_time(meta_dict)



    missionId = meta_dict["product"]["adsHeader"]["missionId"]
    productType = meta_dict["product"]["adsHeader"]["productType"]
    polarisation = convert_to_polarisation(meta_dict["product"]["adsHeader"]["polarisation"])
    swath = meta_dict["product"]["adsHeader"]["swath"]
    mode = meta_dict["product"]["adsHeader"]["mode"]
    start_time = meta_dict["product"]["adsHeader"]["startTime"]
    stop_time = meta_dict["product"]["adsHeader"]["stopTime"]
    absolute_orbit_number = meta_dict["product"]["adsHeader"]["absoluteOrbitNumber"]
    image_number = meta_dict["product"]["adsHeader"]["imageNumber"]
    stop_time = parse_delta_time(stop_time,reference_time)
    start_time = parse_delta_time(start_time,reference_time)
    absolute_orbit_number = parse(Int, absolute_orbit_number)
    swath = convert_to_swath(swath)


    header = Sentinel1Header(missionId,
        productType,
        polarisation,
        swath,
        mode,
        start_time,
        stop_time,
        absolute_orbit_number,
        image_number)
    return header
end
