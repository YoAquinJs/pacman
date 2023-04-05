Pacman = { }

Pacman.LoadPacman = function (grid, gameControl)
    local pacman = {
        grid = grid,
        gameControl = gameControl,
        ghosts = nil,
        states = nil,
        ghostsEatened = 0,

        startIdleTime = 1,
        lastFrameTime = 0,
        nextFrameTime = 0.07,
        frame = 0,
        renderSprite = "fill",
        position = {grid.pacmanGridInfo.startPosition[1], grid.pacmanGridInfo.startPosition[2]},
        velocity = 8,
        direction = {-1, 0},
        nextDirection = {-1, 0},
        facing = {-1, 0},
        directionAxis = 1,
        tile = {grid.pacmanGridInfo.startTile[1], grid.pacmanGridInfo.startTile[2]},
        centerTile = {grid.pacmanGridInfo.startTile[1], grid.pacmanGridInfo.startTile[2]},

        isInDots = false,
        loadedTime = 0,
        tunnel = nil,
        stoped = false,
        render = true,
        dying = false
    }

    pacman.update = function (self, dt)
        if engine.timer.getTime() - self.loadedTime < self.startIdleTime or self.stoped == true then
            return
        end

        if self.position[self.directionAxis] * self.direction[self.directionAxis] >
        (self.grid:getCoordinates(self.tile[1] + self.direction[1], self.tile[2] + self.direction[2])[self.directionAxis] + ((self.grid.tilePX-1) * (1 - self.direction[self.directionAxis])/2)) * self.direction[self.directionAxis] then
            self.tile[self.directionAxis] = self.tile[self.directionAxis] + self.direction[self.directionAxis]

            if self.tunnel ~= nil then
                self.tunnel = nil
            end

            if self.grid:getTileContent(self.tile[1], self.tile[2]).content == self.grid.TUNNEL then
                local tunnelTile = self.grid:getTileContent(self.tile[1], self.tile[2])
                self.tunnel = {tunnelTile.tunnelExit[1], tunnelTile.tunnelExit[2]}
            end
        end

        if self.ghostsEatened > 0 then
            for key, _ in pairs(self.ghosts) do
                if math.abs(self.position[1] - self.ghosts[key].position[1]) < (self.grid.tilePX/2) and math.abs(self.position[2] - self.ghosts[key].position[2]) < (self.grid.tilePX/2)
                and self.ghosts[key].state == self.states.FRIGHTENED then
                    self.render = false
                    self.ghosts[key].render = false
                    self.gameControl:eatGhost(key, self.ghostsEatened)
                    self.ghostsEatened = self.ghostsEatened + 1
                end
            end
        end

        if self.tunnel == nil then
            if Utils.input.up and self.grid:getTileContent(self.tile[1], self.tile[2] - 1).content ~= self.grid.WALL then
                self.nextDirection = {0, -1}
                if self.directionAxis == 2 then
                    self.direction[2] = -1
                end
            end
            if Utils.input.down then
                local nextTileContent = self.grid:getTileContent(self.tile[1], self.tile[2] + 1).content
                if nextTileContent ~= self.grid.WALL and nextTileContent ~= self.grid.BLOCK then
                    self.nextDirection = {0, 1}
                    if self.directionAxis == 2 then
                        self.direction[2] = 1
                    end
                end
            end
            if Utils.input.left and self.grid:getTileContent(self.tile[1] - 1, self.tile[2]).content ~= self.grid.WALL then
                self.nextDirection = {-1, 0}
                if self.directionAxis == 1 then
                    self.direction[1] = -1
                end
            end
            if Utils.input.right and self.grid:getTileContent(self.tile[1] + 1, self.tile[2]).content ~= self.grid.WALL then
                self.nextDirection = {1, 0}
                if self.directionAxis == 1 then
                    self.direction[1] = 1
                end
            end
        end

        if self.position[self.directionAxis] * self.direction[self.directionAxis] >=
           self.grid:getCenterCoordinates(self.centerTile[1], self.centerTile[2])[self.directionAxis] * self.direction[self.directionAxis] then

            if self.direction[1] ~= 0 or self.direction[2] ~= 0 then
                self.centerTile[self.directionAxis] = self.centerTile[self.directionAxis] + self.direction[self.directionAxis]
            end
            local nextTileContent = self.grid:getTileContent(self.tile[1] + self.nextDirection[1], self.tile[2] + self.nextDirection[2]).content
            if nextTileContent ~= self.grid.WALL and nextTileContent ~= self.grid.BLOCK then
                self.direction = {self.nextDirection[1], self.nextDirection[2]}
                self.facing = {self.direction[1], self.direction[2]}
                self.directionAxis = math.abs(1 * self.direction[1]) + math.abs(2 * self.direction[2])
            end

            nextTileContent = self.grid:getTileContent(self.tile[1] + self.direction[1], self.tile[2] + self.direction[2]).content
            if nextTileContent == self.grid.WALL or nextTileContent == self.grid.BLOCK then
                self.direction[self.directionAxis] = 0
            end

            local consumable = self.grid:getTileContent(self.tile[1], self.tile[2]).consumable
            if consumable ~= nil then
                self.grid:consume(consumable, self.tile[1], self.tile[2])
            end

            if self.tunnel ~= nil then
                self.tile = {self.tunnel[1], self.tunnel[2]}
                self.centerTile = {self.tunnel[1] + self.direction[1], self.tunnel[2]}
                local centerCoordinates = self.grid:getCenterCoordinates(self.tunnel[1], self.tunnel[2])
                self.position = {centerCoordinates[1], centerCoordinates[2]}
            end
        end

        local centerCoords = self.grid:getCenterCoordinates(self.tile[1], self.tile[2])
        if self.direction[1] ~= 0 and self.position[2] ~= centerCoords[2] then
            self.position[2] = centerCoords[2]
        elseif self.direction[2] ~= 0 and self.position[1] ~= centerCoords[1] then
            self.position[1] = centerCoords[1]
        end

        local cornerBoost = 0
        if self.grid:getTileContent(self.tile[1], self.tile[2]).isIntersection == true then
            if ((self.nextDirection[1] ~= 0 and self.directionAxis == 2) or (self.nextDirection[2] ~= 0 and self.directionAxis == 1)) and self.passedCenter == false then
                cornerBoost = 3
            end
        end

        if dt < .2 then
            self.position[1] = self.position[1] + (self.direction[1] * (self.velocity + cornerBoost) * self.grid.tilePX * dt)
            self.position[2] = self.position[2] + (self.direction[2] * (self.velocity + cornerBoost) * self.grid.tilePX * dt)
        end
    end


    pacman.draw = function (self)
        if self.render == false then return end

        if engine.timer.getTime() - self.loadedTime > self.startIdleTime and not self.stoped then
            if (engine.timer.getTime() - self.lastFrameTime) >= self.nextFrameTime then
                self.lastFrameTime = engine.timer.getTime()
                self.frame = self.frame + 1
                if self.frame > 3 then self.frame = 1 end
            end
            if self.frame ~= 3 then
                if self.direction[1] == -1 then
                    self.renderSprite = "l"..tostring(self.frame)
                elseif self.direction[1] == 1 then
                    self.renderSprite = "r"..tostring(self.frame)
                elseif self.direction[2] == -1 then
                    self.renderSprite = "u"..tostring(self.frame)
                elseif self.direction[2] == 1 then
                    self.renderSprite = "d"..tostring(self.frame)
                end
            elseif self.direction[1] ~= 0 or self.direction[2] ~= 0 then
                self.renderSprite = "fill"
            end
        end

        if self.dying == true then
            if (engine.timer.getTime() - self.lastFrameTime) >= (self.nextFrameTime*3.5) then
                self.lastFrameTime = engine.timer.getTime()
                self.frame = self.frame + 1

                if self.frame > 13 then
                    self.gameControl:pacmanDie()
                end

                self.renderSprite = "dh"..tostring(self.frame)

                if self.frame < 1 then self.renderSprite = "fill" end
            end
        end

        if self.frame < 12 then
            local img = "pacman/"..self.renderSprite
            Utils:draw(img, self.position[1]-self.grid.tilePX+1, self.position[2]-self.grid.tilePX+1, self.grid.tilePX*2/Utils:getImgSize(img), {1,1,1})
        end
    end

    pacman.loadedTime = engine.timer.getTime()
    pacman.lastFrameTime = engine.timer.getTime()
    return pacman
end

return Pacman