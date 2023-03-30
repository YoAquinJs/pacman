_G.engine = require("love")

require("gamecontrol")
require("input")

function engine.load()
    _G.GameControl = GameControl.LoadGameControl(16*2)
    _G.Input = Input.getInput()

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#GameControl.grid.TILES*GameControl.grid.tilePX - (GameControl.grid.tilePX*4),
    #GameControl.grid.TILES[1]*GameControl.grid.tilePX - GameControl.grid.tilePX+100, {display = 2, fullscreen=false, centered=true})

    --GameControl:startLevel(10)
end

local i = 0
function engine.update(dt)
   -- engine.timer.sleep((1/60))-- Set to aprox 100fps

    GameControl:update(dt)
    Input:update()
 end


function engine.draw()
    GameControl:draw()
end

--TODO
-- Sound
-- blink counters
-- REFACTOR Dificultity settings (google table)
-- Score popup when gain points ghost eat(pause time .5seconds), prop
-- pretty start screen (optional, mostly done)
--BUGS