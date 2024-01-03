using Flux: DataLoader
using Flux
using FileIO
using JLD2
using Logging
using BSON: @save
using Dates: now

"""
    train_model(model, train_X_prepared, train_Y, val_X_prepared, val_Y, epochs, learning_rate, batch_size, loss_fn, verbose=true, logger=nothing)

Train a machine learning model using provided training and validation data.

This function trains the model on the training set and evaluates it on the validation set over a specified number of epochs. It also computes and stores training and validation losses and accuracies. The best model (based on validation loss) is saved during training.

# Arguments
- `model`: The neural network model to be trained.
- `train_X_prepared`: Prepared training data.
- `train_Y`: Training labels.
- `val_X_prepared`: Prepared validation data.
- `val_Y`: Validation labels.
- `epochs::Int`: Number of epochs for training.
- `learning_rate::Float64`: Learning rate for the optimizer.
- `batch_size::Int`: Batch size for training.
- `loss_fn`: Loss function to be used for training.
- `verbose::Bool`: If `true`, print training progress.
- `logger`: Optional logger for recording training metrics.

# Returns
- `(train_losses, train_accuracies, val_losses, val_accuracies)`: A tuple containing lists of training and validation losses and accuracies for each epoch.

# Example
```julia
model = create_model(...)
train_losses, train_accuracies, val_losses, val_accuracies = train_model(model, train_X, train_Y, val_X, val_Y, 10, 0.001, 32, loss_fn)
```
"""
function train_model(model, train_X_prepared, train_Y, val_X_prepared, val_Y, epochs, learning_rate, batch_size, loss_fn, verbose = true,  logger = nothing)
    delete_if_exists("training_log.txt")

    opt = ADAM(learning_rate)
    loss(x, y) = loss_fn(model(x), y)
    accuracy(x, y) = mean((model(x) .> 0.5) .== y) #accuracy

    # Metrics storage
    train_losses = []
    val_losses = []
    train_accuracies = []
    val_accuracies = []

    for epoch in 1:epochs
        epoch_start_time = now()
        # Training
        train_loss = 0
        train_acc = 0
        count = 0
        for (x, y) in DataLoader((train_X_prepared, train_Y), batchsize=batch_size, shuffle=true)
            grads = gradient(Flux.params(model)) do
                l = loss(x, y)
                return l
            end
            Flux.update!(opt, Flux.params(model), grads)

            train_loss += loss(x, y)
            train_acc += accuracy(x, y)
            count += 1
        end

        push!(train_losses, train_loss / count)
        push!(train_accuracies, train_acc / count)

        # Validation
        val_loss = loss(val_X_prepared, val_Y)
        val_acc = accuracy(val_X_prepared, val_Y)
        push!(val_losses, val_loss)
        push!(val_accuracies, val_acc)

        if verbose
            avg_train_acc = train_acc / count  # Average training accuracy
            avg_train_loss = train_loss / count  # Average training loss
            @info "Epoch $epoch" train_loss=avg_train_loss val_loss=val_loss train_accuracy=avg_train_acc val_accuracy=val_acc
        end





        if logger != nothing
            Wandb.log(
                logger,
                Dict(
                    "Training/Loss" => train_loss,
                    "Training/Accuracy" => train_acc,
                    "Validation/Loss" => val_loss,
                    "Validation/Accuracy" => val_acc,
                ),
            )
            @info "metrics" accuracy=val_acc loss=val_loss
        end
        
        # generally it is best to save only the state.. however, for JuliaEO i am saving the entire model so it is easier to load it in ithe notebook. 
        if val_loss == minimum(val_losses)
            Flux.trainmode!(false)
            @save "best_model.bson" model

            if verbose
                @info "New best model saved at epoch $epoch"
            end         
            Flux.trainmode!(true)
        end
        
        Flux.trainmode!(false)
        @save "newest_model.bson" model              
        Flux.trainmode!(true)
        epoch_end_time = now()  # Track end time of epoch
        epoch_duration = epoch_end_time - epoch_start_time
        learning_rate = opt.eta
        
        log_training_metrics(epoch, train_loss / count, train_acc / count, val_loss, val_acc, learning_rate, epoch_duration)

    end

    
    return train_losses, train_accuracies, val_losses, val_accuracies
end

function log_training_metrics(epoch, train_loss, train_acc, val_loss, val_acc, learning_rate, epoch_duration, log_filename="training_log.txt")
    open(log_filename, "a") do file
        write(file, "Epoch: $epoch, Train Loss: $train_loss, Train Accuracy: $train_acc, Val Loss: $val_loss, Val Accuracy: $val_acc, Learning Rate: $learning_rate, Epoch Duration: $epoch_duration\n")
        flush(file)
    end
end



function delete_if_exists(filename)
    if isfile(filename)
        rm(filename)
    end
end
