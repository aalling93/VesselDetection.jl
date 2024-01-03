
"""
    calculate_accuracy(predictions::AbstractVector{Float64}, labels::AbstractVector{Bool}, threshold::Float32=0.5)::Float64

Calculate the accuracy of a set of predictions against true labels.

Accuracy is computed as the proportion of correct predictions, including both true positives and true negatives, among the total number of predictions.

# Arguments
- `predictions::AbstractVector{Float64}`: Vector of predicted probabilities.
- `labels::AbstractVector{Float64}`: Vector of actual  labels.
- `threshold::Float32`: Threshold for classifying a prediction as positive.

# Returns
- `Float64`: The accuracy score.

# Example
```julia
accuracy = calculate_accuracy([0.7, 0.3, 0.8], [1.0, 0.0, 1.0])
```
"""
function calculate_accuracy(predictions, labels, threshold::Float32=0.5)
    thresholded_predictions = predictions .> threshold
    return mean(thresholded_predictions .== labels)
end


function calculate_precision(predictions, labels, threshold::Float32=0.5)
    thresholded_predictions = predictions .> threshold
    true_positives = sum((thresholded_predictions .== 1) .& (labels .== 1))
    predicted_positives = sum(thresholded_predictions)
    return predicted_positives == 0 ? 0 : true_positives / predicted_positives
end

function calculate_recall(predictions, labels, threshold::Float32=0.5)
    thresholded_predictions = predictions .> threshold
    true_positives = sum((thresholded_predictions .== 1) .& (labels .== 1))
    actual_positives = sum(labels)
    return actual_positives == 0 ? 0 : true_positives / actual_positives
end

function calculate_f1_score(predictions, labels, threshold::Float32=0.5)
    precision = calculate_precision(predictions, labels, threshold)
    recall = calculate_recall(predictions, labels, threshold)
    return precision + recall == 0 ? 0 : 2 * (precision * recall) / (precision + recall)
end


"""
    calculate_class_metrics(predictions, true_labels, threshold, class_label)::NamedTuple

Calculate various classification metrics for a specific class label.

This function computes precision, recall, F1 score, and accuracy for a given class label based on the predictions, true labels, and a specified threshold.

# Arguments
- `predictions`: Vector of predicted probabilities.
- `true_labels`: Vector of actual labels.
- `threshold`: Threshold for classifying predictions.
- `class_label`: The class label for which metrics are calculated.

# Returns
- `NamedTuple`: A tuple containing precision, recall, F1 score, and accuracy.

# Example
```julia
metrics = calculate_class_metrics(predictions, true_labels, 0.5, 1)
```
"""
function calculate_class_metrics(predictions, true_labels, threshold, class_label)
    pred_labels = predictions .> threshold
    tp = sum((pred_labels .== class_label) .& (true_labels .== class_label))
    fp = sum((pred_labels .== class_label) .& (true_labels .!= class_label))
    tn = sum((pred_labels .!= class_label) .& (true_labels .!= class_label))
    fn = sum((pred_labels .!= class_label) .& (true_labels .== class_label))

    precision = tp / (tp + fp)
    recall = tp / (tp + fn)
    f1 = 2 * (precision * recall) / (precision + recall)
    accuracy = (tp + tn) / length(true_labels)

    return (precision=precision, recall=recall, f1=f1, accuracy=accuracy)
end

"""
    calculate_metrics(predictions, true_labels, threshold)::NamedTuple

Compute classification metrics for both classes (e.g., ships and icebergs) at a given threshold.

This function calculates precision, recall, F1 score, and accuracy for both classes separately.

# Arguments
- `predictions`: Vector of predicted probabilities.
- `true_labels`: Vector of actual labels.
- `threshold`: Threshold for classifying predictions.

# Returns
- `NamedTuple`: Contains metrics for both classes.

# Example
```julia
all_metrics = calculate_metrics(predictions, true_labels, 0.5)
```
"""
function calculate_metrics(predictions, true_labels, threshold)
    ship_metrics = calculate_class_metrics(predictions, true_labels, threshold, 1)
    iceberg_metrics = calculate_class_metrics(predictions, true_labels, threshold, 0)

    return (threshold=threshold, ships=ship_metrics, icebergs=iceberg_metrics)
end


"""
    compute_metrics_vector(predictions, labels, thresholds)::Vector

Compute classification metrics for a range of thresholds.

This function iterates over multiple thresholds to calculate various classification metrics, 
providing a comprehensive evaluation of model performance across different classification thresholds.

# Arguments
- `predictions`: Vector of predicted probabilities.
- `labels`: Vector of actual labels.
- `thresholds`: Vector of thresholds to evaluate.

# Returns
- `Vector`: A vector of NamedTuples containing metrics for each threshold.

# Example
```julia
metrics_vector = compute_metrics_vector(predictions, labels, 0:0.1:1)
```
"""
function compute_metrics_vector(predictions, labels, thresholds)
    metrics_vector = []

    for t in thresholds
        metrics = calculate_metrics(predictions, labels, t)
        push!(metrics_vector, metrics)
    end

    return metrics_vector
end



"""
    evaluate_test_set_at_threshold(test_predictions, test_labels, threshold)::NamedTuple

Evaluate the test set at a specific threshold to calculate classification metrics.

This function calculates classification metrics for a test set given a specific threshold, 
useful for assessing model performance on unseen data.

# Arguments
- `test_predictions`: Predictions on the test set.
- `test_labels`: Actual labels of the test set.
- `threshold`: Threshold for classifying predictions.

# Returns
- `NamedTuple`: Metrics for the test set at the given threshold.

# Example
```julia
test_metrics = evaluate_test_set_at_threshold(test_predictions, test_labels, 0.5)
```
"""
function evaluate_test_set_at_threshold(test_predictions, test_labels, threshold)
    # Ensure that test_labels are in the correct format (a vector, not a matrix)
    if typeof(test_labels) == Matrix
        test_labels = vec(test_labels)
    end
    
    # Ensure predictions are a vector if they are not already
    if typeof(test_predictions) == Matrix
        test_predictions = vec(test_predictions)
    end
    
    # Calculate metrics for ships
    ship_metrics = calculate_class_metrics(test_predictions, test_labels, threshold, 1)
    
    # Calculate metrics for icebergs
    iceberg_metrics = calculate_class_metrics(test_predictions, test_labels, threshold, 0)
    
    return (ships=ship_metrics, icebergs=iceberg_metrics)
end

# Function to calculate class metrics with positive_class as a required argument
function calculate_class_metrics(predictions, true_labels, threshold, class_label)
    pred_labels = predictions .> threshold
    tp = sum((pred_labels .== class_label) .& (true_labels .== class_label))
    fp = sum((pred_labels .== class_label) .& (true_labels .!= class_label))
    tn = sum((pred_labels .!= class_label) .& (true_labels .!= class_label))
    fn = sum((pred_labels .!= class_label) .& (true_labels .== class_label))

    precision = tp / (tp + fp)
    recall = tp / (tp + fn)
    f1 = 2 * (precision * recall) / (precision + recall)
    accuracy = (tp + tn) / length(true_labels)

    return (precision=precision, recall=recall, f1=f1, accuracy=accuracy)
end
