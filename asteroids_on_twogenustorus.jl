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
    angular_velocity::Float64
end

player_angle(player::Player) = player.actor.angle
set_player_position!(x, y) = (player.actor.pos = (x, y))
draw(player::Player) = draw(player.actor)
accelerate_player!(acceleration, dt) = (player.velocity += acceleration.*dt)
angular_accelerate_player!(angular_acceleration, dt) = (player.angular_velocity += angular_acceleration * dt)

function update_player_position!(dt)
    x, y = player.actor.pos 

    v = player.velocity
    displacement = v * dt

    dx = displacement[1]
    dy = displacement[2]

    # Apply velocity
    new_x, new_y = (x + dx, y + dy)

    # Wrap around if necessary
    new_x, new_y = two_genus_wrap_position(new_x, new_y)

    # Update
    set_player_position!(new_x, new_y)
    return nothing
end

update_player_angle!(dt) = player.actor.angle += player.angular_velocity * dt

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

# Instantiate a global player ship
player = Player(Actor("player.png"), [0, 0], 0)
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
    angle_deg = player_angle(player) # [Degrees]
    angle_rad = angle_deg / 360 * 2 * pi
    acceleration_vector = 200 .* [cos(angle_rad), sin(angle_rad)]
    g.keyboard.UP && accelerate_player!(acceleration_vector, dt)
    g.keyboard.LEFT && angular_accelerate_player!(-600, dt)
    g.keyboard.RIGHT && angular_accelerate_player!(600, dt)

    !(g.keyboard.LEFT) && !(g.keyboard.RIGHT) && angular_accelerate_player!(-1 * sign(player.angular_velocity) * 300, dt)

    # Player position and angle update
    update_player_position!(dt)
    update_player_angle!(dt)

end