module Ship_detector 


using Images 


include("data/transformation/transformation.jl")
include("data/dataloader.jl")

include("model/model.jl")

include("filters.jl")
include("operations.jl")
include("cfar/cfar.jl")

end