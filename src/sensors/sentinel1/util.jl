import Dates


"""
Utilities and get functions for the metadata..




Functions 

- getAnnotationPaths(safePath::string, satellite="s1")
- searchDir(path, key)
- getTimeDifference(startTime::Dates.DateTime,stopTime::Dates.DateTime)

"""


function get_reference_time(meta_dict)::DateTime
    start_time = meta_dict["product"]["adsHeader"]["startTime"]
    reference_time = DateTime(start_time[1:19])
    return reference_time
end


function parse_delta_time(time_string::String,reference_time::DateTime)
    milliseconds = Dates.value( DateTime(time_string[1:23]) - reference_time)
    microseconds = parse(Int, time_string[24:26])
    return milliseconds /1000.0 + microseconds*  10^-6
end


function get_data_path_sentinel1(safe_path::AbstractString, polarisation::Polarisation, swath::Integer)

    files = readdir(joinpath(safe_path,"measurement"))
    file_name = _find_file_sentinel1(files, polarisation, swath)
    return joinpath(safe_path,"measurement",file_name) 
end

function _find_file_sentinel1(files::Vector{T},polarisation::Polarisation, swath::Integer) where T <: AbstractString

    files_with_correct_name_format = files[ [ length(split(name,"-")) == 9 for name in files ] ]
    files_name_parts = [split(name,"-") for name in files_with_correct_name_format]

    files_polarisation = [ parse(Polarisation,name_parts[4]) for name_parts in files_name_parts]
    files_swath = [ parse(Int64,name_parts[2][3]) for name_parts in files_name_parts]

    file_name = files_with_correct_name_format[ (files_polarisation .== polarisation) .& (files_swath .==swath)]

    if length(file_name) != 1
        throw(ErrorException("Error, $(length(file_name)) files found"))
    end

    return file_name[1]
end





"""
getAnnotationPaths(safePath::string)

Getting the paths for the annotation files for a SLC image using its .SAFE folder path.

### Parameters
    * safePath::String: path of .SAFE folder for one image.
    
### Returns
    * annotationPaths::Vector: Vector of paths for annotation files in .SAFE folder
"""
function getAnnotationPaths(safePath::String)::Vector{String}
    annotationFolder = joinpath(safePath, "annotation")
    return [joinpath(annotationFolder, annotationFile) for annotationFile in searchDir(annotationFolder, ".xml")]
end


""""

search dir

Searching a directory for files with extention.

"""
searchDir(path, key) = filter(x -> occursin(key, x), readdir(path))


function getDictofXml(annotationFile::String)
    doc = EzXML.readxml(annotationFile)
    return XMLDict.xml_dict(doc)
end



""""
getTimeDifference(startTime::Dates.DateTime,stopTime::Dates.DateTime)

Getting time difference in seconds between to DateTimes.
time difference is calcualted as stopTime - startTime. 
Will return a negative value if stopTime is before startTime.

### Parameters
    * startTime::Dates.DateTime: Start time
    * stopTime::Dates.DateTime: End time. 

    
### Returns
    * timedifference in seconds

"""
function getTimeDifference(startTime::Dates.DateTime,stopTime::Dates.DateTime)::Float64
    return (stopTime-startTime).value/1000
end


"""
vecToDataframeRows(vec::Vector{Pair{String, String}})::NamedTuple

    turns a vector of two strings, e.g.,  "missionId" => "S1A", into a row for a DataFrame

    ### Parameters
    vec::Vector{Pair{String, String}}: 
    
    ### return 
    row for df
"""
function vecToDataframeRows(vec)::NamedTuple
    try
        return (Data=vec[1], Value=vec[2])
    catch
        return nothing
    end
end


"""
Utilities and get functions for the metadata..

# Functions
- get_sentinel1_annotation_paths(safe_path::string, satellite="s1")
- search_directory(path, key)
- read_xml_as_dict(annotationFile::string)
"""



"""
    get_sentinel1_annotation_paths(safe_path::string)

Getting the paths for the annotation files for a SLC image using its .SAFE folder path.

### Parameters
* `safe_path::String`: path of .SAFE folder for one image.

### Returns
* `annotationPaths::Vector`: Vector of paths for annotation files in .SAFE folder
"""
function get_sentinel1_annotation_paths(safe_path::String)::Vector{String}
    annotationFolder = joinpath(safe_path, "annotation")
    return [joinpath(annotationFolder, annotationFile) for annotationFile in search_directory(annotationFolder, ".xml")]
end

"""
getDataPaths(safePath::string)

Getting the paths for the annotation files for a SLC image using its .SAFE folder path.

### Parameters
    * safePath::String: path of .SAFE folder for one image.
    
### Returns
    * annotationPaths::Vector: Vector of paths for annotation files in .SAFE folder
"""
function get_sentinel1_measurement_paths(safePath::String)::Vector{String}
    dataFolder = joinpath(safePath, "measurement")
    return [joinpath(dataFolder, annotationFile) for annotationFile in searchDir(dataFolder, ".tiff")]
end





""""
    search_directory(path, key)

Searching a directory for files with extension.
"""
search_directory(path, key) = filter(x -> occursin(key, x), readdir(path))



function read_xml_as_dict(annotationFile::String)
    doc = open(f->read(f, String), annotationFile)
    return XMLDict.xml_dict(doc)
end


