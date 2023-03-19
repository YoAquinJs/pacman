_G.engine = require("love")

require("gamecontrol")
require("grid")
require("input")
require("font")

function engine.load() --On game laod
    _G.Input = Input.getInput()
    _G.GameControl = GameControl.LoadGameControl(Input)
    _G.Grid = Grid.LoadGrid(GameControl)
    _G.Font = Font
    GameControl.grid = Grid

    engine.graphics.setBackgroundColor(0,0,0) --window Background Color
    engine.window.setMode(#Grid.TILES*Grid.tilePX - (Grid.tilePX*4), #Grid.TILES[1]*Grid.tilePX - Grid.tilePX, {display = 2, fullscreen=false, centered=true})

    GameControl:startLevel(1)
end

local i = 0
function engine.update(dt) --Per Frame Logic
   -- engine.timer.sleep((1/60))-- Set to aprox 100fps

    GameControl:update(dt)
    Input:update()
 end


function engine.draw() --Per Frame Graphics
    GameControl:draw()
    if GameControl.currentLevel > 0  then
        Grid:draw()
    end
end

-- TODO
-- Blinkin when losing and when frightened mode is close to finish
-- Gamecontrol for selecting level and play time runs
-- Start Screen
-- Sound
-- Correct pacman movement
-- wall sprite selection
-- Pacman eat
