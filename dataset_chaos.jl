using Images, FileIO, Colors, FixedPointNumbers, MLDatasets, Statistics
# using WAV

CANVAS_SIZE = 1000

function triangular_step(current_pos)
    random_number = rand() 
    if random_number < 1/3
        output = ([0, 0] + current_pos)/2
    elseif random_number < 2/3
        output = ([1, 0] + current_pos)/2
    else
        output = ([0.5, (3^0.5)/2] + current_pos)/2
    end
    output
end

function triangular_chaos(num_points)
    output = zeros(num_points, 2)
    output[1,:] = [0.5, 0.5]
    for i in 2:num_points
        output[i,:] = triangular_step(output[i-1,:])
    end
    output
end

function square_step(current_pos)
    random_number = rand() 
    if random_number < 1/4
        output = ([0, 0] + current_pos)/2
    elseif random_number < 1/2
        output = ([1, 0] + current_pos)/2
    elseif random_number < 3/4
        output = ([0, 1] + current_pos)/2
    else
        output = ([1, 1] + current_pos)/2
    end
    output
end

function square_chaos(num_points)
    output = zeros(num_points, 2)
    output[1,:] = [0.5, 0.5]
    for i in 2:num_points
        output[i,:] = square_step(output[i-1,:])
    end
    output
end


function circular_step(current_pos, step)
    theta = 2*pi*step
    output = ([(1+cos(theta))/2, (1+sin(theta))/2] + current_pos)/2
    output
end

function circular_chaos(input)
    num_points = length(input) + 1
    output = zeros(num_points, 2)
    output[1,:] = [0.5, 0.5]
    for i in 2:num_points
        output[i,:] = circular_step(output[i-1,:], input[i-1])
    end
    output
end

function square_driven_step(current_pos, step)
    if step < 1/4
        output = ([0, 0] + current_pos)/2
    elseif step < 1/2
        output = ([1, 0] + current_pos)/2
    elseif step < 3/4
        output = ([0, 1] + current_pos)/2
    else
        output = ([1, 1] + current_pos)/2
    end
    output
end

function square_driven_chaos(input)
    num_points = length(input) + 1
    output = zeros(num_points, 2)
    output[1,:] = [0.5, 0.5]
    for i in 2:num_points
        output[i,:] = square_driven_step(output[i-1,:], input[i-1])
    end
    output
end

function plot_data(data, canvas_size, alpha)
    num_points = size(data)[1]
    canvas = zeros(canvas_size, canvas_size)
    @. data = (data * canvas_size) + 1
    data = floor.(Int, data)
    @. data = canvas_size - data + 1
    for i in 1:num_points
        canvas[data[i,2], data[i,1]] += alpha
    end
    canvas
end

function pixel_color_transform(pixel)
    output = zeros(3)
    #white to blue colormap
    if pixel <= 0
        output = RGB(1.,1.,1.)
    elseif pixel <=0.5
        output = RGB(1-2pixel,1-2pixel,1)
    else
        output = RGB(0.,0.,1.)
    end
    output
end

function render_img(data, canvas_size, alpha)
    data = plot_data(data, canvas_size, alpha)
    x,y = size(data)
    canvas = zeros(RGB,x,y)
    for i in 1:x
        for j in 1:y
            canvas[i,j] = pixel_color_transform(data[i,j])
        end
    end
    canvas
end

function sierpinski_main(num_points, canvas_size, alpha)
    data = triangular_chaos(num_points)
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save("triangle.jpg", img);
end

function square_main(num_points, canvas_size, alpha)
    data = square_chaos(num_points)
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save("square.jpg", img);
end

function circular_main(num_points, canvas_size, alpha)
    data = circular_chaos(rand(num_points))
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save("circular.jpg", img);
end


function munge_dataset(images)
    if length(size(images))==4
        image_data = mean(images, dims=3)
    else
        image_data = images
    end
    num_samples = size(image_data)[end]
    image_data = reshape(image_data, :, num_samples)
    image_data = reshape(image_data, :)
    image_data = image_data + (rand(Float64, size(image_data))/100000)
    quartiles = quantile(image_data, [0.25,0.5,0.75,1.0])
    output = ones(size(image_data))
    @. output[image_data < quartiles[3]] = 0.74
    @. output[image_data < quartiles[2]] = 0.49
    @. output[image_data < quartiles[1]] = 0.24
    output
end

function cifar_10_square(canvas_size, alpha)
    train_x, _ = CIFAR10.traindata()
    chaos_in = munge_dataset(train_x)
    data = square_driven_chaos(chaos_in)
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save(string("cifar_10.jpg"), img)
end

function mnist_square(canvas_size, alpha)
    train_x, _ = MNIST.traindata()
    chaos_in = munge_dataset(train_x)
    data = square_driven_chaos(chaos_in)
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save(string("mnist.jpg"), img)
end

function fashion_mnist_square(canvas_size, alpha)
    train_x, _ = FashionMNIST.traindata()
    chaos_in = munge_dataset(train_x)
    data = square_driven_chaos(chaos_in)
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save(string("fashion_mnist.jpg"), img)
end

function cifar_100_square(canvas_size, alpha)
    train_x, _ = CIFAR100.traindata()
    chaos_in = munge_dataset(train_x)
    data = square_driven_chaos(chaos_in)
    @. data[data==1] = 0.99999
    img = render_img(data, canvas_size, alpha)
    save(string("cifar_100.jpg"), img)
end

# function import_wav(filepath)
    # import_data = wavread(filepath)[1]
    # import_data = mean(import_data, dims=2)
    # import_data = reshape(import_data, :)
    # import_data= import_data + (rand(Float64, size(import_data))/10000000)
    # quartiles = quantile(import_data, [0.25,0.5,0.75,1.0])
    # output = ones(size(import_data))
    # @. output[import_data < quartiles[3]] = 0.74
    # @. output[import_data < quartiles[2]] = 0.49
    # @. output[import_data < quartiles[1]] = 0.24
    # output
# end

# function wav_chaos(filename, canvas_size, alpha)
    # chaos_in = import_wav(string(filename,".wav"))
    # data = square_driven_chaos(chaos_in)
    # @. data[data==1] = 0.99999
    # img = render_img(data, canvas_size, alpha)
    # save(string(filename,"_chaos.jpg"), img)
# end


sierpinski_main(100000000, 500, 0.001)
square_main(100000000, CANVAS_SIZE, 0.001)
cifar_10_square(CANVAS_SIZE,0.1)
mnist_square(CANVAS_SIZE,0.01)
# cifar_100_square(CANVAS_SIZE,0.1)
fashion_mnist_square(CANVAS_SIZE,0.1)
