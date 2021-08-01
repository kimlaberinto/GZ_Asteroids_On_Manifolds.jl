using Colors

game_include("src/twogenustorus_gamesetup.jl")

# Define Player Ship
mutable struct Player
    actor::Actor
    velocity::Array
    angular_velocity::Float64
end

player_angle(player::Player) = player.actor.angle
set_player_position!(x, y) = (player.actor.pos = (x, y))
draw(player::Player) = draw(player.actor)
function accelerate_player!(acceleration, dt)
    player.velocity += acceleration.*dt
    velocity_magnitude = norm(player.velocity)
    capped_velocity_magnitude = min(velocity_magnitude, 600)
    player.velocity = normalize(player.velocity) * capped_velocity_magnitude
    return nothing
end
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
# Instantiate a global player ship
player = Player(Actor("player.png"), [0, 0], 0)
set_player_position!(225, 225)

function draw(g::Game)
    clear()

    draw(player)

    nonarena_draw()
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