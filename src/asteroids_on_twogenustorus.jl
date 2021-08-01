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



function draw(g::Game)
    clear()

    nonarena_draw()
end

function nonarena_draw()
    for nonarena in non_arenas
        draw(nonarena.geometry, NON_ARENA_COLOR, fill=true)
    end
end

function update(g::Game)

end