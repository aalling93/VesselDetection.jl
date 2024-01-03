"""
Sentinel1CoordinateConversion

returns structure of product information
"""
Base.@kwdef struct Sentinel1CoordinateConversion
    azimuthTime::Vector{Float64}
    slantRangeTime::Vector{Float64}
    sr0::Vector{Float64}
    srgrCoefficients::Vector{Vector{Float64}}
    gr0::Vector{Float64}
    grsrCoefficients::Vector{Vector{Float64}}
end


""""
coordinateConversion

neededd for, e.g., range doppler geocoding..

    
    Number of coordinateConversion records (i.e. polynomial updates).  list. This element is a list of coordinateConversion records that describe
    conversion between the slant range and ground range coordinate systems. The list contains an entry for
    each update made along azimuth. This list applies to and is filled in only for GRD products and therefore
    has a length of zero for SLC products.

        The polynomial used to convert image pixels between slant range and ground range. The polynomials are
        time-stamped with the zero Doppler azimuth and two way slant range times to which they apply. The
        coefficients used on range lines between updates are found by linear interpolation between the updated
        and previous values. For a minimum spacing of 1s between coordinateConversion record updates and a
        maximum acquisition length of 25 minutes, the maximum number of records in the list is 1500.


- "azimuthTime"      => Zero Doppler azimuth time at which parameters apply [UTC]. 
- "slantRangeTime"   => Two way slant range time to first range sample [s].
- "sr0"              => Slant range origin used for ground range calculation [m].
- "srgrCoefficients" => Polynomial to convert from slant range to ground range. The order of polynomial n is given by the count
attribute -1. 
- "gr0"              => Ground range origin used for slant range calculation [m].
- "grsrCoefficients" => Polynomial to convert from ground range to slant range coefficients. The order of polynomial n is given
by the count attribute -1.

"""
function Sentinel1CoordinateConversion(meta_dict)::Sentinel1CoordinateConversion

    reference_time = get_reference_time(meta_dict)

    coordinateConversion = meta_dict["product"]["coordinateConversion"]["coordinateConversionList"]["coordinateConversion"]

    azimuthTime = [parse_delta_time(elem["azimuthTime"],reference_time) for elem in coordinateConversion]
    slantRangeTime = [parse(Float64, elem["slantRangeTime"]) for elem in coordinateConversion]

    sr0 = [parse(Float64, elem["sr0"]) for elem in coordinateConversion]
    gr0 = [parse(Float64, elem["gr0"]) for elem in coordinateConversion]

    srgrCoefficients = [parse.(Float64,split(elem["srgrCoefficients"][""]," ")) for elem in coordinateConversion]
    grsrCoefficients = [parse.(Float64,split(elem["grsrCoefficients"][""]," ")) for elem in coordinateConversion]

    coord_conversion = Sentinel1CoordinateConversion(azimuthTime,
    slantRangeTime,
    sr0,
    srgrCoefficients,
    gr0,
    grsrCoefficients)
    return coord_conversion
end