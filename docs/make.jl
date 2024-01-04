using VesselDetection
using Documenter

DocMeta.setdocmeta!(VesselDetection, :DocTestSetup, :(using VesselDetection ); recursive=true)

makedocs(;
    modules=[VesselDetection],
    authors="Kristian Aalling Soerensen",
    repo="https://github.com/aalling93/VesselDetection.jl/blob/{commit}{path}#{line}",
    sitename="VesselDetection.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aalling93.github.io/VesselDetection.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md"
    ],
)

deploydocs(;
    repo="github.com/aalling93/VesselDetection.jl",
    devbranch="main",
)
