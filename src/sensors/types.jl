

abstract type SARImage end
export SARImage  # Export the SARImage type

abstract type MetaData end
export MetaData  # Export the MetaData type


# Define a test structure that extends SARImage
struct TestSAR <: SARImage
    # You can add fields here if needed
end

# Define a function to test instantiation of TestSAR
function test_sar()
    return TestSAR()  # Return an instance of TestSAR
end

