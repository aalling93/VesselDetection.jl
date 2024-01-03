# ╔═╡ Markdown Cell
begin
"""
# Title of the Tutorial

## Introduction
[brief introduction and objectives]
"""
end

# ╔═╡ Markdown Cell
begin
"""


## Table of Contents
- [Section 1](#section-1)
- [Section 2](#section-2)
- ...
"""
end

# ╔═╡ Markdown Cell
begin
"""
<div style="text-align: center">
    <img src="../figures/notebooks/dataspace.png" alt="Descriptive Image Text" width="900" style="border:1px solid black"/>
</div>

"""
end

# ╔═╡ Markdown Cell
begin
"""
## Init:
"""
end

# ╔═╡ Code Cell
begin
using Pkg
using DotEnv

include("../src/test_name.jl")

using .Test_name

DotEnv.config("../.env");
end

# ╔═╡ Markdown Cell
begin
"""
## Section 1: Metedata

"""
end

# ╔═╡ Code Cell
begin
access_token = Test_name.Download.get_access_token_copernicus(username = get(ENV, "DATASPACE_USERNAME", ""), password = get(ENV, "DATASPACE_PASSWORD", ""));
println(access_token[1:10])
end

# ╔═╡ Code Cell
begin
bbox = Test_name.Download.Metadata.get_bbox([-27.227298,38.650065]);
end

# ╔═╡ Code Cell
begin
data = Test_name.Download.Metadata.download_metadata_copernicus(bbox=bbox,
                                    start_datetime="2023-10-01T00:00:00Z", 
                                    end_datetime="2023-12-26T23:59:59Z", 
                                    max_records="5",
                                    collection="Sentinel1",
                                    product_type= "GRD",
                                    verbose=1);

end

# ╔═╡ Code Cell
begin
df = Test_name.Download.Metadata.vector_of_dicts_to_dataframe(data["features"]);
end

# ╔═╡ Code Cell
begin
println(df)
end

# ╔═╡ Markdown Cell
begin
"""

"""
end

# ╔═╡ Code Cell
begin
Test_name.Visualize.plot_quicklook_from_url(data,3)
end

# ╔═╡ Markdown Cell
begin
"""




## Section 2: Download

"""
end

# ╔═╡ Code Cell
begin
df[3,:id]
end

# ╔═╡ Code Cell
begin
access_token[1:10]
end

# ╔═╡ Code Cell
begin
Test_name.Download.Products.download_product_copernicus(access_token = access_token,product_id = df[3,:id], filename="../data/test.zip")
end

# ╔═╡ Markdown Cell
begin
"""
### Subsection 2.1: [Subsection Title]
[content]

## Conclusion and Further Resources
[concluding remarks and additional resources]

## About the Author
[Your information]

"""
end

# ╔═╡ Markdown Cell
begin
"""
/Users/kaaso/Documents/coding/JuliaEO2024/figures/notebooks/dataspace.png
"""
end


# ╔═╡ Introduction to Julia and EO Data
begin
"""

    # Introduction to Julia and Earth Observation Data
    Julia is a high-level, high-performance programming language well-suited for numerical analysis and computational science. Combined with its powerful libraries and tools, Julia is an excellent choice for Earth Observation (EO) data analysis. This workshop aims to introduce Julia's capabilities in handling, processing, and analyzing EO data.
    
"""
end


# ╔═╡ Getting Started with Julia
begin
"""

    # Getting Started with Julia
    In this section, we'll cover the basic setup of Julia for EO data analysis. This includes the installation of Julia, setting up the environment, and a brief overview of key packages such as `Pluto.jl` for interactive notebooks, `GeoData.jl` for geospatial data handling, and `Images.jl` for image processing.
    
"""
end


# ╔═╡ Data Acquisition and Preprocessing
begin
"""

    # Data Acquisition and Preprocessing
    Effective EO data analysis starts with the acquisition and preprocessing of data. This section will introduce methods to import EO data (e.g., satellite images, environmental data) into Julia, and basic preprocessing techniques to clean and prepare the data for analysis.
    
"""
end


# ╔═╡ Data Analysis and Visualization
begin
"""

    # Data Analysis and Visualization
    After preprocessing, the next step is to analyze the data. We'll explore various data analysis techniques suited for EO data and how to visualize the results using Julia's powerful visualization libraries like `Makie.jl` or `VegaLite.jl`.
    
"""
end
