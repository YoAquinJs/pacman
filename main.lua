_G.engine = require("love")

require("gamecontrol")
require("utils")

function engine.load()
    _G.GameControl = GameControl.LoadGameControl() --Tile size determinating screen and elements sizes
    GameControl.currentLevelInfo.level = -1
    _G.Utils = Utils
    Utils:start()

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#GameControl.grid.TILES*GameControl.grid.tilePX - (GameControl.grid.tilePX*4),
    #GameControl.grid.TILES[1]*GameControl.grid.tilePX - GameControl.grid.tilePX, {display = 2, fullscreen=GameControl.isFullscreen, centered=true})

    Utils.sleeptTime = engine.timer.getTime()
    --print(love.system.getOS())
end

function engine.update(dt)
    Utils:update()
    GameControl:update(dt, Utils:getTjime())
    Utils.input.start = false
end

--function engine.keyreleased(key)
--    Utils.input.start = key == "space"
--end

function engine.draw()
    GameControl:draw(Utils:getTime())
    --engine.graphics.print(tostring(engine.timer.getFPS()), 25, 25, 0, 2, 2)
end

function engine.quit()
    if GameControl.tag ~= nil then
        table.insert(GameControl.highscores, {GameControl.tag, GameControl.score})
        GameControl:serializeScores()
    end
    Utils.inputHandler:close()
end

--TODO gpio input