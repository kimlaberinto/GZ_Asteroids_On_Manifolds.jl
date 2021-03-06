WIDTH = 900
HEIGHT = 900
BACKGROUND = colorant"black"

#Custom constants
NON_ARENA_COLOR = colorant"grey26"

# Define Non-Arenas
struct NonArenaRect
    geometry::Rect
end

nonarena_N = NonArenaRect(Rect(0, 0, 900, 50))
nonarena_W = NonArenaRect(Rect(0, 0, 50, 900))
nonarena_S = NonArenaRect(Rect(0, 850, 900, 50))
nonarena_E = NonArenaRect(Rect(850, 0, 50, 900))
nonarena_mid = NonArenaRect(Rect(450, 50, 400, 400))

non_arenas = NonArenaRect[nonarena_N, nonarena_W, nonarena_S, nonarena_E, nonarena_mid]


# return true when point is in the arena,
# i.e. none of the non-arena geometries are colliding with this
function position_in_arena(x, y)
    x, y = convert(Int64, round(x)), convert(Int64, round(y))

    touching_one_of_non_arena = false
    for nonarena in non_arenas
        touching_one_of_non_arena |= collide(nonarena.geometry, x, y)
    end
    return !touching_one_of_non_arena
end

# TODO, not working, just test
function two_genus_wrap_position(x, y)

    current_x, current_y = x, y

    for _ in 1:2
        if current_y < 450 && current_x < 50
            current_x = 450
        elseif current_y < 450 && current_x > 450 && current_y < (-current_x + 900)
            current_x = 50
        elseif current_y > 850 && current_x > 450
            current_y = 450
        elseif current_y < 450 && current_x > 450 && current_y > (-current_x + 900) 
            current_y = 850
        elseif current_y < 50
            current_y = 850
        elseif current_y > 850
            current_y = 50
        elseif current_x < 50
            current_x = 850
        elseif current_x > 850
            current_x = 50
        end
    end 

    new_x, new_y = current_x, current_y

    return new_x, new_y
end

function nonarena_draw()
    for nonarena in non_arenas
        draw(nonarena.geometry, NON_ARENA_COLOR, fill=true)
    end
end
