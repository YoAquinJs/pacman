_G.engine = require("love")

require("gamecontrol")
require("input")

function engine.load() --On game laod
    _G.GameControl = GameControl.LoadGameControl()
    _G.Input = Input.getInput()

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#GameControl.grid.TILES*GameControl.grid.tilePX - (GameControl.grid.tilePX*4),
    #GameControl.grid.TILES[1]*GameControl.grid.tilePX - GameControl.grid.tilePX, {display = 2, fullscreen=false, centered=true})

    --GameControl:startLevel(1)
end

local i = 0
function engine.update(dt) --Per Frame Logic
   -- engine.timer.sleep((1/60))-- Set to aprox 100fps

    GameControl:update(dt)
    Input:update()
 end


function engine.draw() --Per Frame Graphics
    GameControl:draw()
end

-- TODO
-- Correct pacman movement
-- wall sprite selection with wall sprites
-- Sound
-- REFACTOR Dificultity settings
--BUGS