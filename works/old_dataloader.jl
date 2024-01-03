


function load_images(folder_path::String, label ::Int64) 
    image_files = readdir(folder_path)
    images = [convert(Matrix{Float64}, Gray.(load(joinpath(folder_path, file)))) for file in image_files]
    images = [temp./maximum(temp) for temp in images]

    
    labels = fill(label, length(images))
    return images, labels
end

function extract_data(data)
    images = [item[1] for item in data]
    labels = [item[2] for item in data]
    return images, labels
end

function load_and_split_datasets(path_ships::String, path_icebergs::String)
    

    # Load images from folders
    ship_images, ship_labels = load_images(path_ships, 1)
    iceberg_images, iceberg_labels = load_images(path_icebergs, 0)

    # Combine and shuffle
    X = vcat(ship_images, iceberg_images)
    Y = vcat(ship_labels, iceberg_labels)
    data = shuffleobs(collect(zip(X, Y)))

    # Split the data
    (train_val, test) = splitobs(data, at=0.8)   # 80% for training+validation, 20% for test
    (train, val) = splitobs(train_val, at=0.75)  # 75% of 80% for training, 25% of 80% for validation

    # Extract images and labels
    train_X, train_Y = extract_data(train)
    val_X, val_Y = extract_data(val)
    test_X, test_Y = extract_data(test)

    return train_X, train_Y, val_X, val_Y, test_X, test_Y
end
