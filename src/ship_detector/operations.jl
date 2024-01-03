using Base.Math: @horner, libm
using Base.MPFR: ROUNDING_MODE



"""
    erfinv(x)

Compute the inverse error function of a real `x`, defined by ``\\operatorname{erf}(\\operatorname{erfinv}(x)) = x``.
"""
function erfinv(x::Float64)
    a = abs(x)
    if a >= 1.0
        if x == 1.0
            return Inf
        elseif x == -1.0
            return -Inf
        end
        throw(DomainError())
    elseif a <= 0.75 # Table 17 in Blair et al.
        t = x*x - 0.5625
        return x * @horner(t, 0.16030_49558_44066_229311e2,
                             -0.90784_95926_29603_26650e2,
                              0.18644_91486_16209_87391e3,
                             -0.16900_14273_46423_82420e3,
                              0.65454_66284_79448_7048e2,
                             -0.86421_30115_87247_794e1,
                              0.17605_87821_39059_0) /
                   @horner(t, 0.14780_64707_15138_316110e2,
                             -0.91374_16702_42603_13936e2,
                              0.21015_79048_62053_17714e3,
                             -0.22210_25412_18551_32366e3,
                              0.10760_45391_60551_23830e3,
                             -0.20601_07303_28265_443e2,
                              0.1e1)
    elseif a <= 0.9375 # Table 37 in Blair et al.
        t = x*x - 0.87890625
        return x * @horner(t, -0.15238_92634_40726_128e-1,
                               0.34445_56924_13612_5216,
                              -0.29344_39867_25424_78687e1,
                               0.11763_50570_52178_27302e2,
                              -0.22655_29282_31011_04193e2,
                               0.19121_33439_65803_30163e2,
                              -0.54789_27619_59831_8769e1,
                               0.23751_66890_24448) /
                   @horner(t, -0.10846_51696_02059_954e-1,
                               0.26106_28885_84307_8511,
                              -0.24068_31810_43937_57995e1,
                               0.10695_12997_33870_14469e2,
                              -0.23716_71552_15965_81025e2,
                               0.24640_15894_39172_84883e2,
                              -0.10014_37634_97830_70835e2,
                               0.1e1)
    else # Table 57 in Blair et al.
        t = 1.0 / sqrt(-log(1.0 - a))
        return @horner(t, 0.10501_31152_37334_38116e-3,
                          0.10532_61131_42333_38164_25e-1,
                          0.26987_80273_62432_83544_516,
                          0.23268_69578_89196_90806_414e1,
                          0.71678_54794_91079_96810_001e1,
                          0.85475_61182_21678_27825_185e1,
                          0.68738_08807_35438_39802_913e1,
                          0.36270_02483_09587_08930_02e1,
                          0.88606_27392_96515_46814_9) /
              (copysign(t, x) *
               @horner(t, 0.10501_26668_70303_37690e-3,
                          0.10532_86230_09333_27531_11e-1,
                          0.27019_86237_37515_54845_553,
                          0.23501_43639_79702_53259_123e1,
                          0.76078_02878_58012_77064_351e1,
                          0.11181_58610_40569_07827_3451e2,
                          0.11948_78791_84353_96667_8438e2,
                          0.81922_40974_72699_07893_913e1,
                          0.40993_87907_63680_15361_45e1,
                          0.1e1))
    end
end

function erfinv(x::Float32)
    a = abs(x)
    if a >= 1.0f0
        if x == 1.0f0
            return Inf32
        elseif x == -1.0f0
            return -Inf32
        end
        throw(DomainError())
    elseif a <= 0.75f0 # Table 10 in Blair et al.
        t = x*x - 0.5625f0
        return x * @horner(t, -0.13095_99674_22f2,
                               0.26785_22576_0f2,
                              -0.92890_57365f1) /
                   @horner(t, -0.12074_94262_97f2,
                               0.30960_61452_9f2,
                              -0.17149_97799_1f2,
                               0.1f1)
    elseif a <= 0.9375f0 # Table 29 in Blair et al.
        t = x*x - 0.87890625f0
        return x * @horner(t, -0.12402_56522_1f0,
                               0.10688_05957_4f1,
                              -0.19594_55607_8f1,
                               0.42305_81357f0) /
                   @horner(t, -0.88276_97997f-1,
                               0.89007_43359f0,
                              -0.21757_03119_6f1,
                               0.1f1)
    else # Table 50 in Blair et al.
        t = 1.0f0 / sqrt(-log(1.0f0 - a))
        return @horner(t, 0.15504_70003_116f0,
                          0.13827_19649_631f1,
                          0.69096_93488_87f0,
                         -0.11280_81391_617f1,
                          0.68054_42468_25f0,
                         -0.16444_15679_1f0) /
              (copysign(t, x) *
               @horner(t, 0.15502_48498_22f0,
                          0.13852_28141_995f1,
                          0.1f1))
    end
end

erfinv(x::Integer) = erfinv(float(x))




"""
Add padding to array


"""
function add_padding(array::Matrix{T} where T<: Real, padding_width::Integer=7, pad_value::Real=P where P<: Real )
    input_rows, input_columns = size(array);
    padded_image = ones(input_rows+padding_width*2,input_columns+padding_width*2)*pad_value;
    padded_image[padding_width+1:input_rows+padding_width,padding_width+1:input_columns+padding_width] = array;
    return padded_image
end


"""
    binarize_array(image::Matrix{T}, threshold::Real= 0.0001) where T<:Real

Making a mask with boolean values of image

# Examples
    bool_array = binarize_array(rand(10,10), threshold= 0.0001)
"""
function binarize_array(image::Matrix{T}, threshold::Real= 0.0001) where T<:Real
    binary_image = similar(image,T)
    binary_image[image .> threshold].=1;
    binary_image[image .< threshold].=0;
    return convert.(Bool,binary_image)
end



"""
Making a mask with 1/NaN values of image

# Examples
    array_with_nan = mask_array_nan(rand(10,10), 0.5)
"""
function mask_array_nan(image::Matrix{T}, threshold::Real = 0.5) where T<:Real
    mask_image = similar(image,T)
    mask_image[image .> threshold].=1;
    mask_image[image .< threshold].=NaN;
    return mask_image
end





""""
Find center locations of objects in a binary image.

# Example
    object_centers = object_locations(binary_array)
"""
function object_locations(image::Matrix{T}) where T <: Real
    #objects using using label components.
    binary_array = copy(image)
    if T!=Float64
        binary_array = convert.(Float64,binary_array)
    end
    objects = Images.label_components(binary_array,bkg = trues(5,5));
    #finding the center x and y coordinate for each object.
    unique_objects = unique(objects)[2:length(unique(objects))] #not counting background.
    x_coordinate = [round(Int64,Statistics.mean(first.(Tuple.(findall(x->x==j, objects))))) for j in unique_objects]
    y_coordinate = [round(Int64,Statistics.mean(last.(Tuple.(findall(x->x==j, objects))))) for j in unique_objects]
    object_center = [[x_coordinate[i],y_coordinate[i]] for i in 1:1:length(y_coordinate)]
    binary_array = nothing
    return object_center
end





"""
Extracting a subset from an image. The subset will be extraxted from the image row/column defined by coordinate and size subset_size.

# Input
    image: The image array
    coordinate::Vector{Int64}. Center coordinate of subset, in image geometry.
    subset_size::Vector{Int64}=[75,75]. Size of the subset.

# Output
    subset::Array{Float64, 3}. The three dimensional subset [rows,columns,dimensions.] with dimension=1 for an input 2D array.
"""
function get_subset(image::Matrix{T} where T<:Real, coordinate::Vector{P}, subset_size::Vector{P} = [75,75]) where P<:Integer
    half_window_row = round(Int64,(subset_size[1]-1)/2);
    half_window_column = round(Int64,(subset_size[2]-1)/2);
    subset = image[coordinate[1]-half_window_row:coordinate[1]+half_window_row,coordinate[2]-half_window_column:coordinate[2]+half_window_column,:];
    if size(subset)[3]==1
        subset = dropdims(subset;dims=3)
    end
    return subset
end






"""
Convolution function copied from Yosi Pramajaya. Credits goes to him. In his blogpost, he showed this implementation was faster than many others..
See https://towardsdatascience.com/understanding-convolution-by-implementing-in-julia-3ed744e2e933

dont want to have too many packages. I therefore wont use Convolution pkg.

# Input
    input::Matrix{Float64}. The input image,
    filter::Matrix{Float64}. The  filter/kernel to convolve
    stride::Int64 = 1. Stride of the convolution.
    padding::String = "valid". If padding is used ["valid" or "same"]

# Output
    result::Matrix{Float64}. convolved image.

# Example
    #define a filter.
    average_pool_filter = filters.meanFilter([2,2])
    #perform convolution.
    image = operations.conv2d(image, average_pool_filter,2, "same")

"""
function conv2d(input::Matrix{T} where T<:Real, filter::Matrix{P} where P<: Real, stride::Integer = 1, padding::String = "valid")
    input_r, input_c = size(input)
    filter_r, filter_c = size(filter)

    if padding == "same"
        pad_r = (filter_r - 1) ÷ 2 # Integer division.
        pad_c = (filter_c - 1) ÷ 2 # Needed because of Type-stability feature of Julia

        input_padded = zeros(input_r+(2*pad_r), input_c+(2*pad_c))
        for i in 1:input_r, j in 1:input_c
            input_padded[i+pad_r, j+pad_c] = input[i, j]
        end
        input = input_padded
        input_r, input_c = size(input)
    elseif padding == "valid"
        # We don't need to do anything here
    else
        throw(DomainError(padding, "Invalid padding value"))
    end

    result = zeros((input_r-filter_r) ÷ stride + 1, (input_c-filter_c) ÷ stride + 1)
    result_r, result_c = size(result)

    ir = 1
    ic = 1
    sum = 0
    for i in 1:result_r
        for j in 1:result_c
            for k in 1:filter_r
                for l in 1:filter_c
                    result[i,j] += input[ir+k-1,ic+l-1]*filter[k,l]
                    sum = sum+input[ir+k-1,ic+l-1]*filter[k,l]
                end
            end
            ic += stride
        end
        ir += stride
        ic = 1 # Return back to 1 after finish looping over column
    end
    return result
end



# credit https://github.com/aamini/FastConv.jl
# direct version (do not check if threshold is satisfied)
@generated function fastconv(E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote

        retsize = [size(E)...] + [size(k)...] .- 1
        retsize = tuple(retsize...)
        ret = zeros(T, retsize)

        convn!(ret,E,k)
        return ret

    end
end

# credit https://github.com/aamini/FastConv.jl
# in place helper operation to speedup memory allocations
@generated function convn!(out::Array{T}, E::Array{T,N}, k::Array{T,N}) where {T,N}
    quote
        @inbounds begin
            @nloops $N x E begin
                @nloops $N i k begin
                    (@nref $N out d->(x_d + i_d - 1)) += (@nref $N E x) * (@nref $N k i)
                end
            end
        end
        return out
    end
end
