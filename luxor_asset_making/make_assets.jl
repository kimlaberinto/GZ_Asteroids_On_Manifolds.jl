include("MakeAsteroidsAssets.jl")
using .MakeAsteroidsAssets
MakeAsteroidsAssets.make_big_asteroids("images/big_asteroids.png")
MakeAsteroidsAssets.make_small_asteroids("images/small_asteroids.png")

include("MakePlayerAssets.jl")
using .MakePlayerAssets
MakePlayerAssets.make_player("images/player.png")