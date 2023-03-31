_G.engine = require("love")

require("gamecontrol")
require("input")

function engine.load()
    _G.GameControl = GameControl.LoadGameControl(20) --Tile size determinating screen and elements sizes
    _G.Input = Input.getInput()

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#GameControl.grid.TILES*GameControl.grid.tilePX - (GameControl.grid.tilePX*4),
    #GameControl.grid.TILES[1]*GameControl.grid.tilePX - GameControl.grid.tilePX, {display = 2, fullscreen=false, centered=true})

    GameControl:startLevel(1)
end

function engine.update(dt)
    GameControl:update(dt)
    Input:update()
 end


function engine.draw()
    GameControl:draw()
end

--TODO
-- Sound
--BUGS