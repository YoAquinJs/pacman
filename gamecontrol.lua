require("pacman")
require("ghosts")
require("grid")
require("font")

_G.Font = Font
GameControl = {}

GameControl.LoadGameControl = function ()
    local gameControl = {
        grid = nil,
        pacman = nil,
        ghosts = nil,
        states = nil,
        highscores = {},

        savingsFile = "savings/highscores",
        maxHighscores = 5,
        animVelocity = 10,
        propMaxTime=10,
        levelSprites = {"cherry","strawberry","orange","apple","melon","galaxian","bell","key"},
        levelSpritesPoints = {100,300,500,700,1000,2000,3000,5000},

        levelCounterCoords=nil,
        lifesCounterCoords=nil,
        highScoreLabelCoords=nil,
        highScoreValueCoords=nil,
        nameTagCoords=nil,
        scoreCounterCoords=nil,
        gameOverLabel=nil,

        nameTag={1, {65, 65, 65, 65, 65}, 0},
        lifes=2,
        generalState=nil,
        isFrightened=false,--Define frightened start time or false for no frightened mode
        score=0,
        currentLevel=-1,
        currentLevelInfo={},
        deathTime=0,
        winTime=0,
        propSpawnTime=0,
        propLastSpawnTime=0,
        levels = {
            {
                untilLevel = 1,
                frightenedModeTime = 7,
                phases = {{"SCATTER", 7}, {"CHASE", 20}, {"SCATTER", 7}, {"CHASE", 20}, {"SCATTER", 5}, {"CHASE", 20}, {"SCATTER", 5}, {"CHASE", -1}}
            },
            {
                untilLevel = 4,
                frightenedModeTime = 4,
                phases = {{"SCATTER", 7}, {"CHASE", 20}, {"SCATTER", 7}, {"CHASE", 20}, {"SCATTER", 5}, {"CHASE", -1}}
            },
            {
                untilLevel = -1,
                frightenedModeTime = 1.5,
                phases = {{"SCATTER", 5}, {"CHASE", 20}, {"SCATTER", 5}, {"CHASE", 20}, {"SCATTER", 5}, {"CHASE", -1}}
            },
        },
        startLevel = function (self, level, died)
            engine.timer.sleep(1)

            if level == 1 and died == false then
                self.score = 0
                self.lifes = 3
                self.grid:reloadConsumeables()
            else
                if level == self.currentLevel + 1 then
                    self.grid:reloadConsumeables()
                end
            end

            for i=1, #self.levels do
                if level <= self.levels[i].untilLevel or self.levels[i].untilLevel == -1 then
                    self.currentLevelInfo = self.levels[i]
                    goto exitLevelInfoSelector
                end
            end::exitLevelInfoSelector::

            self.pacman = Pacman.LoadPacman(self.grid, self)
            local GhostsObjs = Ghosts:LoadGhosts(self.grid, self, self.pacman)
            self.ghosts = GhostsObjs
            self.states = Ghosts.states
            self.generalState = Ghosts.states.CHASE
            self.pacman.ghosts = GhostsObjs
            self.pacman.states = Ghosts.states
            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].state = self.generalState
            end

            self.prop = 0
            self.propSpawnTime = engine.timer.getTime()
            self.currentLevel = level
        end,
        frightenedMode = function (self)
            self.isFrightened = engine.timer.getTime()

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].state = self.states.FRIGHTENED
                self.ghosts[key].nextFrameTime = 0.199
            end

            self.pacman.ghostsEatened = 1
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
            engine.timer.sleep(1)
            self.pacman.renderSprite = "fill"
            self.pacman.frame = 0
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
            self.score = self.score + (200 * ghostsEatened)
        end,
        winLevel = function (self)
            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].stoped = true
                self.ghosts[key].render = false
            end

            engine.timer.sleep(1)
            self.pacman.stoped = true
            self.pacman.render = false
            self.winTime = engine.timer.getTime()
        end
    }

    gameControl.grid =  Grid.LoadGrid(gameControl)

    gameControl.update = function (self, dt)
        if self.currentLevel > 0 then
            if self.grid.consumables == 0 then
                if engine.timer.getTime() - self.winTime > 3 then
                    engine.timer.sleep(.5)
                    self:startLevel(self.currentLevel+1, false)
                    self.grid.wallColor = {0,0,1}
                    return
                end
                if engine.timer.getTime() - self.winTime - math.floor(engine.timer.getTime() - self.winTime) > .75 then
                    self.grid.wallColor = {1,1,1}
                else
                    self.grid.wallColor = {0,0,1}
                end
            end

            if (engine.timer.getTime() - self.propSpawnTime) % 15 > 14.9 and self.prop == 0 then
                self.prop = self.currentLevel
                self.propLastSpawnTime = engine.timer.getTime()

                if self.currentLevel > 8 then
                    self.prop = 8
                end
            end

            if self.prop ~= 0  and (engine.timer.getTime() - self.propLastSpawnTime) >= self.propMaxTime then
                self.prop = 0
                self.propSpawnTime = engine.timer.getTime()
            end

            if self.prop ~= 0 and math.abs(self.pacman.position[1] - self.grid.propSpawnCoords[1]) < 5 and math.abs(self.pacman.position[2] - self.grid.propSpawnCoords[2]) < 5 then
                self.score = self.score + self.levelSpritesPoints[self.prop]
                self.prop = 0
                self.propSpawnTime = engine.timer.getTime()
            end

            -- Check for iterating between SCATTER and CHASE
            if self.isFrightened ~= false then
                if (engine.timer.getTime() - self.isFrightened) > self.currentLevelInfo.frightenedModeTime then
                    for key, _ in pairs(self.ghosts) do
                        if self.ghosts[key].state ~= self.states.EATEN then
                            self.ghosts[key].state = self.generalState
                            self.ghosts[key].nextFrameTime = 0.15
                        end
                    end

                    self.isFrightened = false
                    self.pacman.ghostsEatened = 0
                elseif (engine.timer.getTime() - self.isFrightened) > self.currentLevelInfo.frightenedModeTime-2 then
                    local changes, frightenedColor = math.floor((engine.timer.getTime() - self.isFrightened - (self.currentLevelInfo.frightenedModeTime-2))/0.3 + 0.5), "B"
                    if changes % 2 == 1 then
                        frightenedColor = "W"
                    end
                    for key, _ in pairs(self.ghosts) do
                        if self.ghosts[key].state == self.states.FRIGHTENED then
                            self.ghosts[key].frightenedColor = frightenedColor
                        end
                    end
                end
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
            Font.drawText("HIGH SCORE", love.graphics.getWidth()/2, self.highScoreLabelCoords[2], 2.6, {1,1,1}, true)
            Font.drawText(tostring(self.highscores[1][2]), love.graphics.getWidth()/2, self.highScoreValueCoords[2], 2.6, {1,1,1}, true)
            Font.drawText(tostring(self.score), self.scoreCounterCoords[1]-(self.grid.tilePX*(#tostring(self.score))), self.scoreCounterCoords[2], 2.6, {1,1,1})
            Font.drawText(self:getNameTag(), self.nameTagCoords[1], self.nameTagCoords[2], 2.6, {1,1,1})
            for i = 0, self.lifes-2 do
                engine.graphics.setColor(1,1,1)
                local img, scale = engine.graphics.newImage("sprites/pacman/r2.png"), 1.8
                img:setFilter("nearest", "nearest")
                engine.graphics.draw(img, self.lifesCounterCoords[1]+(i*self.grid.tilePX*2)-(self.grid.tilePX), self.lifesCounterCoords[2]-(self.grid.tilePX), 0, scale, scale)
            end

            for i=1, 8 do
                if self.currentLevel < i then goto exit end
                local scale, sprite = 1.8, self.levelSprites[i]

                if self.currentLevel > 8 then
                    local _sprite = i + (self.currentLevel - 8)
                    if _sprite > 8 then _sprite = 8 end

                    sprite = self.levelSprites[_sprite]
                end

                local img = engine.graphics.newImage("sprites/props/"..sprite..".png")
                engine.graphics.setColor(1,1,1)
                img:setFilter("nearest", "nearest")
                engine.graphics.draw(img, self.levelCounterCoords[1]-((i-1)*self.grid.tilePX*2)-(self.grid.tilePX), self.levelCounterCoords[2]-(self.grid.tilePX), 0, scale, scale)
            end::exit::

            if self.prop ~= 0 then
                local img = engine.graphics.newImage("sprites/props/"..self.levelSprites[self.prop]..".png")
                local imgWidth, imgHeight = img:getDimensions()

                engine.graphics.setColor(1,1,1)
                img:setFilter("nearest", "nearest")
                engine.graphics.draw(img, self.grid.propSpawnCoords[1] - (imgWidth), self.grid.propSpawnCoords[2] - (imgHeight), 0, 2, 2, 2)
            end

            self.grid:draw()
            self.pacman:draw()
            self.ghosts.blinky:draw()
            self.ghosts.clyde:draw()
            self.ghosts.inky:draw()
            self.ghosts.pinky:draw()
        elseif self.currentLevel == 0 then
            local timePastDeath = (engine.timer.getTime() - self.deathTime)
            if timePastDeath <= 1 then
                Font.drawText("GAME OVER", love.graphics.getWidth()/2, self.gameOverLabel[2], 3, {1,0,0}, true)
                self.grid:draw()
            elseif timePastDeath <= 2 then
                Font.drawText("GAME OVER", love.graphics.getWidth()/2, self.gameOverLabel[2], 3, {1,0,0}, true)
            else
                Font.drawText("GAME OVER", love.graphics.getWidth()/2, self.gameOverLabel[2], 3, {1,0,0}, true)
                Font.drawText("PRESS ANY KEY TO CONTINUE", self.pressAnyKeyLabel[1], self.pressAnyKeyLabel[2], 2, {1,1,1})
            end
        else
            Font.drawText("PACMAN", love.graphics.getWidth()/2, 20, 10, {1,1,0}, true)

            for i, char in ipairs(self.nameTag[2]) do
                local color, scale, adjust = {.9, .9, .9}, 6.5, 0
                if i == self.nameTag[1] then
                    scale = 7.5
                    adjust = 5
                    if engine.timer.getTime() - math.floor(engine.timer.getTime()) < 0.5 then
                        color = {1,1,1}
                    end
                end
                Font.drawText(string.char(char), love.graphics.getWidth()/2 + (45*(i-3)), 114 - adjust, scale, color, true)
            end

            Font.drawText("HIGH SCORES", love.graphics.getWidth()/2, 185, 4.5, {1,1,1}, true)
            for i, pair in ipairs(self.highscores) do
                local scoreStr = ""
                for _=1, 7-#tostring(pair[2]) do
                    scoreStr = scoreStr.." "
                end
                scoreStr = scoreStr..tostring(pair[2])
                Font.drawText(pair[1].." / "..scoreStr, love.graphics.getWidth()/2, 200 + (i*30), 3, {1,1,1}, true)
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