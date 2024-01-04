using Test



function tp_cfar_test()

    image_no_objects = [i for i=1:0.5:20.5, j=1:40];
    image_with_objects =[i for i=1:0.5:20.5, j=1:40]
    image_with_objects[20,10] = 60000;  #object
    image_with_objects[4,5] = 60000; #object 
    image_with_objects[20:30,20:33] .= 60000; #large object


    cfar1 = VesselDetection.Ship_detector.two_parameter_constant_false_alarm_rate(image_no_objects,5,3,0.01);
    cfar2 = VesselDetection.Ship_detector.two_parameter_constant_false_alarm_rate(image_with_objects,5,3,0.01);

    check = sum(cfar2)==8;
    check &= sum(cfar1)==0;

    if !check
        println("Error in test for CA-CFAR")
    end
    return check
end




# Test case for two_parameter_constant_false_alarm_rate function
@testset "TP CFAR Tests" begin
    @testset "Test Case 1" begin
        @test tp_cfar_test()
    end
end