require("pacman")
require("ghosts")
require("grid")
require("font")

_G.Font = Font
GameControl = {}

GameControl.LoadGameControl = function (tilePX)
    local gameControl = {
        grid = nil,
        pacman = nil,
        ghosts = nil,
        states = nil,
        highscores = {},

        savingsFile = "savings/highscores",
        startLifes=3,
        maxVelocity = 9,
        eatenVelocity = 12,
        maxHighscores = 5,
        propMaxTime=10,
        props = {{"cherry", 100},{"strawberry", 300},{"orange", 500},{"apple", 700},{"melon", 1000},{"galaxian", 2000},{"bell", 3000},{"key", 5000}},

        levelCounterCoords=nil,
        lifesCounterCoords=nil,
        highScoreLabelCoords=nil,
        highScoreValueCoords=nil,
        nameTagCoords=nil,
        scoreCounterCoords=nil,
        gameOverLabel=nil,

        nameTag={1, {65, 65, 65, 65, 65}, 0},
        popups={},
        lifes=2,
        generalState=nil,
        isFrightened=false,--Define frightened start time or false for no frightened mode
        score=0,
        currentLevel=-1,
        currentLevelInfo={shifts={},phase=1,startTimeOffset=0,data={}},
        deathTime=0,
        winTime=0,
        propSpawnTime=0,
        propLastSpawnTime=0,
        levels = {
            modeShifts = {-- 0:SCATTER 1:CHASE
                {untilLevel = 1, phases = {{0, 7}, {1, 20}, {0, 7}, {1, 20}, {0, 5}, {1, 20}, {0, 5}, {1, 1}}},
                {untilLevel = 4, phases = {{0, 7}, {1, 20}, {0, 7}, {1, 20}, {0, 5}, {1, 1}}},
                {untilLevel = -1,phases = {{0, 5}, {1, 20}, {0, 5}, {1, 20}, {0, 5}, {1, 1}}},
            },
            levelData = {
--1           2           3              4          5                6          7           8          9           10                 11                  12               13
--BonusSymbol/PacmanSpeed/PacmanDotSpeed/GhostSpeed/GhostTunnelSpeed/Elroy1Dots/Elroy1Speed/Elroy2Dots/Elroy2Speed/PacmanFrightSpeed/PacmanFrightDotSpeed/GhostFrightSpeed/FrightTime
{ 0,          0.80,       0.71,          0.75,      0.40,             20,       0.80,       10,        0.85,       0.90,             0.79,                0.50,            6}, --  1
{ 2,          0.90,       0.79,          0.85,      0.45,             30,       0.90,       15,        0.95,       0.95,             0.83,                0.55,            5}, --  2
{ 3,          0.90,       0.79,          0.85,      0.45,             40,       0.90,       20,        0.95,       0.95,             0.83,                0.55,            4}, --  3
{ 3,          0.90,       0.79,          0.85,      0.45,             40,       0.90,       20,        0.95,       0.95,             0.83,                0.55,            3}, --  4
{ 4,          1.00,       0.87,          0.95,      0.50,             40,       1.00,       20,        1.05,       1.00,             0.87,                0.60,            2}, --  5
{ 4,          1.00,       0.87,          0.95,      0.50,             50,       1.00,       25,        1.05,       1.00,             0.87,                0.60,            5}, --  6
{ 5,          1.00,       0.87,          0.95,      0.50,             50,       1.00,       25,        1.05,       1.00,             0.87,                0.60,            2}, --  7
{ 5,          1.00,       0.87,          0.95,      0.50,             50,       1.00,       25,        1.05,       1.00,             0.87,                0.60,            2}, --  8
{ 6,          1.00,       0.87,          0.95,      0.50,             60,       1.00,       30,        1.05,       1.00,             0.87,                0.60,            1}, --  9
{ 6,          1.00,       0.87,          0.95,      0.50,             60,       1.00,       30,        1.05,       1.00,             0.87,                0.60,            5}, -- 10
{ 7,          1.00,       0.87,          0.95,      0.50,             60,       1.00,       30,        1.05,       1.00,             0.87,                0.60,            2}, -- 11
{ 7,          1.00,       0.87,          0.95,      0.50,             80,       1.00,       40,        1.05,       1.00,             0.87,                0.60,            1}, -- 12
{ 8,          1.00,       0.87,          0.95,      0.50,             80,       1.00,       40,        1.05,       1.00,             0.87,                0.60,            1}, -- 13
{ 8,          1.00,       0.87,          0.95,      0.50,             80,       1.00,       40,        1.05,       1.00,             0.87,                0.60,            3}, -- 14
{ 8,          1.00,       0.87,          0.95,      0.50,            100,       1.00,       50,        1.05,       1.00,             0.87,                0.60,            1}, -- 15
{ 8,          1.00,       0.87,          0.95,      0.50,            100,       1.00,       50,        1.05,       1.00,             0.87,                0.60,            1}, -- 16
{ 8,          1.00,       0.87,          0.95,      0.50,            100,       1.00,       50,        1.05,        nil,              nil,                 nil,            0}, -- 17
{ 8,          1.00,       0.87,          0.95,      0.50,            100,       1.00,       50,        1.05,       1.00,             0.87,                0.60,            1}, -- 18
{ 8,          1.00,       0.87,          0.95,      0.50,            120,       1.00,       60,        1.05,        nil,              nil,                 nil,            0}, -- 19
{ 8,          1.00,       0.87,          0.95,      0.50,            120,       1.00,       60,        1.05,        nil,              nil,                 nil,            0}, -- 20
{ 8,          0.90,       0.79,          0.95,      0.50,            120,       1.00,       60,        1.05,        nil,              nil,                 nil,            0}, -- 21
            }
        },
        startLevel = function (self, level, died)
            engine.timer.sleep(1)

            if level == 1 and died == false then
                self.score = 0
                self.lifes = self.startLifes
                self.grid:reloadConsumeables()
            else
                if level == self.currentLevel + 1 then
                    self.grid:reloadConsumeables()
                end
            end

            for i=1,#self.levels.modeShifts do
                if level < self.levels.modeShifts[1].untilLevel+1 or self.levels.modeShifts[1].untilLevel==-1 then
                    self.currentLevelInfo.shifts = self.levels.modeShifts[i].phases
                    goto selectedModeShift
                end
            end ::selectedModeShift::

            if level < #self.levels.levelData then
                self.currentLevelInfo.data = self.levels.levelData[level]
            else
                self.currentLevelInfo.data = self.levels.levelData[#self.levels.levelData]
            end
            self.currentLevelInfo.startTimeOffset = engine.timer.getTime()
            self.generalState = self.currentLevelInfo.shifts[1][1]
            self.currentLevelInfo.phase = 1

            self.pacman = Pacman.LoadPacman(self.grid, self)
            local GhostsObjs = Ghosts:LoadGhosts(self.grid, self, self.pacman)
            self.ghosts = GhostsObjs
            self.states = Ghosts.states
            self.pacman.ghosts = GhostsObjs
            self.pacman.states = Ghosts.states
            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].state = self.generalState
            end

            self.prop = 0
            self.grid.mazeColor = {1,1,1}
            self.winTime = 0
            self.propSpawnTime = engine.timer.getTime()
            self.currentLevel = level
        end,
        frightenedMode = function (self)
            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].state = self.states.FRIGHTENED
                self.ghosts[key].nextFrameTime = 0.199
                self.ghosts[key].frightenedColor = "B"
            end

            self.pacman.ghostsEatened = 1
            self.currentLevelInfo.startTimeOffset = self.currentLevelInfo.startTimeOffset + self.currentLevelInfo.data[13]

            self.isFrightened = engine.timer.getTime()
        end,
        serializeScores = function (self)
            local formattedValues = ""
            table.sort(self.highscores, function (k1, k2) return k1[2] > k2[2] end )

            for i, value in ipairs(self.highscores) do
                if i > self.maxHighscores then
                    table.remove(self.highscores, i)
                    goto exitHighscoreSelector
                end

                formattedValues = formattedValues..value[1]..", "..value[2].."\n"
            end::exitHighscoreSelector::

            engine.filesystem.write(self.savingsFile, formattedValues:sub(1, #formattedValues - 1))
        end,
        getNameTag = function (self)
            return string.char(self.nameTag[2][1], self.nameTag[2][2], self.nameTag[2][3], self.nameTag[2][4], self.nameTag[2][5])
        end,
        eatPacman = function (self)
            self.lifes = self.lifes - 1

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].stoped = true
            end
            self.pacman.stoped = true
            self.pacman.dying = true
            engine.timer.sleep(1.5)
            self.pacman.renderSprite = "fill"
            self.pacman.frame = -4
            self.pacman.lastFrameTime = engine.timer.getTime()

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].render = false
            end
            self.prop = 0
        end,
        pacmanDie = function (self)
            if self.lifes == 0 then
                self.deathTime = engine.timer.getTime()
                self.currentLevel = 0
                table.insert(self.highscores, {self:getNameTag(), self.score})
                self:serializeScores()
                return
            end
            self:startLevel(self.currentLevel, true)
        end,
        eatGhost = function (self, key, ghostsEatened)
            self.ghosts[key].state = self.states.EATEN
            self.ghosts[key].nextFrameTime = 0.15
            local obtainedScore = (200 * math.pow(2,ghostsEatened-1))
            self.score = self.score + obtainedScore

            local popupCoords = self.grid:getCenterCoordinates(self.ghosts[key].tile[1], self.ghosts[key].tile[2])
            table.insert(self.popups, {tostring(obtainedScore), popupCoords[1], popupCoords[2] - (self.grid.tilePX/2), {0,1,1}, engine.timer.getTime(), .001, 2,
            done=function ()
                for key, _ in pairs(self.ghosts) do
                    self.ghosts[key].stoped = true
                end
                self.pacman.stoped = true
                engine.timer.sleep(1)
                for key, _ in pairs(self.ghosts) do
                    self.ghosts[key].stoped = false
                end
                self.pacman.stoped = false
                self.pacman.render = true
                self.ghosts[key].render = true
            end})
        end,
        winLevel = function (self)
            engine.timer.sleep(1.5)

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].stoped = true
                self.ghosts[key].render = false
            end
            self.pacman.stoped = true

            engine.timer.sleep(.5)
            self.pacman.render = false
            self.winTime = engine.timer.getTime()
        end
    }

    gameControl.grid =  Grid.LoadGrid(gameControl, tilePX)

    gameControl.update = function (self, dt)
        if self.currentLevel > 0 then
            if self.grid.consumables == 0 then
                if engine.timer.getTime() - self.winTime > 4.5 then
                    engine.timer.sleep(.5)
                    self:startLevel(self.currentLevel+1, false)
                    self.grid.mazeColor = {0,0,1}
                    return
                end
                if engine.timer.getTime() - self.winTime - math.floor(engine.timer.getTime() - self.winTime) > .5 then
                    self.grid.mazeColor = {1,1,1}
                else
                    self.grid.mazeColor = {0.129,0.129,1}
                end

                return
            end

            for i, popup in ipairs(self.popups) do
                if (engine.timer.getTime() - popup[5]) >= popup[6] then
                    table.remove(self.popups, i)

                    if popup.done ~= nil then popup.done() end
                end
            end

            if (engine.timer.getTime() - self.propSpawnTime) % 15 > 14.9 and self.prop == 0 then
                self.prop = self.currentLevelInfo.data[1]
                self.propLastSpawnTime = engine.timer.getTime()
            end

            if self.prop ~= 0  and (engine.timer.getTime() - self.propLastSpawnTime) >= self.propMaxTime then
                self.prop = 0
                self.propSpawnTime = engine.timer.getTime()
            end

            if self.prop ~= 0 and math.abs(self.pacman.position[1] - self.grid.propSpawnCoords[1]) < 5 and math.abs(self.pacman.position[2] - self.grid.propSpawnCoords[2]) < 5 then
                self.score = self.score + self.props[self.prop][2]
                table.insert(self.popups, {self.props[self.prop][2], self.grid.propSpawnCoords[1], self.grid.propSpawnCoords[2] - (self.grid.tilePX/2), {1,.706,1}, engine.timer.getTime(), 2, 2.2})
                self.prop = 0
                self.propSpawnTime = engine.timer.getTime()
            end

            local pastIsInDots = self.pacman.isInDots
            self.pacman.isInDots = self.grid.TILES[self.pacman.tile[1]][self.pacman.tile[2]].consumable ~= nil

            if self.pacman.isInDots == false and pastIsInDots == true and
            self.grid.TILES[self.pacman.tile[1]+self.pacman.direction[1]][self.pacman.tile[2]+self.pacman.direction[2]].consumable ~= nil then
                self.pacman.isInDots = true
            end

            if self.isFrightened ~= false then
                local frightenedTimeLeft = self.currentLevelInfo.data[13] - (engine.timer.getTime() - self.isFrightened)
                if frightenedTimeLeft < 0 then--self.currentLevelInfo.frightenedModeTime then
                    for key, _ in pairs(self.ghosts) do
                        if self.ghosts[key].state ~= self.states.EATEN then
                            self.ghosts[key].state = self.generalState

                            local oppostiteDirContent = self.grid:getTileContent(self.ghosts[key].tile[1] - self.ghosts[key].direction[2], self.ghosts[key].tile[2] - self.ghosts[key].direction[2])
                            if oppostiteDirContent ~= self.grid.WALL and oppostiteDirContent ~= self.grid.BLOCK then
                                self.ghosts[key].direction[self.ghosts[key].directionAxis] = self.ghosts[key].direction[self.ghosts[key].directionAxis]*-1
                            end
                            self.ghosts[key].nextFrameTime = 0.15
                        end
                    end

                    self.isFrightened = false
                    self.pacman.ghostsEatened = 0
                elseif frightenedTimeLeft <= 2 then--self.currentLevelInfo.frightenedModeTime-2 then
                    local frightenedColor = "B"--self.currentLevelInfo.frightenedModeTime-2))/0.3 + 0.5), "B"
                    local colorTimeSpan = 1/5
                    if self.currentLevelInfo.data[13] == 1 then colorTimeSpan = 1/6 end
                    if math.floor(frightenedTimeLeft/(colorTimeSpan) + 0.5) % 2 == 1 then
                        frightenedColor = "W"
                    end
                    for key, _ in pairs(self.ghosts) do
                        if self.ghosts[key].state == self.states.FRIGHTENED then
                            self.ghosts[key].frightenedColor = frightenedColor
                        end
                    end
                end
                local velocityData = 10
                if self.pacman.isInDots == true then velocityData = 11 end
                self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data[velocityData]
            else
                local velocityData = 2
                if self.pacman.isInDots == true then velocityData = 3 end
                self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data[velocityData]

                if self.currentLevelInfo.phase ~= -1 then
                    local acumulatedPhasesTime = 0
                    for i, phase in ipairs(self.currentLevelInfo.shifts) do
                        acumulatedPhasesTime = acumulatedPhasesTime + phase[2]

                        if engine.timer.getTime() - self.currentLevelInfo.startTimeOffset < acumulatedPhasesTime then
                            if self.generalState ~= phase[1] then
                                for key, _ in pairs(self.ghosts) do
                                    if self.ghosts[key].state ~= self.states.EATEN then
                                        self.ghosts[key].state = phase[1]
                                        local oppostiteDirContent = self.grid:getTileContent(self.ghosts[key].tile[1] - self.ghosts[key].direction[2], self.ghosts[key].tile[2] - self.ghosts[key].direction[2])
                                        if oppostiteDirContent ~= self.grid.WALL and oppostiteDirContent ~= self.grid.BLOCK then
                                            self.ghosts[key].direction[self.ghosts[key].directionAxis] = self.ghosts[key].direction[self.ghosts[key].directionAxis]*-1
                                        end
                                    end
                                end
                            end
                            self.generalState = phase[1]
                            if i == #self.currentLevelInfo.shifts then
                                self.currentLevelInfo.phase = -1
                            end
                            goto breakPhaseSelector
                        end
                    end
                    ::breakPhaseSelector::
                end
            end

            for key, _ in pairs(self.ghosts) do
                if self.ghosts[key].state == self.states.FRIGHTENED then
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data[12]
                elseif self.ghosts[key].state == self.states.EATEN then
                    self.ghosts[key].velocity = self.eatenVelocity
                elseif self.grid.TILES[self.ghosts[key].tile[1]][self.ghosts[key].tile[2]].tunnelHallway == true then
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data[5]
                else
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data[4]
                end
            end

            if self.grid.consumables <= self.currentLevelInfo.data[6] and self.ghosts.blinky.state == self.states.CHASE then
                self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data[7]
                if self.grid.consumables <= self.currentLevelInfo.data[8] then
                    self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data[9]
                end
            end

            if self.grid.TILES[self.ghosts.blinky.tile[1]][self.ghosts.blinky.tile[2]].tunnelHallway == true then
                self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data[5]
            end

            self.pacman:update(dt)
            self.ghosts.blinky:update(dt)
            self.ghosts.clyde:update(dt)
            self.ghosts.inky:update(dt)
            self.ghosts.pinky:update(dt)
    elseif self.currentLevel == 0 then
            if Input.right == true or Input.left == true or Input.up == true or Input.down == true or Input.start == true then
                self.currentLevel = -1
            end
        else
            if engine.timer.getTime() - self.nameTag[3] > 0.15 then
                if Input.left then
                    self.nameTag[1] = self.nameTag[1] - 1
                    if self.nameTag[1] == 0 then self.nameTag[1] = #self.nameTag[2] end
                    self.nameTag[3] = engine.timer.getTime()
                elseif Input.right then
                    self.nameTag[1] = self.nameTag[1] + 1
                    if self.nameTag[1] == #self.nameTag[2]+1 then self.nameTag[1] = 1 end
                    self.nameTag[3] = engine.timer.getTime()
                elseif Input.up then
                    self.nameTag[2][self.nameTag[1]] = self.nameTag[2][self.nameTag[1]] + 1
                    if self.nameTag[2][self.nameTag[1]] == 58 then self.nameTag[2][self.nameTag[1]] = 65 end
                    if self.nameTag[2][self.nameTag[1]] == 91 then self.nameTag[2][self.nameTag[1]] = 48 end
                    self.nameTag[3] = engine.timer.getTime()
                elseif Input.down then
                    self.nameTag[2][self.nameTag[1]] = self.nameTag[2][self.nameTag[1]] - 1
                    if self.nameTag[2][self.nameTag[1]] == 47 then self.nameTag[2][self.nameTag[1]] = 90 end
                    if self.nameTag[2][self.nameTag[1]] == 64 then self.nameTag[2][self.nameTag[1]] = 57 end
                    self.nameTag[3] = engine.timer.getTime()
                end
            end

            if Input.start == true then
                for _, pair in ipairs(self.highscores) do
                    if pair[1] == self:getNameTag() then
                        --make sound
                        return
                    end
                end
                self:startLevel(1, false)
            end
            --check input for start game and set name
        end
    end

    gameControl.draw = function (self)
        if self.currentLevel > 0 then
            Font.drawText("HIGH SCORE", engine.graphics.getWidth()/2, self.highScoreLabelCoords[2], self.grid.tilePX*(2.6/16), {1,1,1}, true)
            Font.drawText(tostring(self.highscores[1][2]), engine.graphics.getWidth()/2, self.highScoreValueCoords[2], self.grid.tilePX*(2.6/16), {1,1,1}, true)
            Font.drawText(tostring(self.score), self.scoreCounterCoords[1]-(self.grid.tilePX*(#tostring(self.score))), self.scoreCounterCoords[2], self.grid.tilePX*(2.6/16), {1,1,1})
            Font.drawText(self:getNameTag(), self.nameTagCoords[1], self.nameTagCoords[2], self.grid.tilePX*(2.6/16), {1,1,1})
            for i = 0, self.lifes-2 do
                engine.graphics.setColor(1,1,1)
                local img, scale = engine.graphics.newImage("sprites/pacman/r2.png"), self.grid.tilePX*(1.8/16)
                img:setFilter("nearest", "nearest")
                engine.graphics.draw(img, self.lifesCounterCoords[1]+(i*self.grid.tilePX*2)-(self.grid.tilePX), self.lifesCounterCoords[2]-(self.grid.tilePX), 0, scale, scale)
            end

            for i=1, 8 do
                if self.currentLevel < i then goto exit end
                local scale, sprite = self.grid.tilePX*(1.8/16), self.props[i][1]

                if self.currentLevel > 8 then
                    local _sprite = i + (self.currentLevel - 8)
                    if _sprite > 8 then _sprite = 8 end

                    sprite = self.props[_sprite][1]
                end

                local img = engine.graphics.newImage("sprites/props/"..sprite..".png")
                engine.graphics.setColor(1,1,1)
                img:setFilter("nearest", "nearest")
                engine.graphics.draw(img, self.levelCounterCoords[1]-((i-1)*self.grid.tilePX*2)-(self.grid.tilePX), self.levelCounterCoords[2]-(self.grid.tilePX), 0, scale, scale)
            end::exit::

            if self.prop ~= 0 then
                local img, scale = engine.graphics.newImage("sprites/props/"..self.props[self.prop][1]..".png"), self.grid.tilePX*(2/16)
                local imgWidth, imgHeight = img:getDimensions()

                engine.graphics.setColor(1,1,1)
                img:setFilter("nearest", "nearest")
                engine.graphics.draw(img, self.grid.propSpawnCoords[1] - (imgWidth*scale/2), self.grid.propSpawnCoords[2] - (imgHeight*scale/2), 0, scale, scale)
            end

            self.grid:draw()
            self.pacman:draw()
            self.ghosts.blinky:draw()
            self.ghosts.clyde:draw()
            self.ghosts.inky:draw()
            self.ghosts.pinky:draw()

            for _, popup in ipairs(self.popups) do
                Font.drawText(":"..tostring(popup[1]), popup[2], popup[3], self.grid.tilePX*(popup[7]/16), popup[4], true)
            end
        elseif self.currentLevel == 0 then
            local timePastDeath = (engine.timer.getTime() - self.deathTime)
            if timePastDeath <= 1 then
                Font.drawText("GAME OVER", engine.graphics.getWidth()/2, self.gameOverLabel[2], self.grid.tilePX*(3/16), {1,0,0}, true)
                self.grid:draw()
            elseif timePastDeath <= 2 then
                Font.drawText("GAME OVER", engine.graphics.getWidth()/2, self.gameOverLabel[2], self.grid.tilePX*(3/16), {1,0,0}, true)
            else
                Font.drawText("GAME OVER", engine.graphics.getWidth()/2, self.gameOverLabel[2], self.grid.tilePX*(3/16), {1,0,0}, true)
                Font.drawText("PRESS ANY KEY TO CONTINUE", engine.graphics.getWidth()/2, self.pressAnyKeyLabel[2], self.grid.tilePX*(2/16), {1,1,1}, true)
            end
        else
            engine.graphics.setColor(1,1,1)
            local titleImg, scale = engine.graphics.newImage("sprites/title.png"), self.grid.tilePX*(2.2/16)
            local imgWidth, imgHeight = titleImg:getDimensions()
            titleImg:setFilter("nearest", "nearest")
            engine.graphics.draw(titleImg, (engine.graphics.getWidth() - (imgWidth*scale))/2,  40*(self.grid.tilePX/16), 0, scale, scale)


            Font.drawText("PLAYER", engine.graphics.getWidth()/2, 170*(self.grid.tilePX/16), self.grid.tilePX*(6/16), {1,1,0}, true)
            for i, char in ipairs(self.nameTag[2]) do
                local color, scale, adjust = {.2,.2,.6}, self.grid.tilePX*(7.5/16), 0
                if i == self.nameTag[1] then
                    scale = self.grid.tilePX*(8.5/16)
                    adjust = 5*(self.grid.tilePX/16)
                    if engine.timer.getTime() - math.floor(engine.timer.getTime()) < 0.5 then
                        color = {.2,.2,1}
                    end
                end
                Font.drawText(string.char(char), engine.graphics.getWidth()/2 + (8.5*self.grid.tilePX*(6/16)*(i-3)), (230*(self.grid.tilePX/16)) - adjust, scale, {1,1,0}, true, color)
            end

            Font.drawText("HIGHSCORES", engine.graphics.getWidth()/2, 305*(self.grid.tilePX/16), self.grid.tilePX*(6.5/16), {1,1,1}, true)
            for i, pair in ipairs(self.highscores) do
                local scoreStr = ""
                for _=1, 8-#tostring(pair[2]) do
                    scoreStr = scoreStr.." "
                end
                scoreStr = scoreStr..tostring(pair[2])
                Font.drawText(pair[1].." / "..scoreStr, engine.graphics.getWidth()/2, (340 + (i*35))*(self.grid.tilePX/16), self.grid.tilePX*(3.7/16), {1,1,1}, true)
            end
            --Main menu
        end
    end

    -- File For saving scores
    engine.filesystem.createDirectory("savings")

    if engine.filesystem.getInfo(gameControl.savingsFile) == nil then
        engine.filesystem.write(gameControl.savingsFile, "")
    end

    local i = 1
    for line in engine.filesystem.lines(gameControl.savingsFile) do
        local comaIndex = line:find(",")
        gameControl.highscores[i] = {line:sub(1, comaIndex-1), tonumber(line:sub(comaIndex+1, #line))}
        i = i + 1
    end
    gameControl:serializeScores()

    return gameControl
end

return GameControl