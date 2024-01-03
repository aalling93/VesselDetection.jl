
abstract type GroundRangeDetected end
abstract type SingleLookComplex end
abstract type Polarisation end
abstract type Swath end
abstract type Sentinel1MetaData end

struct IW <: Swath end
struct EW <: Swath end



struct HH <: Polarisation end
struct VV <: Polarisation end
struct HV <: Polarisation end
struct VH <: Polarisation end




mutable struct Sentinel1Folders
    safe::String
    co_pol::String
    cross_pol::String
    co_annotation::String
    cross_annotation::String
end




mutable struct Sentinel1GRD <: GroundRangeDetected
    metadata::Sentinel1MetaData
    data::Vector{Matrix{Float64}} 
    paths::Sentinel1Folders
end





"""
@enum Polarisation begin
    VV
    VH
    HV
    HH
end

"""
function convert_to_swath(str::String) :: Swath
    if str == "IW"
        return IW()
    elseif str == "EW"
        return EW()
    # Else, if the string is not IW or EW, but the str can be converted to a number, then convert to a number:
    else
        try 
            return parse(Int64, str)
        catch 
            error("Invalid Swath string: $str")
            return str
        end
        
    end
end





function convert_to_polarisation(str::String) :: Polarisation
    if str == "HH"
        return HH()
    elseif str == "VV"
        return VV()
    elseif str == "HV"
        return HV()
    elseif str == "VH"
        return VH()
    else
        error("Invalid polarisation string: $str")
    end
end
