module Sentinel1


using EzXML
using XMLDict
using Dates
#using Rasters, ArchGDAL, RasterDataSources, Statistics

include("tiffs.jl")
include("sentinel_1_types.jl")
include("util.jl")
include("header.jl")
include("sentinel1ImageInformation.jl")
include("geo_location.jl")
include("Sentinel1CoordinateConversion.jl")
include("metadata.jl")
include("load_s1.jl")
include("interpolations.jl")


end