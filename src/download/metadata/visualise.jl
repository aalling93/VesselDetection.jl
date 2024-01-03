using Plots, DataFrames, GeometryBasics
#using GeometryTypes  # or the relevant package where Point is defined
import GeometryBasics
# Ensure PlotlyJS backend is active
#plotlyjs()

"""
    plot_polygons(df::DataFrame, polygon_column::Symbol, hover_column::Symbol)

Plot polygons on a map based on the coordinates provided in a DataFrame.

This function takes a DataFrame containing polygon coordinates and additional information 
to be displayed on hover, and plots these polygons on a map. The polygons are outlined and filled, 
with labels at their centroids indicating the hover information.

# Arguments
- `df::DataFrame`: The DataFrame containing the polygon data.
- `polygon_column::Symbol`: Column name in `df` containing the polygon coordinates.
- `hover_column::Symbol`: Column name in `df` whose values are shown when hovering over the polygons.

# Example
```julia
plot_polygons(my_df, :PolygonCoords, :HoverInfo)
```
"""
function plot_polygons(df, polygon_column, hover_column)
    # Check if required columns exist in the DataFrame
    if !(polygon_column in names(df)) || !(hover_column in names(df))
        error("Specified columns do not exist in the DataFrame.")
    end

    plt = plot(layout=(1, 1), legend=:outertopright)  # Set the legend to the right of the plot

    # Variables to store min and max longitude and latitude values
    min_lon, max_lon = Inf, -Inf
    min_lat, max_lat = Inf, -Inf

    # Iterate over rows in the DataFrame
    for (index, row) in enumerate(eachrow(df))
        raw_polygon = row[polygon_column]
        points = [GeometryBasics.Point(coords...) for coords in raw_polygon]
        xs = [p[1] for p in points]
        ys = [p[2] for p in points]

        # Update min and max longitude and latitude
        min_lon = min(min_lon, minimum(xs))
        max_lon = max(max_lon, maximum(xs))
        min_lat = min(min_lat, minimum(ys))
        max_lat = max(max_lat, maximum(ys))

        # Add the first point at the end to close the polygon
        append!(xs, xs[1])
        append!(ys, ys[1])

        # Plot the polygon
        plot!(plt, xs, ys, fillrange=0, fillalpha=0.3, fillcolor=:blue, linecolor=:black, label=row[hover_column])

        # Calculate centroid of the polygon for annotation
        centroid_x, centroid_y = calculate_polygon_centroid(xs, ys)


        # Annotate the polygon with the row index
        annotate!(plt, centroid_x, centroid_y, text(string(index), :center, 10, :black, RGBA(0,0,0,0.3)))
    end

    # Set plot limits
    xlims!(plt, (min_lon, max_lon))
    ylims!(plt, (min_lat, max_lat))

    # Customize the plot
    xlabel!(plt, "Longitude")
    ylabel!(plt, "Latitude")
    title!(plt, "Polygon Plot")

    # Display the plot
    display(plt)
end


function calculate_polygon_centroid(xs, ys)
    area = 0.0
    cx = 0.0
    cy = 0.0
    for i in 1:length(xs)-1
        a = xs[i] * ys[i+1] - xs[i+1] * ys[i]
        area += a
        cx += (xs[i] + xs[i+1]) * a
        cy += (ys[i] + ys[i+1]) * a
    end
    area /= 2
    cx /= (6 * area)
    cy /= (6 * area)
    return cx, cy
end
