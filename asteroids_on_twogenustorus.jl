using Colors
using LinearAlgebra

game_include("src/twogenustorus_gamesetup.jl")

# Define Player Ship
mutable struct Player
    actor::Actor
    velocity::Array
    angular_velocity::Float64
end

player_angle(player::Player) = player.actor.angle
draw(player::Player) = draw(player.actor)
function accelerate!(player::Player, acceleration, dt)
    player.velocity += acceleration.*dt
    velocity_magnitude = norm(player.velocity)
    capped_velocity_magnitude = min(velocity_magnitude, 1000)
    player.velocity = normalize(player.velocity) * capped_velocity_magnitude
    return nothing
end

# Define Asteroids
mutable struct Asteroid
    actor::Actor
    velocity::Array
    angular_velocity::Float64
end

draw(asteroid::Asteroid) = draw(asteroid.actor)
function accelerate!(asteroid::Asteroid, acceleration, dt)
    asteroid.velocity += acceleration.*dt
    velocity_magnitude = norm(asteroid.velocity)
    capped_velocity_magnitude = min(velocity_magnitude, 300)
    asteroid.velocity = normalize(asteroid.velocity) * capped_velocity_magnitude
    return nothing
end

function init_random_asteroid()
    size = rand(["small"])
    image_index = rand(1:5)

    image_file = "$(size)_asteroids_$(image_index).png"

    random_angle = 2*pi*rand()
    random_speed = 25 + 100*rand()
    random_velocity = random_speed * [cos(random_angle), sin(random_angle)]

    random_angular_velocity = 100 + 100*rand()

    random_position = (50 + 800*rand(), 50 + 800*rand())

    new_asteroid = Asteroid(Actor(image_file), random_velocity, random_angular_velocity)
    set_position!(new_asteroid, random_position[1], random_position[2])

    return new_asteroid
end

# Generic functions
set_position!(obj, x, y) = (obj.actor.pos = (x, y))

angular_accelerate!(obj, angular_acceleration, dt) = (obj.angular_velocity += angular_acceleration * dt)

function update_position!(obj, dt)
    x, y = obj.actor.pos

    v = obj.velocity
    displacement = v * dt

    dx = displacement[1]
    dy = displacement[2]

    # Apply velocity
    new_x, new_y = (x + dx, y + dy)

    # Wrap around if necessary
    new_x, new_y = two_genus_wrap_position(new_x, new_y)

    # Update
    set_position!(obj, new_x, new_y)
    return nothing
end

update_angle!(obj, dt) = obj.actor.angle += obj.angular_velocity * dt


# Instantiate a global player ship
player = Player(Actor("player.png"), [0, 0], 0)
set_position!(player, 225, 225)

# Instantiate asteroids
asteroids = Asteroid[init_random_asteroid() for _ in 1:5]

function draw(g::Game)
    clear()

    for asteroid in asteroids
        draw(asteroid)
    end

    draw(player)

    nonarena_draw()
end

function update(g::Game, dt)

    # Player acceleration
    # Screen top is more negative in y axis
    angle_deg = player_angle(player) # [Degrees]
    angle_rad = angle_deg / 360 * 2 * pi
    acceleration_vector = 200 .* [cos(angle_rad), sin(angle_rad)]
    g.keyboard.UP && accelerate!(player, acceleration_vector, dt)
    g.keyboard.LEFT && angular_accelerate!(player, -600, dt)
    g.keyboard.RIGHT && angular_accelerate!(player, 600, dt)

    !(g.keyboard.LEFT) && !(g.keyboard.RIGHT) && angular_accelerate!(player, -1 * sign(player.angular_velocity) * 300, dt)

    # Player position and angle update
    update_position!(player, dt)
    update_angle!(player, dt)

    # Update asteroids
    for asteroid in asteroids
        update_position!(asteroid, dt)
        update_angle!(asteroid, dt)
    end

end
