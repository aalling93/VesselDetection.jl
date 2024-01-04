#push!(LOAD_PATH,"../src/")
using VesselDetection
using Documenter

DocMeta.setdocmeta!(VesselDetection, :DocTestSetup, :(using VesselDetection ); recursive=true)

makedocs(;
    modules=[VesselDetection],
    authors="Kristian Aalling Soerensen",
    repo="https://github.com/aalling93/VesselDetection.jl",
    sitename="VesselDetection.jl",
    pages=[
        "Home" => "index.md"
    ],
)

deploydocs(;
    repo="github.com/aalling93/VesselDetection.jl",
    devbranch="main",
)
