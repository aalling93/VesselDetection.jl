using Statistics 

"""
    loss_fn(predictions, targets)

Calculate the binary cross-entropy loss between predictions and targets.

Binary cross-entropy loss measures the performance of a classification model whose output is a probability value between 0 and 1. The loss increases as the predicted probability diverges from the actual label. It is a common loss function for binary classification tasks.

# Arguments
- `predictions`: Predicted probabilities, typically as the output of a sigmoid function.
- `targets`: Actual binary targets/labels (0 or 1).

# Returns
- Loss value computed as the mean binary cross-entropy across all predictions.

# Example
```julia
predictions = [0.5, 0.8, 0.1]
targets = [0, 1, 0]
loss = loss_fn(predictions, targets)
```
"""
function loss_fn(predictions, targets)
    # Ensure that predictions are clipped to avoid log(0)
    eps = 1e-7
    predictions = clamp.(predictions, eps, 1 - eps)
    return -mean(targets .* log.(predictions) + (1 .- targets) .* log.(1 .- predictions))
end
