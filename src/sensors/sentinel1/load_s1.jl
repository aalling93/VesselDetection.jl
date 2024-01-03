
"""
    Sentinel1GRD(safePath::String)

Create a Sentinel1GRD object from a Sentinel-1 GRD product.

This function reads the Sentinel-1 Ground Range Detected (GRD) product specified by the `safePath`. 
It loads the necessary metadata and image bands (co- and cross-polarization) to create a Sentinel1GRD object, 
which includes metadata, image data, and file paths.

# Arguments
- `safePath::String`: Path to the Sentinel-1 GRD product directory.

# Returns
- `Sentinel1GRD`: An object containing Sentinel-1 GRD data and metadata.

# Example
```julia
grd_product = Sentinel1GRD("path/to/S1_GRD_product")
```
"""
function Sentinel1GRD(safePath::String)
    annotationFolder = get_sentinel1_annotation_paths(safePath)
    DataFolder = get_sentinel1_measurement_paths(safePath)
    meta_dict = read_xml_as_dict(annotationFolder[1])

    metadata = Sentinel1GRDMetaData(meta_dict);
    co_pol = load_band(path = DataFolder[2]);
    cross_pol =load_band(path = DataFolder[1]);
    Paths = Sentinel1Folders(safePath)

    return Sentinel1GRD(metadata, [co_pol, cross_pol], Paths)
end

    
    


"""
    Sentinel1Folders(safeFolder::String)

Create a Sentinel1Folders object containing paths to various Sentinel-1 product components.

This function extracts and organizes paths to annotation and measurement folders of a Sentinel-1 product,
facilitating easy access to these components.

# Arguments
- `safeFolder::String`: Path to the Sentinel-1 product directory.

# Returns
- `Sentinel1Folders`: An object containing organized paths to Sentinel-1 product components.

# Example
```julia
folders = Sentinel1Folders("path/to/S1_product")
```
"""
function Sentinel1Folders(safeFolder::String)
    annotationFolder = get_sentinel1_annotation_paths(safeFolder)
    DataFolder = get_sentinel1_measurement_paths(safeFolder)
    return Sentinel1Folders(safeFolder,DataFolder[1], DataFolder[2], annotationFolder[1], annotationFolder[2])
end



"""
    load_sentinel1_grd(safe_path::AbstractString, polarisation::Polarisation, swath::Integer, window=nothing)

Load and return data and metadata for a specific Sentinel-1 GRD swath and polarization.

This function loads the TIFF data and metadata for a specified swath and polarization of a Sentinel-1 GRD product. 
It allows for selective reading of the data within a specified window, if provided.

# Arguments
- `safe_path::AbstractString`: Path to the Sentinel-1 GRD product.
- `polarisation::Polarisation`: Polarization type to load (e.g., HH, HV).
- `swath::Integer`: Swath number to load.
- `window`: Optional window for subsetting the data.

# Returns
- `Sentinel1SLC`: An object containing loaded Sentinel-1 GRD data and metadata.

# Example
```julia
slc_data = load_sentinel1_grd("path/to/S1_GRD", HH, 1)
```
"""
function load_sentinel1_grd(safe_path::AbstractString, polarisation::Polarisation, swath::Integer, window=nothing)
    tiff_path = get_data_path_sentinel1(safe_path, polarisation, swath)
    metadata_path = get_annotation_path_sentinel1(safe_path, polarisation, swath)
    
    data = load_tiff(tiff_path, window, convertToDouble = true, flip = true)
    metadata = Sentinel1MetaData(metadata_path)
    
    local index_start

    if isnothing(window)
        index_start = (1,1)
    else
        index_start = (window[1][1],window[2][1])
    end
    
    return Sentinel1SLC( metadata, index_start, data,false)
end





