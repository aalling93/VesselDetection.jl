"""
    module VesselDetection

VesselDetection.jl is a sophisticated Julia module tailored for satellite-based maritime surveillance.
This comprehensive module integrates various aspects of satellite data processing, analysis, and vessel detection, 
making it a powerful tool for maritime researchers and analysts.

# Overview

The module encapsulates the complete workflow for vessel detection using satellite data:

- Orbital mechanics and satellite data handling.
- Sensor data preprocessing and analysis.
- Advanced image processing and analysis for vessel detection.
- Visualization tools for satellite data and detection results.
- Utilities for data downloading and management.

# Components

- `orbits`: 
  - `tle.jl`: Manages Two-Line Element (TLE) set data for satellite tracking.
  - `orbits.jl`: Provides calculations and utilities related to satellite orbits.

- `sensors`: 
  - `util.jl`: Utility functions for sensor data handling.
  - `types.jl`: Defines data types and structures for sensor data.
  - `sentinel1`: Specific implementations for handling Sentinel-1 satellite data.
  - `sensors.jl`: Central module for managing and preprocessing sensor data.

- `analysis`: 
  - `statistics.jl`: Statistical tools for data analysis.
  - `Analysis.jl`: Core analysis functionalities for processing and interpreting satellite imagery.

- `visualize`: 
  - `visualize.jl`: Main script for visualization of data and results.
  - `plot.jl`: Additional plotting and visualization utilities.

- `download`: 
  - `utils.jl`: Utilities for data downloading.
  - `download.jl`: Scripts for automated downloading of satellite data.
  - `products`: Handling and management of downloaded data products.
  - `metadata`: Management of metadata associated with satellite data.

- `ship_detector`: 
  - `filters.jl`: Image filters for enhancing and preprocessing imagery.
  - `operations.jl`: General operations and utilities for image processing.
  - `cfar`: Implementation of Constant False Alarm Rate (CFAR) algorithm for ship detection.
  - `model`: Machine learning models for ship detection.
  - `Ship_detector.jl`: Main module for the ship detection process.
  - `data`: Data handling and preprocessing specific to ship detection.

# Usage

Designed for maritime surveillance experts, researchers, and enthusiasts, this module offers a versatile 
toolkit for satellite-based vessel detection. It provides an integrated approach for data handling, 
processing, analysis, and visualization, catering to various needs in the maritime surveillance field.


# Examples

## Downloading data

```julia
using VesselDetection

# get metadata
data = VesselDetection.Download.Metadata.download_metadata_copernicus(bbox=bbox,
start_datetime=start_datetime,
end_datetime=end_datetime,
max_records="5",
collection="Sentinel1",
product_type= "GRD",
verbose=1);

# illustrate a quicklook image 
VesselDetection.Visualize.plot_quicklook_from_url(data,2)

# Download data
VesselDetection.Download.Products.download_product_copernicus(access_token = access_token, product_id = df[3,:id], filename="../data/test.zip")

```

## Train a binary CNN to classify ships

```julia
using VesselDetection

# get data
images, labels= VesselDetection.Ship_detector.create_dataset(json_data);
train_X, train_Y, val_X, val_Y, test_X, test_Y = VesselDetection.Ship_detector.shuffle_and_split_data(images, labels, 0.7, 0.1);

# create model
model  = VesselDetection.Ship_detector.Model.Binary_model.create_model(
                                                                input_channels =size(train_X[1])[3], 
                                                                img_size=size(train_X[1])[1:2], 
                                                                filter_sizes=[3, 3, 3], 
                                                                num_filters=[64, 64, 128], 
                                                                use_maxpool=[true, true, true], 
                                                                use_dropout=[0.3, 0.3, 0.3], 
                                                                dense_layers=[64], 
                                                                final_dense_units=1);

# prepare data

train_X_prepared = cat(train_X..., dims=4);
val_X_prepared = cat(val_X..., dims=4);
train_Y_prepared = hcat(train_Y...);
val_Y_prepared = hcat(val_Y...);

# train model   

loss_fn = VesselDetection.Ship_detector.Model.Binary_model.loss_fn;
epochs = 150;
learning_rate = 0.001;
batch_size = 128;

train_losses, train_accuracies, val_losses, val_accuracies =  VesselDetection.Ship_detector.Model.Binary_model.train_model(model, train_X_prepared, train_Y_prepared, val_X_prepared, val_Y_prepared, epochs, learning_rate, batch_size, loss_fn);                                                           
```

## One stage object detection

```julia
using VesselDetection

# load a sentinel-1 images
safe_folder = "../data/S1A_IW_GRDH_1SDV_20220612T173329_20220612T173354_043633_05359A_EA25.SAFE";
test_img = VesselDetection.Sensors.Sentinel1.Sentinel1GRD(safe_folder);

# define nessesary transformations
s1_transform = VesselDetection.Ship_detector.Transformation.TransformCompose([
    VesselDetection.Ship_detector.Transformation.absolute,
    x -> VesselDetection.Ship_detector.Transformation.clip_to_valid_range(x, amin=1, amax=65535),
    VesselDetection.Ship_detector.Transformation.to_db,
    x -> VesselDetection.Ship_detector.Transformation.min_max_scale(x, data_max=48.17, data_min=0, to_max=1, to_min=0),
    x -> VesselDetection.Ship_detector.Transformation.to_channels(x, [1, 2, 2]),
    VesselDetection.Ship_detector.Transformation.to_float32,
]);

# apply transformations
test_img2 = s1_transform(test_img.data);

# load model 
model =  VesselDetection.Ship_detector.Model.OneStageDetector.load_model(model_path = model_path)

# detect objects in image using model
results = VesselDetection.Ship_detector.Model.OneStageDetector.process_image_for_onnx(model, input);

# illustrate results
VesselDetection.Visualize.plot_image_with_boxes(image_matrix = input[2,:,:], bbox_dict = results, confidence_threshold = 0.20)
````

# Author

Kristian Aalling Sorensen, 2024.

"""
module VesselDetection

using Dates 

include("download/download.jl")
include("sensors/sensors.jl")
include("visualize/visualize.jl")
include("analysis/Analysis.jl")
include("ship_detector/Ship_detector.jl")


end
