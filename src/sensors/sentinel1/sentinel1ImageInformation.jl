"""
    Sentinel1ImageInformation

returns structure of Sentinel1ImageInformation from metadata in .xml
"""

Base.@kwdef struct Sentinel1ImageInformation
    productFirstLineUtcTime::DateTime ##for SLC this should be in float..
    productLastLineUtcTime::DateTime
    ascendingNodeTime::DateTime
    sliceNumber::Int64
    slantRangeTime::Float64
    outputPixels::String
    rangePixelSpacing::Float64
    azimuthPixelSpacing::Float64
    numberOfSamples::Float64
    numberOfLines::Float64
    azimuth_frequency::Float64
    slant_range_time_seconds::Float64
    incidence_angle_mid_swath::Float64
    azimuth_time_interval::Float64
end



""""
    Sentinel1ImageInformation

Constructor for the Sentinel1ImageInformation structure.

It takes a dictionary containing the full sentinel-1 swath metadata and extracts the Sentinel1ImageInformation as a structure. Input in the Sentinel1ImageInformation file:
- `range_pixel_spacing`: Pixel spacing between range samples [m].
- `azimuth_frequency`: Azimuth line frequency of the output image [Hz]. This is the inverse of the azimuth_timeInterval.
- `slant_range_time_seconds`: Two-way slant range time to first sample.
- `incidence_angle_mid_swath`: Incidence angle at mid swath [degrees].
- `azimuth_pixel_spacing`: Nominal pixel spacing between range lines [m].
- `number_of_samples`: Total number of samples in the output image (image width).

# Input
- `meta_dict[dict]`: a dictionary of the metadata.

# Output
- `Sentinel1ImageInformation[structure of Sentinel1ImageInformation]`
"""
function Sentinel1ImageInformation(meta_dict)::Sentinel1ImageInformation
    image_informations = meta_dict["product"]["imageAnnotation"]["imageInformation"]

    productFirstLineUtcTime = DateTime(meta_dict["product"]["imageAnnotation"]["imageInformation"]["productFirstLineUtcTime"][1:19])
    productLastLineUtcTime = DateTime(meta_dict["product"]["imageAnnotation"]["imageInformation"]["productLastLineUtcTime"][1:19])
    ascendingNodeTime = DateTime(meta_dict["product"]["imageAnnotation"]["imageInformation"]["ascendingNodeTime"][1:19])
    sliceNumber= parse(Int64, image_informations["sliceNumber"])
    slantRangeTime = parse(Float64, image_informations["slantRangeTime"])
    outputPixels = image_informations["outputPixels"]
    rangePixelSpacing = parse(Float64, image_informations["rangePixelSpacing"])
    azimuthPixelSpacing = parse(Float64, image_informations["azimuthPixelSpacing"])
    numberOfSamples = parse(Float64, image_informations["numberOfSamples"])
    numberOfLines = parse(Float64, image_informations["numberOfLines"])
    azimuth_frequency = parse(Float64, image_informations["azimuthFrequency"])
    slant_range_time_seconds = parse(Float64, image_informations["slantRangeTime"])
    incidence_angle_mid_swath = parse(Float64, image_informations["incidenceAngleMidSwath"])
    azimuth_time_interval = parse(Float64, image_informations["azimuthTimeInterval"])
    

    image_informations = Sentinel1ImageInformation(
        productFirstLineUtcTime,
        productLastLineUtcTime,
        ascendingNodeTime,
        sliceNumber,
        slantRangeTime,
        outputPixels,
        rangePixelSpacing,
        azimuthPixelSpacing,
        numberOfSamples,
        numberOfLines,
        azimuth_frequency,
        slant_range_time_seconds,
        incidence_angle_mid_swath,
        azimuth_time_interval,)
    return image_informations
end



