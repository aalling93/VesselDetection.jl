using ZipFile
import Glob

"""
    unzip_file(; zip_path::String, output_folder::String)::Union{Nothing, Vector{String}}

Unzip a single file from `zip_path` to `output_folder`.

This function unzips the contents of a ZIP file specified by `zip_path` into the `output_folder`.
It returns a vector of top-level item paths in the ZIP file or `nothing` if unzipping fails.

# Arguments
- `zip_path::String`: Path to the ZIP file.
- `output_folder::String`: Folder where the unzipped contents will be stored.

# Returns
- `Union{Nothing, Vector{String}}`: A vector of top-level item paths or `nothing` in case of failure.

# Usage
```julia
top_level_items = unzip_file(zip_path="path/to/your/file.zip", output_folder="path/to/output/folder")
````
"""
function unzip_file(; zip_path::String, output_folder::String)
    @assert isfile(zip_path) "zip_path does not point to a valid file"
    @assert isdir(output_folder) || mkpath(output_folder) "output_folder is not a valid directory"
    top_level_items = Set{String}()

    try
        z = ZipFile.Reader(zip_path)
        try
            for f in z.files
                # Get the top-level name
                top_level_name = split(f.name, "/")[1]
                push!(top_level_items, top_level_name)  # Store the top-level name

                # Proceed to extract
                out_path = joinpath(output_folder, f.name)
                if endswith(f.name, "/")  # Directory
                    mkpath(out_path)
                else  # File
                    mkpath(dirname(out_path))
                    open(out_path, "w") do file
                        write(file, read(f))
                    end
                end
            end
        finally
            close(z)
        end
    catch e
        @warn "Failed to unzip file: $zip_path" exception=(e, catch_backtrace())
        return nothing
    end

    # Convert the set of top-level item names to full paths
    return [joinpath(output_folder, item) for item in top_level_items]
end


"""
unzip_all(folder_path::String, output_folder::String)::Vector{String}

Unzip all ZIP files found in a specified folder.

This function searches for all ZIP files in `folder_path` and unzips each file into `output_folder`.
It returns a vector containing the paths to the top-level items from all unzipped files. Each entry in
the vector represents a path to a file or directory that was at the top level in the corresponding ZIP file.

# Arguments
- `folder_path::String`: The folder containing ZIP files to be unzipped.
- `output_folder::String`: The folder where the contents of the ZIP files will be extracted.

# Returns
- `Vector{String}`: A vector of strings, each representing a path to a top-level item in the unzipped files.

# Usage
```julia
all_top_level_items = unzip_all("path/to/your/folder", "path/to/output/folder")
````

"""
function unzip_all(folder_path::String, output_folder::String)
    @assert isdir(folder_path) "folder_path is not a valid directory"
    @assert isdir(output_folder) || mkpath(output_folder) "output_folder is not a valid directory or could not be created"

    all_top_level_paths = String[]

    zip_files = Glob.glob("*.zip", folder_path)
    for zip_file in zip_files
        full_path = joinpath(folder_path, zip_file)
        top_level_paths = unzip_file(full_path, output_folder)
        append!(all_top_level_paths, top_level_paths)
    end

    return all_top_level_paths
end


