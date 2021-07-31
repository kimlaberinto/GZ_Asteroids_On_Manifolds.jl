using Colors

WIDTH = 900
HEIGHT = 900
BACKGROUND = colorant"grey26"


struct ArenaRect
    geometry::Rect
    arena_color
end

arena_left = ArenaRect(Rect(50, 50, 400, 800), colorant"black")
arena_right =  ArenaRect(Rect(450, 450, 400, 400), colorant"black")

arenas = ArenaRect[arena_left, arena_right]

function draw(g::Game)
    clear()
    for arena in arenas
        draw(arena.geometry, arena.arena_color, fill=true)
    end
end


function update(g::Game)

end