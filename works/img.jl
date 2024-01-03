using ImageView, Images
using TestImages
using Makie

# Plot the image
vh_band_file = "/Users/kaaso/Documents/coding/JuliaEO2024/data/S1A_IW_GRDH_1SDV_20220612T173329_20220612T173354_043633_05359A_EA25.SAFE/measurement/s1a-iw-grd-vh-20220612t173329-20220612t173354-043633-05359a-002.tiff"
vv_band_file = "/Users/kaaso/Documents/coding/JuliaEO2024/data/S1A_IW_GRDH_1SDV_20220612T173329_20220612T173354_043633_05359A_EA25.SAFE/measurement/s1a-iw-grd-vv-20220612t173329-20220612t173354-043633-05359a-001.tiff"



# Load the image
image = load(vv_band_file)



scene = Makie.imshow(image, colormap = :grays)  # For grayscale images

# Adding titles and labels
Makie.title!(scene, "TIFF Image")
Makie.xlabel!(scene, "X Axis")
Makie.ylabel!(scene, "Y Axis")
