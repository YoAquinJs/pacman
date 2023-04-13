require("pacman")
require("ghosts")
require("grid")

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

        nameTagColor = {.2,.2,.6},
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
        sirenPitch = 1,
        levels = {
            modeShifts = {},-- 0:SCATTER 1:CHASE See leveldata.csv
            levelData = {
"BonusSymbol","PacmanSpeed","PacmanDotSpeed","GhostSpeed","GhostTunnelSpeed","Elroy1Dots","Elroy1Speed","Elroy2Dots","Elroy2Speed","PacmanFrightSpeed","PacmanFrightDotSpeed","GhostFrightSpeed","FrightTime"
                        }
        },
        startLevel = function (self, level, died)
            if level == 1 and died == false then
                self.score = 0
                self.lifes = self.startLifes
                self.reachHighscore = false
                self.grid:reloadConsumeables()
            else
                if level == self.currentLevel + 1 then
                    self.grid:reloadConsumeables()
                end
            end

            for i=1,#self.levels.modeShifts do
                if level < self.levels.modeShifts[i].untilLevel+1 or self.levels.modeShifts[i].untilLevel==-1 then
                    self.currentLevelInfo.shifts = self.levels.modeShifts[i].phases
                    goto selectedModeShift
                end
            end ::selectedModeShift::

            if level < #self.levels.levelData then
                self.currentLevelInfo.data = self.levels.levelData[level]
            else
                self.currentLevelInfo.data = self.levels.levelData[#self.levels.levelData]
            end
            self.currentLevelInfo.startTimeOffset = Utils:getTime()
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
            self.currentLevel = level
            self.frameCount = 0
            self.sirenPitch = 1
            self.propSpawnTime = Utils:getTime()
        end,
        addScore = function (self, add)
            self.score = self.score + add

            if self.reachHighscore == false and self.score > self.highscores[1][2] then
                self.reachHighscore = true
                Utils:triggAudio("highscore", 1, 1, false, true)
            end
        end,
        frightenedMode = function (self)
            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].state = self.states.FRIGHTENED
                self.ghosts[key].nextFrameTime = 0.199
                self.ghosts[key].frightenedColor = "B"
            end

            self.pacman.ghostsEatened = 1
            self.currentLevelInfo.startTimeOffset = self.currentLevelInfo.startTimeOffset + self.currentLevelInfo.data.FrightTime

            self.isFrightened = Utils:getTime()
            Utils:stopAllSounds()
            Utils:doAfter(Utils:triggAudio("frigthtenedstart", 1, 1, false, true), function ()
                Utils:triggAudio("frigthtened", 1, 1, true, true)
            end)

            Utils:doAfter(self.currentLevelInfo.data.FrightTime, function ()
                Utils:triggAudio("frigthtened", 1, 1, true, false)
            end)
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

            Utils:stopAllSounds()
            Utils:sleep(1)
            self.pacman.renderSprite = "fill"
            self.pacman.frame = 0
            self.pacman.lastFrameTime = Utils:getTime()

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].render = false
            end
            self.prop = 0

            self.pacman.nextFrameTime = Utils:triggAudio("die", 1, 1, false, true)/12
        end,
        pacmanDie = function (self)
            Utils:sleep(1)
            if self.lifes == 0 then
                self.deathTime = Utils:getTime()
                self.currentLevel = 0
                table.insert(self.highscores, {self:getNameTag(), self.score})
                self:serializeScores()
            else
                self:startLevel(self.currentLevel, true)
            end
        end,
        eatGhost = function (self, key, ghostsEatened)
            self.ghosts[key].state = self.states.EATEN
            self.ghosts[key].nextFrameTime = 0.15
            local obtainedScore = (200 * math.pow(2,ghostsEatened-1))
            self.score = self.score + obtainedScore

            local popupCoords = self.grid:getCenterCoordinates(self.ghosts[key].tile[1], self.ghosts[key].tile[2])
            Utils:stopAllSounds()
            table.insert(self.popups, {tostring(obtainedScore), popupCoords[1], popupCoords[2] - (self.grid.tilePX/2), {0,1,1}, Utils:getTime(), .001, 2,
            done=function ()
                for key, _ in pairs(self.ghosts) do
                    self.ghosts[key].stoped = true
                end
                self.pacman.stoped = true
                Utils:sleep(Utils:triggAudio("eatghost", 1, 1, false, true))
                Utils:stopAllSounds()
                Utils:triggAudio("eaten", 1, 1, true, true)

                for key, _ in pairs(self.ghosts) do
                    self.ghosts[key].stoped = false
                end
                self.pacman.stoped = false
                self.pacman.render = true
                self.ghosts[key].render = true
            end})
        end,
        winLevel = function (self)
            Utils:sleep(1.5)

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].stoped = true
                self.ghosts[key].render = false
            end
            self.pacman.stoped = true

            Utils:sleep(.5)
            self.pacman.render = false
            self.winTime = Utils:getTime()
        end
    }

    gameControl.grid =  Grid.LoadGrid(gameControl, tilePX)

    gameControl.update = function (self, dt, time)
        if self.currentLevel > 0 then
            if self.grid.consumables == 0 then
                if time - self.winTime > 4.5 then
                    Utils:sleep(.5)
                    self:startLevel(self.currentLevel+1, false)
                    self.grid.mazeColor = {0,0,1}
                    return
                end
                if time - self.winTime - math.floor(time - self.winTime) > .5 then
                    self.grid.mazeColor = {1,1,1}
                else
                    self.grid.mazeColor = {0.129,0.129,1}
                end

                return
            end

            for i, popup in ipairs(self.popups) do
                if (time - popup[5]) >= popup[6] then
                    table.remove(self.popups, i)

                    if popup.done ~= nil then popup.done() end
                end
            end

            if (time - self.propSpawnTime) % 15 > 14.9 and self.prop == 0 then
                self.prop = self.currentLevelInfo.data.BonusSymbol
                self.propLastSpawnTime = time
            end

            if self.prop ~= 0  and (time - self.propLastSpawnTime) >= self.propMaxTime then
                self.prop = 0
                self.propSpawnTime = time
            end

            if self.prop ~= 0 and math.abs(self.pacman.position[1] - self.grid.propSpawnCoords[1]) < 5 and math.abs(self.pacman.position[2] - self.grid.propSpawnCoords[2]) < 5 then
                self.score = self.score + self.props[self.prop][2]
                table.insert(self.popups, {self.props[self.prop][2], self.grid.propSpawnCoords[1], self.grid.propSpawnCoords[2] - (self.grid.tilePX/2), {1,.706,1}, time, 2, 2.2})
                self.prop = 0
                self.propSpawnTime = time

                Utils:triggAudio("eatfruit", 1, 1, false, true)
            end

            local pastIsInDots = self.pacman.isInDots
            self.pacman.isInDots = self.grid:getTileContent(self.pacman.tile[1], self.pacman.tile[2]).consumable ~= nil

            if self.pacman.isInDots == false and pastIsInDots == true and
            self.grid:getTileContent(self.pacman.tile[1]+self.pacman.direction[1], self.pacman.tile[2]+self.pacman.direction[2]).consumable ~= nil then
                self.pacman.isInDots = true
            end

            if self.isFrightened ~= false then
                local frightenedTimeLeft = self.currentLevelInfo.data.FrightTime - (time - self.isFrightened)
                if frightenedTimeLeft < 0 then--self.currentLevelInfo.frightenedModeTime then
                    for key, _ in pairs(self.ghosts) do
                        if self.ghosts[key].state ~= self.states.EATEN then
                            self.ghosts[key].state = self.generalState

                            local oppostiteDirContent = self.grid:getTileContent(self.ghosts[key].tile[1] - self.ghosts[key].direction[2], self.ghosts[key].tile[2] - self.ghosts[key].direction[2]).content
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
                    if self.currentLevelInfo.data.FrightTime == 1 then colorTimeSpan = 1/6 end
                    if math.floor(frightenedTimeLeft/(colorTimeSpan) + 0.5) % 2 == 1 then
                        frightenedColor = "W"
                    end
                    for key, _ in pairs(self.ghosts) do
                        if self.ghosts[key].state == self.states.FRIGHTENED then
                            self.ghosts[key].frightenedColor = frightenedColor
                        end
                    end
                end
                self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanFrightSpeed
                if self.pacman.isInDots == true then
                    self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanFrightDotSpeed
                end
            else
                self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanSpeed
                if self.pacman.isInDots == true then
                    self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanDotSpeed
                end

                if self.currentLevelInfo.phase ~= -1 then
                    local acumulatedPhasesTime = 0
                    for i, phase in ipairs(self.currentLevelInfo.shifts) do
                        acumulatedPhasesTime = acumulatedPhasesTime + phase[2]

                        if time - self.currentLevelInfo.startTimeOffset < acumulatedPhasesTime then
                            if self.generalState ~= phase[1] then
                                for key, _ in pairs(self.ghosts) do
                                    if self.ghosts[key].state ~= self.states.EATEN then
                                        self.ghosts[key].state = phase[1]
                                        local oppostiteDirContent = self.grid:getTileContent(self.ghosts[key].tile[1] - self.ghosts[key].direction[2], self.ghosts[key].tile[2] - self.ghosts[key].direction[2]).content
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

            local anyEaten = false
            for key, _ in pairs(self.ghosts) do
                if self.ghosts[key].state == self.states.FRIGHTENED then
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data.GhostFrightSpeed
                elseif self.ghosts[key].state == self.states.EATEN then
                    anyEaten = true
                    self.ghosts[key].velocity = self.eatenVelocity
                elseif self.grid:getTileContent(self.ghosts[key].tile[1], self.ghosts[key].tile[2]).tunnelHallway == true then
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data.GhostTunnelSpeed
                else
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data.GhostSpeed
                end
            end

            if self.grid.consumables <= self.currentLevelInfo.data.Elroy1Dots and self.ghosts.blinky.state == self.states.CHASE then
                self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data.Elroy1Speed
                self.sirenPitch = 1.2
                if self.grid.consumables <= self.currentLevelInfo.data.Elroy2Dots then
                    self.sirenPitch = 1.4
                    self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data.Elroy2Speed
                end
            end

            if self.grid:getTileContent(self.ghosts.blinky.tile[1], self.ghosts.blinky.tile[2]).tunnelHallway == true then
                self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data.GhostTunnelSpeed
            end

            if self.pacman.dying == false and self.frameCount > 2 then
                if Utils:isPlaying("eatdot") == true then
                    if self.pacman.isInDots == false then
                        Utils:triggAudio("eatdot", .65, 1, false, true)
                    end
                else
                    Utils:triggAudio("eatdot", .65, 1, true, self.pacman.isInDots)
                end

                if anyEaten == false then
                    if self.isFrightened ~= false then
                        if Utils:isPlaying("frigthtened") == false then
                            Utils:triggAudio("frigthtened", 1, 1, true, true)
                        end
                    else
                        if Utils:isPlaying("siren") == false then
                            Utils:triggAudio("siren", 1, self.sirenPitch, true, true)
                        end
                    end
                elseif Utils:isPlaying("eaten") == false then
                    Utils:triggAudio("eaten", 1, 1, true, true)
                end
            end

            self.pacman:update(dt)
            self.ghosts.blinky:update(dt)
            self.ghosts.clyde:update(dt)
            self.ghosts.inky:update(dt)
            self.ghosts.pinky:update(dt)

            --AUDIO

            --siren
                --eat dot
            --frightened
            --eaten

            if self.frameCount == 1 then
                Utils:sleep(Utils:triggAudio("start", .7, 1, false, self.currentLevel == 1 and self.lifes == self.startLifes))
            end
            self.frameCount = self.frameCount + 1
        elseif self.currentLevel == 0 then
            if Utils.input.right == true or Utils.input.left == true or Utils.input.up == true or Utils.input.down == true or Utils.input.start == true then
                self.currentLevel = -1
            end
        else
            if time - self.nameTag[3] > 0.15 then
                if Utils.input.left then
                    self.nameTag[1] = self.nameTag[1] - 1
                    if self.nameTag[1] == 0 then self.nameTag[1] = #self.nameTag[2] end
                    self.nameTag[3] = time
                elseif Utils.input.right then
                    self.nameTag[1] = self.nameTag[1] + 1
                    if self.nameTag[1] == #self.nameTag[2]+1 then self.nameTag[1] = 1 end
                    self.nameTag[3] = time
                elseif Utils.input.up then
                    self.nameTag[2][self.nameTag[1]] = self.nameTag[2][self.nameTag[1]] + 1
                    if self.nameTag[2][self.nameTag[1]] == 58 then self.nameTag[2][self.nameTag[1]] = 65 end
                    if self.nameTag[2][self.nameTag[1]] == 91 then self.nameTag[2][self.nameTag[1]] = 48 end

                    self.nameTagColor = {.2,.2,.6}
                    for i=1, #self.highscores do
                        if self.highscores[i][1] == self:getNameTag() then self.nameTagColor = {.8,.6,.01} end
                    end
                    self.nameTag[3] = time
                elseif Utils.input.down then
                    self.nameTag[2][self.nameTag[1]] = self.nameTag[2][self.nameTag[1]] - 1
                    if self.nameTag[2][self.nameTag[1]] == 47 then self.nameTag[2][self.nameTag[1]] = 90 end
                    if self.nameTag[2][self.nameTag[1]] == 64 then self.nameTag[2][self.nameTag[1]] = 57 end

                    self.nameTagColor = {.2,.2,.6}
                    for i=1, #self.highscores do
                        if self.highscores[i][1] == self:getNameTag() then self.nameTagColor = {.8,.6,.01} end
                    end
                    self.nameTag[3] = time
                end
            end

            if Utils.input.start == true then
                for _, pair in ipairs(self.highscores) do
                    if pair[1] == self:getNameTag() then
                        --make sound
                        return
                    end
                end
                self:startLevel(1, false)
            end
        end
    end

    gameControl.draw = function (self, time)
        if self.currentLevel > 0 then
            Utils:drawText("HIGH SCORE", engine.graphics.getWidth()/2, self.highScoreLabelCoords[2], self.grid.tilePX*(2.6/16), {1,1,1}, true)
            Utils:drawText(tostring(self.highscores[1][2]), engine.graphics.getWidth()/2, self.highScoreValueCoords[2], self.grid.tilePX*(2.6/16), {1,1,1}, true)
            Utils:drawText(tostring(self.score), self.scoreCounterCoords[1]-(self.grid.tilePX*(#tostring(self.score))), self.scoreCounterCoords[2], self.grid.tilePX*(2.6/16), {1,1,1})
            Utils:drawText(self:getNameTag(), self.nameTagCoords[1], self.nameTagCoords[2], self.grid.tilePX*(2.6/16), {1,1,1})
            for i = 0, self.lifes-2 do
                local img, scale = "pacman/r2", self.grid.tilePX*(1.8/16)
                Utils:draw(img, self.lifesCounterCoords[1]+(i*self.grid.tilePX*2)-(self.grid.tilePX), self.lifesCounterCoords[2]-(self.grid.tilePX), scale, {1,1,1})
            end

            for i=1, 8 do
                if self.currentLevel < i then goto exit end
                local scale, sprite = self.grid.tilePX*(1.8/16), self.props[i][1]

                if self.currentLevel > 8 then
                    local _sprite = i + (self.currentLevel - 8)
                    if _sprite > 8 then _sprite = 8 end

                    sprite = self.props[_sprite][1]
                end

                local img = "props/"..sprite
                Utils:draw(img, self.levelCounterCoords[1]-((i-1)*self.grid.tilePX*2)-(self.grid.tilePX), self.levelCounterCoords[2]-(self.grid.tilePX), scale, {1,1,1})
            end::exit::

            if self.prop ~= 0 then
                local img, scale, imgSize = "props/"..self.props[self.prop][1], self.grid.tilePX*(2/16), Utils:getImgSize("props/"..self.props[self.prop][1])
                Utils:draw(img, self.grid.propSpawnCoords[1] - (imgSize*scale/2), self.grid.propSpawnCoords[2] - (imgSize*scale/2), scale, {1,1,1})
            end

            self.grid:draw()
            self.pacman:draw(time)
            self.ghosts.blinky:draw(time)
            self.ghosts.clyde:draw(time)
            self.ghosts.inky:draw(time)
            self.ghosts.pinky:draw(time)

            for _, popup in ipairs(self.popups) do
                Utils:drawText(":"..tostring(popup[1]), popup[2], popup[3], self.grid.tilePX*(popup[7]/16), popup[4], true)
            end
        elseif self.currentLevel == 0 then
            local timePastDeath = (time - self.deathTime)
            if timePastDeath <= 1 then
                Utils:drawText("GAME OVER", engine.graphics.getWidth()/2, self.gameOverLabel[2], self.grid.tilePX*(3/16), {1,0,0}, true)
                self.grid:draw()
            elseif timePastDeath <= 2 then
                Utils:drawText("GAME OVER", engine.graphics.getWidth()/2, self.gameOverLabel[2], self.grid.tilePX*(3/16), {1,0,0}, true)
            else
                Utils:drawText("GAME OVER", engine.graphics.getWidth()/2, self.gameOverLabel[2], self.grid.tilePX*(3/16), {1,0,0}, true)
                Utils:drawText("PRESS ANY KEY TO CONTINUE", engine.graphics.getWidth()/2, self.pressAnyKeyLabel[2], self.grid.tilePX*(2/16), {1,1,1}, true)
            end
        else
            local img, scale, imgSize = "title", self.grid.tilePX*(2.2/16), Utils:getImgSize("title")
            Utils:draw(img, (engine.graphics.getWidth() - (imgSize*scale))/2,  40*(self.grid.tilePX/16), scale, {1,1,1})

            Utils:drawText("PLAYER", engine.graphics.getWidth()/2, 160*(self.grid.tilePX/16), self.grid.tilePX*(6/16), {1,1,0}, true)
            for i, char in ipairs(self.nameTag[2]) do
                local color, scale, adjust = self.nameTagColor, self.grid.tilePX*(8/16), 0
                if i == self.nameTag[1] then
                    scale = self.grid.tilePX*(9/16)
                    adjust = 4*(self.grid.tilePX/16)
                    if time - math.floor(time) < 0.5 then
                        if color[2] == .2 then color[3] = 1 end
                        if color[2] == .6 then color[1] = 1 end
                    end
                end
                Utils:drawText(string.char(char), engine.graphics.getWidth()/2 + (9*self.grid.tilePX*(6/16)*(i-3)), (220*(self.grid.tilePX/16)) - adjust, scale, {1,1,0}, true, color)
            end

            Utils:drawText("HIGHSCORES", engine.graphics.getWidth()/2, 305*(self.grid.tilePX/16), self.grid.tilePX*(6.5/16), {1,1,1}, true)
            for i, pair in ipairs(self.highscores) do
                local scoreStr = ""
                for _=1, 8-#tostring(pair[2]) do
                    scoreStr = scoreStr.." "
                end
                scoreStr = scoreStr..tostring(pair[2])
                Utils:drawText(pair[1].." / "..scoreStr, engine.graphics.getWidth()/2, (340 + (i*35))*(self.grid.tilePX/16), self.grid.tilePX*(3.7/16), {1,1,1}, true)
            end
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
        if gameControl.highscores[i][1] == "AAAAA" then
            gameControl.nameTagColor = {.8,.6,.01}
        end
        i = i + 1
    end
    gameControl:serializeScores()

    -- File for level data
    local levelDataFile = assert(io.open("assets/leveldata.csv", "r"))

    local i, j, levelData, levelDataKeys = 1, 1, true, gameControl.levels.levelData
    gameControl.levels.levelData = {}
    for levelDataString in levelDataFile:lines() do
        j = 1

        if #levelDataString < 2 then
            levelData = false
            i = 1
        else
            if levelData == true then
    ---@diagnostic disable-next-line: assign-type-mismatch
                gameControl.levels.levelData[i] = {}
            else
                gameControl.levels.modeShifts[i] = {untilLevel=nil, phases={}}
            end

            for data in string.gmatch(levelDataString, "[^,]+") do
                if levelData == true then
                    if data == "null" then
                        gameControl.levels.levelData[i][levelDataKeys[j]] = nil
                    else
                        gameControl.levels.levelData[i][levelDataKeys[j]] = assert(tonumber(data))
                    end
                else
                    if j == 1 then
                        gameControl.levels.modeShifts[i].untilLevel = assert(tonumber(data))
                    else
                        gameControl.levels.modeShifts[i].phases[j-1] = {j%2, tonumber(data)}
                    end
                end
                j = j + 1
            end
            i = i + 1
        end
    end

    levelDataFile:close()


    return gameControl
end

return GameControl