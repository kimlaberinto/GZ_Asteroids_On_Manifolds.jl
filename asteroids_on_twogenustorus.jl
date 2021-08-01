using Colors

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

# Define Player Ship
mutable struct Player
    actor::Actor
    velocity::Array
end

set_player_position!(x::Int, y::Int) = (player.actor.pos = (x, y))
draw(player::Player) = draw(player.actor)
accelerate_player!(acceleration, dt) = (player.velocity += acceleration.*dt)

function update_player_position!(dt)
    x, y = player.actor.pos 

    v = player.velocity
    displacement = v * dt

    dx = displacement[1]
    dy = displacement[2]

    # Apply velocity, but rounded
    new_x, new_y = round.((x + dx, y + dy))
    
    new_x, new_y = convert(Int64, new_x), convert(Int64, new_y)

    # Wrap around if necessary
    new_x, new_y = two_genus_wrap_position(new_x, new_y)

    # Update
    set_player_position!(new_x, new_y)
    return nothing
end

# return true when point is in the arena,
# i.e. none of the non-arena geometries are colliding with this
function position_in_arena(x::Int, y::Int)
    touching_one_of_non_arena = false
    for nonarena in non_arenas
        touching_one_of_non_arena |= collide(nonarena.geometry, x, y)
    end
    return touching_one_of_non_arena
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
    #@assert position_in_arena(new_x, new_y)

    return new_x, new_y
end

# Instantiate a global player ship
player = Player(Actor("player.png"), [0, 0])
set_player_position!(225, 225)

function draw(g::Game)
    clear()

    draw(player)

    nonarena_draw()
end

function nonarena_draw()
    for nonarena in non_arenas
        draw(nonarena.geometry, NON_ARENA_COLOR, fill=true)
    end
end

function update(g::Game, dt)

    # Player acceleration
    # Screen top is more negative in y axis
    g.keyboard.DOWN && accelerate_player!([0, 500], dt)
    g.keyboard.UP && accelerate_player!([0, -500], dt)
    g.keyboard.LEFT && accelerate_player!([-500, 0], dt)
    g.keyboard.RIGHT && accelerate_player!([500, 0], dt)

    # Player position update
    update_player_position!(dt)

end