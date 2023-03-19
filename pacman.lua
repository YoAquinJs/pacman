Pacman = { }

Pacman.LoadPacman = function (input, grid, gameControl)
    local pacman = {
        input = input,
        grid = grid,
        gameControl = gameControl,
        ghosts = nil,
        states = nil,
        ghostsEatened = 0,

        startIdleTime = 1,
        lastFrameTime = 0,
        nextFrameTime = 0.1,
        frame = 0,
        renderSprite = "fill",
        position = {grid.pacmanGridInfo.startPosition[1], grid.pacmanGridInfo.startPosition[2]},
        velocity = 5, --Tiles per second
        direction = {-1, 0}, --Left at start
        nextDirection = {-1, 0},
        facing = {-1, 0},
        directionAxis = 1,
        tile = {grid.pacmanGridInfo.startTile[1], grid.pacmanGridInfo.startTile[2]},
        centerTile = {grid.pacmanGridInfo.startTile[1], grid.pacmanGridInfo.startTile[2]},

        loadedTime = 0,
        tunnel = nil,
        stoped = false,
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

            if self.grid:getTileContent(self.tile[1], self.tile[2]) == self.grid.TUNNEL then
                self.tunnel = {self.grid.TILES[self.tile[1]][self.tile[2]].tunnelExit[1], self.grid.TILES[self.tile[1]][self.tile[2]].tunnelExit[2]}
            end
        end

        if self.ghostsEatened > 0 then
            for key, _ in pairs(self.ghosts) do
                if math.abs(self.ghosts[key].position[1] - self.position[1]) < 3 and math.abs(self.ghosts[key].position[2] - self.position[2]) < 3
                and self.ghosts[key].state == self.states.FRIGHTENED then
                    self.ghosts[key].state = self.states.EATEN
                    self.gameControl.score = self.gameControl.score + (200 * self.ghostsEatened)
                    self.ghostsEatened = self.ghostsEatened + 1
                end
            end
        end

        if self.tunnel == nil then
            if self.input.up and self.grid:getTileContent(self.tile[1], self.tile[2] - 1) ~= self.grid.WALL then
                self.nextDirection = {0, -1}
                if self.directionAxis == 2 then
                    self.direction[2] = -1
                end
            end
            if self.input.down then
                local nextTileContent = self.grid:getTileContent(self.tile[1], self.tile[2] + 1)
                if nextTileContent ~= self.grid.WALL and nextTileContent ~= self.grid.BLOCK then
                    self.nextDirection = {0, 1}
                    if self.directionAxis == 2 then
                        self.direction[2] = 1
                    end
                end
            end
            if self.input.left and self.grid:getTileContent(self.tile[1] - 1, self.tile[2]) ~= self.grid.WALL then
                self.nextDirection = {-1, 0}
                if self.directionAxis == 1 then
                    self.direction[1] = -1
                end
            end
            if self.input.right and self.grid:getTileContent(self.tile[1] + 1, self.tile[2]) ~= self.grid.WALL then
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
            local nextTileContent = self.grid:getTileContent(self.tile[1] + self.nextDirection[1], self.tile[2] + self.nextDirection[2])
            if nextTileContent ~= self.grid.WALL and nextTileContent ~= self.grid.BLOCK then
                self.direction = {self.nextDirection[1], self.nextDirection[2]}
                self.facing = {self.direction[1], self.direction[2]}
                self.directionAxis = math.abs(1 * self.direction[1]) + math.abs(2 * self.direction[2])
            end

            nextTileContent = self.grid:getTileContent(self.tile[1] + self.direction[1], self.tile[2] + self.direction[2])
            if nextTileContent == self.grid.WALL or nextTileContent == self.grid.BLOCK then
                self.direction[self.directionAxis] = 0
            end

            if self.grid.TILES[self.tile[1]][self.tile[2]].consumable ~= nil then
                self.grid:consume(self.grid.TILES[self.tile[1]][self.tile[2]].consumable, self.tile[1], self.tile[2])
            end

            if self.tunnel ~= nil then
                self.tile = {self.tunnel[1], self.tunnel[2]}
                self.centerTile = {self.tunnel[1] + self.direction[1], self.tunnel[2]}
                local centerCoordinates = self.grid:getCenterCoordinates(self.tunnel[1], self.tunnel[2])
                self.position = {centerCoordinates[1], centerCoordinates[2]}
            end
        end

        self.position[1] = self.position[1] + (self.direction[1] * self.velocity * self.grid.tilePX * dt)
        self.position[2] = self.position[2] + (self.direction[2] * self.velocity * self.grid.tilePX * dt)
    end


    pacman.draw = function (self)
        if engine.timer.getTime() - self.loadedTime > self.startIdleTime and not self.stoped then
            if (engine.timer.getTime() - self.lastFrameTime) >= self.nextFrameTime then
                self.lastFrameTime = engine.timer.getTime()
                self.frame = self.frame + 1
                if self.frame > 3 then self.frame = 1 end
            end
            if self.frame ~= 3 then
                if self.facing[1] == -1 then
                    self.renderSprite = "l"..tostring(self.frame)
                elseif self.facing[1] == 1 then
                    self.renderSprite = "r"..tostring(self.frame)
                elseif self.facing[2] == -1 then
                    self.renderSprite = "u"..tostring(self.frame)
                elseif self.facing[2] == 1 then
                    self.renderSprite = "d"..tostring(self.frame)
                end
            else
                self.renderSprite = "fill"
            end
        end
        engine.graphics.setColor(1,1,1)
        local img = engine.graphics.newImage("sprites/pacman/"..self.renderSprite..".png")
        img:setFilter("nearest", "nearest")
        engine.graphics.draw(img, self.position[1]-8, self.position[2]-8, 0, 1.5, 1.5)
        --engine.graphics.setColor(1,0,0)
        --local debugCoordinates = self.grid:getCoordinates(self.tile[1], self.tile[2])       
        --engine.graphics.rectangle("line", debugCoordinates[1], debugCoordinates[2], self.grid.tilePX, self.grid.tilePX)
        --engine.graphics.setColor(0,1,0)
    end

    pacman.loadedTime = engine.timer.getTime()
    pacman.lastFrameTime = engine.timer.getTime()
    return pacman
end

return Pacman

