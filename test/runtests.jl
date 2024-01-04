using VesselDetection
using Test
import Aqua


@testset "Test of VesselDetection.jl" begin

    # Ship Detection
    ## CFAR
    include("Ship_detection/cfar/test_ca_cfar.jl")
    include("Ship_detection/cfar/test_tp_cfar.jl")
    # other
    include("Ship_detection/test_filters.jl")
    include("Ship_detection/test_operations.jl")
    # model


  
    Aqua.test_all(VesselDetection; ambiguities = false)

end