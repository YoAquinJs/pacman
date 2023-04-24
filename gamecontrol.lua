require("pacman")
require("ghosts")
require("grid")

GameControl = {}

GameControl.LoadGameControl = function ()
    local gameControl = {
        grid = nil,
        pacman = nil,
        ghosts = nil,
        states = nil,
        highscores = {},

        savingsFile = "highscores",
        startLifes=3,
        maxVelocity = 8,
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

        reachHighscore = false,
        nameTagColor = {.2,.2,.6},
        nameTag={1, {65, 65, 65, 65, 65}, 0},
        tag = nil,
        drawables={},
        lifes=5,
        generalState=nil,
        isFrightened=false,
        score=0,
        currentLevelInfo={shifts={},data={},phase=0,level=0,timeLeftForShift=0},
        sirenPitch = 1,
        levels = {
            modeShifts = {},-- 0:SCATTER 1:CHASE See leveldata.csv
            levelData = {"BonusSymbol","PacmanSpeed","PacmanDotSpeed","GhostSpeed","GhostTunnelSpeed","Elroy1Dots","Elroy1Speed","Elroy2Dots","Elroy2Speed","PacmanFrightSpeed","PacmanFrightDotSpeed","GhostFrightSpeed","FrightTime"}
        },
        triggerProp = function (self)
            Utils:programAction(self.propMaxTime, function ()
                self.prop = self.currentLevelInfo.data.BonusSymbol
                Utils:programAction(self.propMaxTime, function ()
                    self.prop = 0
                    self:triggerProp()
                end, "propdestroy")
            end, "propspawn")
        end,
        triggerPhaseChange = function (self, timeLeft, flip)
            if self.generalState ~= self.currentLevelInfo.shifts[self.currentLevelInfo.phase][1] then
                self.generalState = self.currentLevelInfo.shifts[self.currentLevelInfo.phase][1]
                for key, _ in pairs(self.ghosts) do
                    if self.ghosts[key].state ~= self.states.EATEN then
                        self.ghosts[key].state = self.generalState
                        if flip == nil then
                            local oppostiteDirContent = self.grid:getTileContent(self.ghosts[key].tile[1] - self.ghosts[key].direction[1], self.ghosts[key].tile[2] - self.ghosts[key].direction[2]).content
                            if oppostiteDirContent ~= self.grid.WALL and oppostiteDirContent ~= self.grid.BLOCK then
                                self.ghosts[key].direction[self.ghosts[key].directionAxis] = self.ghosts[key].direction[self.ghosts[key].directionAxis]*-1
                            end
                        end
                    end
                end
            end

            local time = self.currentLevelInfo.shifts[self.currentLevelInfo.phase][2]
            if timeLeft ~= nil then time = timeLeft end
            Utils:programAction(-1, function ()
                Utils:programAction(time, function ()
                    if self.currentLevelInfo.shifts[self.currentLevelInfo.phase+1] ~= nil then
                        self.currentLevelInfo.phase = self.currentLevelInfo.phase + 1
                        self:triggerPhaseChange()
                    end
                end, "modeshift")
            end)
        end,
        startLevel = function (self, level, died)
            if level == 1 and died == false then
                self.score = 0
                self.reachHighscore = false
                self.lifes = self.startLifes
                self.reachHighscore = false
                self.grid:reloadConsumeables()
            end

            local i = 1
            self.currentLevelInfo.shifts = nil
            while level < self.levels.modeShifts[i].untilLevel+1 do
                self.currentLevelInfo.shifts = self.levels.modeShifts[i].phases
                i = i + 1
            end
            if self.currentLevelInfo.shifts == nil then
                self.currentLevelInfo.shifts = self.levels.modeShifts[#self.levels.modeShifts].phases
            end

            if level> self.currentLevelInfo.level then
                self.grid:reloadConsumeables()
                self.currentLevelInfo.timeLeftForShift = self.currentLevelInfo.shifts[1][2]
                self.currentLevelInfo.phase = 1
            end

            if level < #self.levels.levelData then
                self.currentLevelInfo.data = self.levels.levelData[level]
            else
                self.currentLevelInfo.data = self.levels.levelData[#self.levels.levelData]
            end

            self.pacman = Pacman.LoadPacman(self.grid, {self.pacmanDir[1], self.pacmanDir[2]}, self)
            local GhostsObjs = Ghosts:LoadGhosts(self.grid, self, self.pacman, {self.blinkyDir[1], self.blinkyDir[2]})
            self.ghosts = GhostsObjs
            self.states = Ghosts.states
            self.pacman.ghosts = GhostsObjs

            self.prop = 0
            self.grid.mazeColor = {1,1,1}
            self.grid.mazeImg = "maze/maze"
            self.currentLevelInfo.level= level
            self.frameCount = 0
            self.sirenPitch = 1

            self.nameTagColor = {.2,.2,.6}
            for i=1, #self.highscores do
                if self.highscores[i][1] == self:getNameTag() then self.nameTagColor = {.8,.6,.01} end
            end

            self:triggerPhaseChange(self.currentLevelInfo.timeLeftForShift, false)
            self:triggerProp()
        end,
        addScore = function (self, add)
            self.score = self.score + add

            if self.reachHighscore == false and Utils.mute == false and self.score > self.highscores[1][2] then
                self.reachHighscore = true
                Utils:muteWhile("highscore", 1, 1)
            end
        end,
        ghostFrightColorFlash = function (self, colorTimeSpan, flashes, iter, isBlue)
            local frightenedColor = "B"
            if isBlue == false then frightenedColor = "W" end
            for key, _ in pairs(self.ghosts) do
                if self.ghosts[key].state == self.states.FRIGHTENED then
                    self.ghosts[key].frightenedColor = frightenedColor
                end
            end

            if iter < flashes then
                Utils:programAction(colorTimeSpan, function ()
                    self:ghostFrightColorFlash(colorTimeSpan, flashes, iter+1, not isBlue)
                end, "frigthtenedFlash"..frightenedColor)
            end
        end,
        frightenedMode = function (self)
            Utils:cancelAction("frigthtened")
            Utils:cancelAction("frigthtenedFlashW")
            Utils:cancelAction("frigthtenedFlashB")

            for key, _ in pairs(self.ghosts) do
                if self.ghosts[key].state ~= self.states.EATEN then
                    self.ghosts[key].state = self.states.FRIGHTENED
                    self.ghosts[key].nextFrameTime = 0.2
                    self.ghosts[key].frightenedColor = "B"
                    local oppostiteDirContent = self.grid:getTileContent(self.ghosts[key].tile[1] - self.ghosts[key].direction[1], self.ghosts[key].tile[2] - self.ghosts[key].direction[2]).content
                    if oppostiteDirContent ~= self.grid.WALL and oppostiteDirContent ~= self.grid.BLOCK then
                        self.ghosts[key].direction[self.ghosts[key].directionAxis] = self.ghosts[key].direction[self.ghosts[key].directionAxis]*-1
                    end
                else
                    self.ghosts[key].turnFrightened = true
                end
            end

            self.pacman.ghostsEatened = 1

            self.isFrightened = true
            self.currentLevelInfo.timeLeftForShift = Utils:cancelAction("modeshift")
            Utils:programAction(self.currentLevelInfo.data.FrightTime, function ()
                local anyEaten = false

                for key, _ in pairs(self.ghosts) do
                    if self.ghosts[key].state ~= self.states.EATEN then
                        self.ghosts[key].state = self.generalState
                        self.ghosts[key].nextFrameTime = 0.15
                    else
                        anyEaten = true
                    end
                end

                --if anyEaten == false then Utils:audio("siren", true, true, 1, self.sirenPitch) end

                self.isFrightened = false
                self.pacman.ghostsEatened = 0
                --Utils:audio("frigthtened", false)
                self:triggerPhaseChange(self.currentLevelInfo.timeLeftForShift)
            end, "frigthtened")
            Utils:programAction(self.currentLevelInfo.data.FrightTime-2, function ()
                local colorTimeSpan, flashes = 1/5, 10
                if self.currentLevelInfo.data.FrightTime == 1 then colorTimeSpan, flashes = 1/6, 6 end
                self:ghostFrightColorFlash(colorTimeSpan, flashes, 1, true)
            end, "frigthtenedFlashW")

            --if Utils.audios["eaten"]:isPlaying() == true then return end

            --Utils.audios["siren"]:stop()
            --Utils:programAction(Utils:audio("frigthtenedstart", true), function ()
            --    Utils:audio("frigthtened", true, true)
            --end)
        end,
        serializeScores = function (self)
            local formattedValues = ""
            table.sort(self.highscores, function (k1, k2) return k1[2] > k2[2] end )

            for i, value in ipairs(self.highscores) do
                if i > self.maxHighscores then
                    table.remove(self.highscores, i)
                else
                    formattedValues = formattedValues..value[1]..", "..value[2].."\n"
                end
            end

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

            self.pacman.nextFrameTime = Utils:audio("die", true)/12
        end,
        pacmanDie = function (self)
            self.currentLevelInfo.timeLeftForShift = Utils:cancelAction("modeshift")

            Utils:sleep(1)
            if self.lifes == 0 then
                self.drawables["gameover"] = {text="GAME OVER", coordinates={engine.graphics.getWidth()/2, self.gameOverLabel[2]}, color={1,0,0}, scale=3, isPopup=""}
                Utils:programAction(1.5, function ()
                    self.currentLevelInfo.level= 0
                    Utils:programAction(1.5, function ()
                        self.drawables["pressanykey"] = {text="PRESS ANY KEY TO CONTINUE", coordinates={engine.graphics.getWidth()/2, self.pressAnyKeyLabel[2]}, color={1,1,1}, scale=2, isPopup=""}
                    end)
                end)
                table.insert(self.highscores, {self.tag, self.score})
                self:serializeScores()
                self.tag = nil
            else
                self:startLevel(self.currentLevelInfo.level, true)
            end
        end,
        eatGhost = function (self, key, ghostsEatened)
            self.ghosts[key].state = self.states.EATEN
            self.ghosts[key].nextFrameTime = 0.15
            local obtainedScore = (200 * math.pow(2,ghostsEatened-1))
            self:addScore(obtainedScore)

            local popupCoords = self.grid:getCenterCoordinates(self.ghosts[key].tile[1], self.ghosts[key].tile[2])
            self.drawables["eatghost"] = {text=tostring(obtainedScore), coordinates={popupCoords[1], popupCoords[2] - (self.grid.tilePX/2)}, color={0,1,1}, scale=2, isPopup=":"}
            Utils:programAction(-1, function ()
                self.drawables["eatghost"] = nil
                for key, _ in pairs(self.ghosts) do
                    self.ghosts[key].stoped = true
                end
                self.pacman.stoped = true
                Utils.audios["frigthtened"]:stop()
                Utils:sleep(Utils:muteWhile("eatghost", 1, 1, -1))

                --Utils:audio("eaten", true, true)
                for key, _ in pairs(self.ghosts) do
                    self.ghosts[key].stoped = false
                end
                self.pacman.stoped = false
                self.pacman.render = true
                self.ghosts[key].render = true
            end)
        end,
        mazeColorFlash = function (self, iter, isBlue)
            self.grid.mazeColor = {0.129,0.129,1}
            if isBlue == false then self.grid.mazeColor = {1,1,1} end

            if iter < 10 then
                Utils:programAction(.5, function ()
                    self:mazeColorFlash(iter+1, not isBlue)
                end)
            end
        end,
        winLevel = function (self)
            Utils:stopAllSounds()
            self.prop = 0
            Utils:sleep(1.5)

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].stoped = true
                self.ghosts[key].render = false
            end
            self.pacman.stoped = true

            Utils:programAction(.5, function ()
                self.pacman.render = false

                self:mazeColorFlash(1, false)
                Utils:programAction(5, function()
                    Utils:sleep(1)
                    self:startLevel(self.currentLevelInfo.level+1, false)
                    self.grid.mazeColor = {0,0,1}
                end)
                self.grid.mazeImg = "maze/winmaze"
            end)
        end
    }

    gameControl.update = function (self, dt, time)
        if self.currentLevelInfo.level > 0 and self.grid.consumables > 0 then
            if self.prop ~= 0 and math.abs(self.pacman.position[1] - self.grid.propSpawnCoords[1]) < 5 and math.abs(self.pacman.position[2] - self.grid.propSpawnCoords[2]) < 5 then
                self:addScore(self.props[self.prop][2])
                self.drawables["prop"] = {text=self.props[self.prop][2], coordinates={self.grid.propSpawnCoords[1], self.grid.propSpawnCoords[2] - (self.grid.tilePX/2)}, color={1,.706,1}, scale=2.2, isPopup=":"}
                Utils:programAction(2, function ()
                    self.drawables["prop"] = nil
                end)
                self.prop = 0
                Utils:cancelAction("propdestroy")
                self:triggerProp()
                Utils:audio("eatfruit", true)
            end

            local pastIsInDots = self.pacman.isInDots
            self.pacman.isInDots = self.grid:getTileContent(self.pacman.tile[1], self.pacman.tile[2]).consumable ~= nil

            if self.pacman.isInDots == false and pastIsInDots == true and
            self.grid:getTileContent(self.pacman.tile[1]+self.pacman.direction[1], self.pacman.tile[2]+self.pacman.direction[2]).consumable ~= nil then
                self.pacman.isInDots = true
            end

            if self.isFrightened ~= false then
                self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanFrightSpeed
                if self.pacman.isInDots == true then
                    self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanFrightDotSpeed
                end
            else
                self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanSpeed
                if self.pacman.isInDots == true then
                    self.pacman.velocity = self.maxVelocity*self.currentLevelInfo.data.PacmanDotSpeed
                end
            end

            for key, _ in pairs(self.ghosts) do
                if self.ghosts[key].state == self.states.FRIGHTENED then
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data.GhostFrightSpeed
                elseif self.ghosts[key].state == self.states.EATEN then
                    self.ghosts[key].velocity = self.eatenVelocity
                elseif self.grid:getTileContent(self.ghosts[key].tile[1], self.ghosts[key].tile[2]).tunnelHallway == true then
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data.GhostTunnelSpeed
                else
                    self.ghosts[key].velocity = self.maxVelocity*self.currentLevelInfo.data.GhostSpeed
                end
            end

            if self.grid.consumables <= self.currentLevelInfo.data.Elroy1Dots then
                self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data.Elroy1Speed
                self.sirenPitch = 1.2
                Utils.audios["siren"]:setPitch(1.2)
                if self.grid.consumables <= self.currentLevelInfo.data.Elroy2Dots then
                    self.sirenPitch = 1.4
                    Utils.audios["siren"]:setPitch(1.4)
                    self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data.Elroy2Speed
                end
            end

            if self.grid:getTileContent(self.ghosts.blinky.tile[1], self.ghosts.blinky.tile[2]).tunnelHallway == true then
                self.ghosts.blinky.velocity = self.maxVelocity*self.currentLevelInfo.data.GhostTunnelSpeed
            end

            if self.pacman.dying == false and self.grid.consumables > 0 and self.frameCount > 2 then
                --if Utils.audios["eatdot"]:isPlaying() == true and self.pacman.isInDots == false then
                --    Utils:audio("eatdot", true, false, .55)
                --elseif self.pacman.isInDots == true then
                --    Utils:audio("eatdot", true, true, .55)
                --end
            end

            self.pacman:update(dt)
            self.ghosts.blinky:update(dt)
            self.ghosts.clyde:update(dt)
            self.ghosts.inky:update(dt)
            self.ghosts.pinky:update(dt)

            if self.frameCount == 1 then
                local sleepTime = Utils:audio("start", self.currentLevelInfo.level == 1 and self.lifes == self.startLifes, false, .7)
                if self.currentLevelInfo.level ~= 1 or self.lifes ~= self.startLifes then
                    sleepTime = sleepTime/4
                end
                Utils:sleep(sleepTime)
                --Utils:programAction(-1, function ()
                --    Utils:audio("siren", true, true, 1, self.sirenPitch)
                --end)
            end
            self.frameCount = self.frameCount + 1
        elseif self.currentLevelInfo.level== 0 then
            if Utils.input.right == true or Utils.input.left == true or Utils.input.up == true or Utils.input.down == true or Utils.input.start == true then
                self.currentLevelInfo.level= -1
                self.drawables["gameover"] = nil
                self.drawables["pressanykey"] = nil

                self.nameTagColor = {.2,.2,.6}
                for i=1, #self.highscores do
                    if self.highscores[i][1] == self:getNameTag() then self.nameTagColor = {.8,.6,.01} end
                end
            end

            self.nameTag[3] = time
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
                if Utils.input.start == true then
                    for _, pair in ipairs(self.highscores) do
                        if pair[1] == self:getNameTag() then
                            Utils:muteWhile("frigthtenedstart", 1)
                            return
                        end
                    end
                    self.tag = self:getNameTag()
                    self:startLevel(1, false)
                end
            end
        end
    end

    gameControl.draw = function (self, time)
        if self.currentLevelInfo.level > 0 then
            Utils:drawText("HIGH SCORE", engine.graphics.getWidth()/2, self.highScoreLabelCoords[2], self.grid.tilePX*(2.6/16), {1,1,1}, true)
            local printScore = self.highscores[1][2]
            if self.reachHighscore == true then printScore = self.score end
            Utils:drawText(printScore, engine.graphics.getWidth()/2, self.highScoreValueCoords[2], self.grid.tilePX*(2.6/16), {1,1,1}, true)
            Utils:drawText(tostring(self.score), self.scoreCounterCoords[1]-(self.grid.tilePX*(#tostring(self.ascore))), self.scoreCounterCoords[2], self.grid.tilePX*(2.6/16), {1,1,1})
            if self.tag ~= nil then
                Utils:drawText(self.tag, self.nameTagCoords[1], self.nameTagCoords[2], self.grid.tilePX*(2.6/16), {1,1,1})
            end
            for i = 0, self.lifes-2 do
                local img, scale = "pacman/r2", self.grid.tilePX*(1.8/16)
                Utils:draw(img, self.lifesCounterCoords[1]+(i*self.grid.tilePX*2)-(self.grid.tilePX), self.lifesCounterCoords[2]-(self.grid.tilePX), scale)
            end

            local lifes = self.currentLevelInfo.level-1
            if lifes > 8 then lifes = 8 end
            for i=1, lifes do
                local scale, sprite = self.grid.tilePX*(1.8/16), self.props[i][1]

                if self.currentLevelInfo.level> 8 then
                    local _sprite = i + (self.currentLevelInfo.level- 8)
                    if _sprite > 8 then _sprite = 8 end

                    sprite = self.props[_sprite][1]
                end

                local img = "props/"..sprite
                Utils:draw(img, self.levelCounterCoords[1]-((i-1)*self.grid.tilePX*2)-(self.grid.tilePX), self.levelCounterCoords[2]-(self.grid.tilePX), scale)
            end

            if self.prop ~= 0 then
                local img, scale, imgSize = "props/"..self.props[self.prop][1], self.grid.tilePX*(2/16), Utils:getImgSize("props/"..self.props[self.prop][1])
                Utils:draw(img, self.grid.propSpawnCoords[1] - (imgSize*scale/2), self.grid.propSpawnCoords[2] - (imgSize*scale/2), scale)
            end

            self.grid:draw()
            self.pacman:draw(time)
            self.ghosts.blinky:draw(time)
            self.ghosts.clyde:draw(time)
            self.ghosts.inky:draw(time)
            self.ghosts.pinky:draw(time)
        elseif self.currentLevelInfo.level< 0 then
            local img, scale, imgSize = "title", self.grid.tilePX*(2.2/16), Utils:getImgSize("title")
            Utils:draw(img, (engine.graphics.getWidth() - (imgSize*scale))/2,  40*(self.grid.tilePX/16), scale)

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

        for _, drawable in pairs(self.drawables) do
            Utils:drawText(drawable.isPopup..tostring(drawable.text), drawable.coordinates[1], drawable.coordinates[2], self.grid.tilePX*(drawable.scale/16), drawable.color, true)
        end
    end

    -- File For saving scores
    if engine.filesystem.getInfo(gameControl.savingsFile) == nil then
        engine.filesystem.write(gameControl.savingsFile, "0PAC0, 10000\n", #"0PAC0, 10000\n")
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
    local i, j, levelData, levelDataKeys = 1, 1, true, gameControl.levels.levelData
    gameControl.levels.levelData = {}
    for levelDataString in Utils.lines(leveldata) do
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

    --File for general data
    local constant, value = 1, 1
    for gameDataString in Utils.lines(gamedata) do
        j = string.find(gameDataString, ":")
        constant, value = gameDataString:sub(1, j-1), gameDataString:sub(j+1, #gameDataString)

        if constant == "defaultNametag" then
            local char = 65
            value:upper()
            for i=1, #gameControl.nameTag[2] do
                if i <= #value then
                    char = string.byte(value:sub(i,i))
                end
                gameControl.nameTag[2][i] = char
                char = 65
            end
        elseif constant == "pacmanStartDirection" then
            local coma = string.find(value, ",")
            gameControl.pacmanDir = {tonumber(value:sub(1, coma-1)), tonumber(value:sub(coma+1, #value))}
        elseif constant == "blinkyStartDirection" then
            local coma = string.find(value, ",")
            gameControl.blinkyDir = {tonumber(value:sub(1, coma-1)), tonumber(value:sub(coma+1, #value))}
        elseif constant == "screenSize" then
            gameControl.grid =  Grid.LoadGrid(gameControl, tonumber(value))
        elseif constant == "props" then
            local i = 1
            for propScore in string.gmatch(value, "([^,]+)") do
                gameControl.props[i][2] = tonumber(propScore)
                i = i + 1
            end
        else
            if string.match(value, "%D") == nil then
                gameControl[constant] = tonumber(value)
            else
                gameControl[constant] = value
            end
        end
    end
    if gameControl.startLifes > 6 then gameControl.startLifes = 6 end

    return gameControl
end

return GameControl