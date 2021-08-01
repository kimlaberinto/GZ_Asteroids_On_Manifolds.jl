module MakePlayerAssets

using Luxor
using Random

export make_player

function lightweight_rand_uniform(a, b)
    return (b-a)*rand() + a
end

function make_player(filename)
    PLAYER_WIDTH = 30
    PLAYER_LENGTH = 50
    Drawing(PLAYER_LENGTH, PLAYER_WIDTH, filename) 

    # Player is facing east
    corners_of_ship = Point[Point(0, 0),
                            Point(PLAYER_LENGTH, PLAYER_WIDTH/2),
                            Point(0, PLAYER_WIDTH)]


    setcolor("white")
    for (index, corner) in enumerate(corners_of_ship)
        if index > 1
            prev_index = index - 1
            prev_corner = corners_of_ship[prev_index]
            line(prev_corner, corner, :stroke)
        end
    end

    finish()

    return nothing
end

end
