_G.engine = require("love")

require("gamecontrol")
require("utils")

function engine.load()
    _G.GameControl = GameControl.LoadGameControl(35) --Tile size determinating screen and elements sizes
    _G.Utils = Utils

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#GameControl.grid.TILES*GameControl.grid.tilePX - (GameControl.grid.tilePX*4),
    #GameControl.grid.TILES[1]*GameControl.grid.tilePX - GameControl.grid.tilePX, {display = 2, fullscreen=false, centered=true})

    Utils.sleeptTime = engine.timer.getTime()
end

function engine.update(dt)
    Utils:updateActions()
    GameControl:update(dt)
    Utils:updateInput()

end


function engine.draw()
    GameControl:draw()
    engine.graphics.setColor(1,1,1)
    engine.graphics.print(tostring(engine.timer.getFPS()), 25, 25, 0, 2, 2)
end

--TODO
-- Refactor with Utils.doAfter
--BUGS
-- Spontaneous invalid tile (ghost) grid fetch (possible corrected as for checking walls when fliping direction on state change)
-- pacman bugs in tunnel (possible lack of frames)