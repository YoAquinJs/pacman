require("pacman")
require("ghosts")

GameControl = {}

GameControl.LoadGameControl = function (input)
    local gameControl = {
        grid = nil,
        pacman = nil,
        ghosts = nil,
        states = nil,
        highscores = {},

        savingsFile = "savings/highscores",
        maxHighscores = 5,
        animVelocity = 10,
        levelSprites = {"cherry","strawberry","orange","apple","melon","galaxian","bell","key"},

        levelCounterCoords=nil,
        lifesCounterCoords=nil,
        highScoreLabelCoords=nil,
        highScoreValueCoords=nil,
        nameTagCoords=nil,
        scoreCounterCoords=nil,
        nameTag="JOA",
        lifes=3,
        generalState=nil,
        isFrightened=false,--Define frightened start time or false for no frightened mode
        score=0,
        currentLevel=0,
        currentLevelInfo={},
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
        startLevel = function (self, level)
            if level == self.currentLevel then
                engine.timer.sleep(1)
            end

            for i=1, #self.levels do
                if level <= self.levels[i].untilLevel or self.levels[i].untilLevel == -1 then
                    self.currentLevelInfo = self.levels[i]
                    goto exitLevelInfoSelector
                end
            end::exitLevelInfoSelector::

            self.pacman = Pacman.LoadPacman(input, self.grid, self)
            local GhostsObjs = Ghosts:LoadGhosts(self.grid, self, self.pacman)
            self.ghosts = GhostsObjs
            self.states = Ghosts.states
            self.generalState = Ghosts.states.CHASE
            self.pacman.ghosts = GhostsObjs
            self.pacman.states = Ghosts.states

            self.currentLevel = level
        end,
        frightenedMode = function (self)
            self.isFrightened = engine.timer.getTime()

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].state = self.states.FRIGHTENED
            end

            self.pacman.ghostsEatened = 1
        end,
        serializeScores = function (self)
            local formattedValues = ""
            table.sort(self.highscores, function (k1, k2) return k1[2] > k2[2] end )

            for i, value in ipairs(self.highscores) do
                if i > self.maxHighscores then
                    goto exitHighscoreSelector
                end

                formattedValues = formattedValues..value[1]..", "..value[2].."\n"
            end::exitHighscoreSelector::

            engine.filesystem.write(self.savingsFile, formattedValues:sub(1, #formattedValues - 1))
        end,
        eatPacman = function (self)
            self.lifes = self.lifes - 1

            if self.lifes < 1 then
                --Lose
                return
            end

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].stoped = true
            end
            self.pacman.stoped = true
            self.pacman.dying = true
            engine.timer.sleep(1)
            self.pacman.renderSprite = "fill"
            self.pacman.lastFrameTime = engine.timer.getTime()
            self.pacman.frame = 0

            for key, _ in pairs(self.ghosts) do
                self.ghosts[key].render = false
            end
        end
    }

    gameControl.update = function (self, dt)
        if self.isFrightened ~= false and (engine.timer.getTime() - self.isFrightened) > self.currentLevelInfo.frightenedModeTime then
            for key, _ in pairs(self.ghosts) do
                if self.ghosts[key].state ~= self.states.EATEN then
                    self.ghosts[key].state = self.generalState
                end
            end

            self.isFrightened = false
            self.pacman.ghostsEatened = 0
        end

        self.pacman:update(dt)
        self.ghosts.blinky:update(dt)
        self.ghosts.clyde:update(dt)
        self.ghosts.inky:update(dt)
        self.ghosts.pinky:update(dt)
    end

    gameControl.draw = function (self)
        if gameControl.currentLevel > 0 then
            Font.drawText("HIGH SCORE", self.highScoreLabelCoords[1], self.highScoreLabelCoords[2], 2.6, {1,1,1})
            Font.drawText(tostring(self.highscores[1][2]), self.highScoreValueCoords[1], self.highScoreValueCoords[2], 2.6, {1,1,1})
            Font.drawText(tostring(self.score), self.scoreCounterCoords[1]-(self.grid.tilePX*(#tostring(self.score))), self.scoreCounterCoords[2], 2.6, {1,1,1})
            Font.drawText(self.nameTag, self.nameTagCoords[1], self.nameTagCoords[2], 2.6, {1,1,1})
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

            self.pacman:draw()
            self.ghosts.blinky:draw()
            self.ghosts.clyde:draw()
            self.ghosts.inky:draw()
            self.ghosts.pinky:draw()
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