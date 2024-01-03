using Test

# Test for get_bbox function

# Test with valid inputs
@test get_bbox([10, 20]) == "10.0,20.0,10.0,20.0"
@test get_bbox([10, 20, 30, 40]) == "10.0,20.0,30.0,40.0"
@test get_bbox("10,20") == "10.0,20.0,10.0,20.0"
@test get_bbox("10,20,30,40") == "10.0,20.0,30.0,40.0"

# Additional tests as previously provided

println("All tests passed!")
