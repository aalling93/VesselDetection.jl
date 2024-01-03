module VesselDetection

using Dates 

include("download/download.jl")
include("sensors/sensors.jl")
include("visualize/visualize.jl")
include("analysis/Analysis.jl")
include("ship_detector/Ship_detector.jl")


end
