module MakeAsteroidsAssets

using Luxor
using Random
using Distributions

export make_big_asteroids

function lightweight_rand_uniform(a, b)
    return (b-a)*rand() + a
end

function make_asteroid(filename, base_radius; size=(150, 150))
    Drawing(size[1], size[2], filename)
    origin()
    
    # Angles
    angles = range(0, 2*pi, length=10)
    angles = angles[1:end-1] # remove the repeated point

    # Add jitter to angles
    angles += [lightweight_rand_uniform(-(2*pi/4 * 0.1), (2*pi/4 * 0.1)) for _ in 1:length(angles)]

    # Make corners of the asteroid
    corners_of_asteroid = Point[]
    for angle in angles
        relative_radial_distance = lightweight_rand_uniform(-base_radius*0.25, base_radius*0.25) #TODO

        absolute_radial_distance = base_radius + relative_radial_distance

        # Assumes origin is the center of this circle
        x_coord = absolute_radial_distance * cos(angle)
        y_coord = absolute_radial_distance * sin(angle)
        push!(corners_of_asteroid, Point(x_coord, y_coord))
    end

    # Draw the corners
    setcolor("white")
    for (index, corner) in enumerate(corners_of_asteroid)
        prev_corner_index = index-1
        prev_corner_index == 0 && (prev_corner_index = length(corners_of_asteroid))
        prev_corner = corners_of_asteroid[prev_corner_index]
        line(prev_corner, corner, :stroke)
    end

    finish()

    return nothing
end

function make_big_asteroids(filename; num_of_assets=5)
    filename_no_extension, extension = Base.Filesystem.splitext(filename)

    for asset_index in 1:num_of_assets
        current_filename = filename_no_extension * "_$(asset_index)" * extension
        make_asteroid(current_filename, 60)
    end

    return nothing
end

function make_small_asteroids(filename; num_of_assets=5)
    filename_no_extension, extension = Base.Filesystem.splitext(filename)

    for asset_index in 1:num_of_assets
        current_filename = filename_no_extension * "_$(asset_index)" * extension
        make_asteroid(current_filename, 20; size=(75, 75))
    end

    return nothing
end

end
