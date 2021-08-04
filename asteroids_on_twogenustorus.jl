using Colors
using LinearAlgebra

game_include("src/twogenustorus_gamesetup.jl")

# Define Player Ship
global can_shoot = true
function reset_can_shoot()
    global can_shoot
    can_shoot = true
    return nothing
end

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
    capped_velocity_magnitude = min(velocity_magnitude, 300)
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
    capped_velocity_magnitude = min(velocity_magnitude, 500)
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

# Define Bullet
mutable struct Bullet
    actor::Circle
    velocity::Array
end

draw(bullet::Bullet) = draw(bullet.actor, colorant"white")

function update_position!(obj::Bullet, dt)
    x, y = obj.actor.x, obj.actor.y

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
set_position!(bullet::Bullet, x, y) = ((bullet.actor.x, bullet.actor.y) = (x, y))

function delete_this_particular_bullet(b)
    global bullets
    deleteat!(bullets, findall(==(b), bullets))
    return nothing
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

function reset()
    global player, asteroids, bullets
    # Instantiate a global player ship
    player = Player(Actor("player.png"), [0, 0], 0)
    set_position!(player, 225, 225)

    # Instantiate asteroids
    asteroids = Asteroid[init_random_asteroid() for _ in 1:15]

    # clear bullet array
    bullets = Bullet[]
end

reset()

function draw(g::Game)
    clear()

    for asteroid in asteroids
        draw(asteroid)
    end

    for bullet in bullets
        draw(bullet)
    end

    draw(player)

    nonarena_draw()
end

function update(g::Game, dt)
    # Player acceleration
    # Screen top is more negative in y axis
    angle_deg = player_angle(player) # [Degrees]
    angle_rad = angle_deg / 360.0 * 2 * pi
    acceleration_vector = 700.0 .* [cos(angle_rad), sin(angle_rad)]
    g.keyboard.UP && accelerate!(player, acceleration_vector, dt)
    g.keyboard.DOWN && accelerate!(player, -0.5*acceleration_vector, dt)
    g.keyboard.LEFT && angular_accelerate!(player, -1000, dt)
    g.keyboard.RIGHT && angular_accelerate!(player, 1000, dt)

    !(g.keyboard.LEFT) && !(g.keyboard.RIGHT) && angular_accelerate!(player, -1 * sign(player.angular_velocity) * 800, dt)

    # Player position and angle update
    update_position!(player, dt)
    update_angle!(player, dt)

    # Update asteroids
    for asteroid in asteroids
        update_position!(asteroid, dt)
        update_angle!(asteroid, dt)
    end

    if g.keyboard.SPACE && can_shoot
        global can_shoot
        player_direction = [cos(angle_rad), sin(angle_rad)]
        bullet_speed = 500.0 * player_direction + player.velocity
        new_bullet = Bullet(Circle(player.actor.pos[1], player.actor.pos[2], 5), bullet_speed)
        set_position!(new_bullet, player.actor.pos[1], player.actor.pos[2])
        push!(bullets, new_bullet)
        can_shoot = false
        schedule_once(reset_can_shoot, 0.1)
        schedule_once(() -> delete_this_particular_bullet(new_bullet), 2)
    end

    #update bullets
    if length(bullets) > 0
        for bullet in bullets
            update_position!(bullet, dt)
        end
    end

    for asteroid in asteroids
        if collide(asteroid.actor, player.actor)
            reset()
            continue
        end

        for bullet in bullets
            if collide(asteroid.actor, bullet.actor)
                deleteat!(bullets, findall(==(bullet), bullets))
                deleteat!(asteroids, findall(==(asteroid), asteroids))
            end
        end

    end

end
