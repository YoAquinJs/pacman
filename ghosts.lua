Ghosts = { }

Ghosts.states = {
    SCATTER=0,
    CHASE=1,
    FRIGHTENED=2,
    EATEN=3
}

function Ghosts.Ghost (Self, grid, ghostStart, gameControl, pacman, name)
    local ghost = {
        grid = grid,
        pacman = pacman,
        gameControl = gameControl,
        name = name,

        startIdleTime = 1,
        lastFrameTime = 0,
        nextFrameTime = 0.1,
        frame = 0,
        renderSprite = "l1",
        frightenedColor="B",
        renderType = name,
        velocity = 8,
        state = Self.states.CHASE,
        position = {ghostStart.startPosition[1], ghostStart.startPosition[2]},
        direction = {0, 0},
        directionAxis = 1,
        tile = {ghostStart.startTile[1], ghostStart.startTile[2]},
        nextTile = {ghostStart.startTile[1], ghostStart.startTile[2]},
        target = {1, 1},

        loadedTime = 0,
        startTimeInSpawn = 0,
        spawn = {true, "in", true},
        tunnel = nil,
        stateDuration = 10,
        stateTimeBegin = 0,
        stoped = false,
        render = true
    }

    ghost.update = function (self, dt)
        if engine.timer.getTime() - self.loadedTime < self.startIdleTime or self.stoped == true then
            return
        end

        if engine.timer.getTime() - self.loadedTime - self.startIdleTime > self.startTimeInSpawn and self.spawn[3] == true then
            self.spawn[2] = "out"
            self.spawn[3] = false
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

        if math.abs(self.pacman.position[1] - self.position[1]) < (self.grid.tilePX/2) and math.abs(self.pacman.position[2] - self.position[2]) < (self.grid.tilePX/2)
        and self.state ~= Self.states.FRIGHTENED and self.state ~= Self.states.EATEN then
            self.gameControl:eatPacman()
        end

        if self.spawn[1] == true then
            if self.spawn[2] == "out" then
                if math.abs(self.position[1] - self.grid.ghostSpawnEntranceCoordinates[1]) >= 3 then
                    if (self.grid.ghostSpawnEntranceCoordinates[1] - self.position[1]) > 0 then
                        self.direction = {1, 0}
                    else
                        self.direction = {-1, 0}
                    end
                    self.directionAxis = 1
                elseif self.position[2] > self.grid.ghostSpawnEntranceCoordinates[2] then
                    self.direction = {0, -1}
                    self.directionAxis = 2
                else
                    self.spawn[1] = false

                    local closestDistance, nextDirection, distance = 100000, {0, 0}, 0

                    distance = math.sqrt(((self.target[1]-(self.tile[1]+1))^2) + ((self.target[2]-self.tile[2])^2))
                    if distance < closestDistance then
                        closestDistance = distance
                        nextDirection = {1, 0}
                    end
                    distance = math.sqrt(((self.target[1]-(self.tile[1]-1))^2) + ((self.target[2]-self.tile[2])^2))
                    if distance <= closestDistance then
                        closestDistance = distance
                        nextDirection = {-1, 0}
                    end

                    self.direction = {nextDirection[1], nextDirection[2]}
                    self.directionAxis = math.abs(nextDirection[1]) + math.abs(2 * nextDirection[2])
                end
            elseif self.spawn[2] == "in" then
                if self.spawn[3] == true then
                    if self.position[1] >= self.grid.ghostSpawnCenterCoordinates[1] + (self.grid.tilePX*2) then
                        self.direction = {-1, 0}
                    elseif self.position[1] <= self.grid.ghostSpawnCenterCoordinates[1] - (self.grid.tilePX*2) then
                        self.direction = {1, 0}
                    end
                else
                    if math.abs(self.position[1] - self.grid.ghostSpawnCenterCoordinates[1]) > 1 then
                        if (self.grid.ghostSpawnCenterCoordinates[1] - self.position[1]) > 0 then
                            self.direction = {1, 0}
                        else
                            self.direction = {-1, 0}
                        end
                    elseif self.position[2] < self.grid.ghostSpawnCenterCoordinates[2] then
                        self.direction = {0, 1}
                    else
                        self.spawn[2] = "out"
                        self.state = self.gameControl.generalState
                    end
                end
            end
        end

        if self.spawn[1] == false then
            if self.position[self.directionAxis] * self.direction[self.directionAxis] >=
            self.grid:getCenterCoordinates(self.nextTile[1], self.nextTile[2])[self.directionAxis] * self.direction[self.directionAxis] then
                if self.tile[2] == self.grid.eatenTargetTile[2] and (self.tile[1] == self.grid.eatenTargetTile[1] or self.tile[1] == self.grid.eatenTargetTile[1+1]) and self.state == Self.states.EATEN then
                    self.spawn = {true, "in"}
                end

                if self.grid.TILES[self.tile[1]][self.tile[2]].isIntersection == true then
                    self.target = self:getTarget()
                    local closestDistance, nextDirection, distance, possibleRoute = 100000, {0, 0}, 0, {}

                    possibleRoute[1] = self.grid:getTileContent(self.tile[1]+1, self.tile[2]) ~= self.grid.WALL and self.direction[1] ~= -1 --Right
                    possibleRoute[2] = self.grid:getTileContent(self.tile[1], self.tile[2]+1) ~= self.grid.WALL and self.direction[2] ~= -1 --Down
                    possibleRoute[3] = self.grid:getTileContent(self.tile[1]-1, self.tile[2]) ~= self.grid.WALL and self.direction[1] ~= 1 --Left
                    possibleRoute[4] = self.grid:getTileContent(self.tile[1], self.tile[2]-1) ~= self.grid.WALL and self.direction[2] ~= 1 --Up

                    if self.state == Self.states.FRIGHTENED then
                        local random = math.floor(math.random(1, 4))
                        while possibleRoute[random] == false do
                            random = math.floor(math.random(1, 4))
                        end

                        nextDirection = {(random % 2)*(2-random), (1 - (random % 2))*(3-random)}
                    else
                        if possibleRoute[1] == true then--Right
                            distance = math.sqrt(((self.target[1]-(self.tile[1]+1))^2) + ((self.target[2]-self.tile[2])^2))
                            if distance < closestDistance then
                                closestDistance = distance
                                nextDirection = {1, 0}
                            end
                        end
                        if possibleRoute[2] == true then--Down
                            distance = math.sqrt(((self.target[1]-self.tile[1])^2) + ((self.target[2]-(self.tile[2]+1))^2))
                            if distance <= closestDistance then
                                closestDistance = distance
                                nextDirection = {0, 1}
                            end
                        end
                        if possibleRoute[3] == true then--Left
                            distance = math.sqrt(((self.target[1]-(self.tile[1]-1))^2) + ((self.target[2]-self.tile[2])^2))
                            if distance <= closestDistance then
                                closestDistance = distance
                                nextDirection = {-1, 0}
                            end
                        end
                        if possibleRoute[4] == true then--Up
                            distance = math.sqrt(((self.target[1]-self.tile[1])^2) + ((self.target[2]-(self.tile[2]-1))^2))
                            if distance <= closestDistance then
                                closestDistance = distance
                                nextDirection = {0, -1}
                            end
                        end
                    end

                    self.direction = {nextDirection[1], nextDirection[2]}
                    self.directionAxis = math.abs(nextDirection[1]) + math.abs(2 * nextDirection[2])
                end

                self.nextTile[self.directionAxis] = self.nextTile[self.directionAxis] + self.direction[self.directionAxis]
                if self.tunnel ~= nil then
                    if self.pacman.tunnel ~= nil then
                        self.gameControl:eatPacman()
                    end

                    self.tile = {self.tunnel[1], self.tunnel[2]}
                    self.nextTile = {self.tunnel[1] + self.direction[1], self.tunnel[2]}
                    local centerCoordinates = self.grid:getCenterCoordinates(self.tunnel[1], self.tunnel[2])
                    self.position = {centerCoordinates[1], centerCoordinates[2]}
                    return
                end
            end
        end

        self.position[1] = self.position[1] + (self.direction[1] * self.velocity * self.grid.tilePX * dt)
        self.position[2] = self.position[2] + (self.direction[2] * self.velocity * self.grid.tilePX * dt)

        --if self.state == Self.states.FRIGHTENED then
        --    self.position[1] = self.position[1] + (self.direction[1] * self.frightenedVelocity * self.grid.tilePX * dt)
        --    self.position[2] = self.position[2] + (self.direction[2] * self.frightenedVelocity * self.grid.tilePX * dt)
        --elseif  self.state == Self.states.EATEN then
        --    self.position[1] = self.position[1] + (self.direction[1] * self.eatenVelocity * self.grid.tilePX * dt)
        --    self.position[2] = self.position[2] + (self.direction[2] * self.eatenVelocity * self.grid.tilePX * dt)
        --else
        --    self.position[1] = self.position[1] + (self.direction[1] * self.velocity * self.grid.tilePX * dt)
        --    self.position[2] = self.position[2] + (self.direction[2] * self.velocity * self.grid.tilePX * dt)
        --end
    end


    ghost.draw = function (self)
        if not self.render == true then return end

        if engine.timer.getTime() - self.loadedTime > self.startIdleTime and not self.stoped then
            if (engine.timer.getTime() - self.lastFrameTime) >= self.nextFrameTime then
                self.lastFrameTime = engine.timer.getTime()
                self.frame = self.frame + 1
                if self.frame > 2 then self.frame = 1 end
            end

            if self.state == Self.states.FRIGHTENED then
                self.renderSprite = "f"..self.frightenedColor..tostring(self.frame)
                self.renderType = "ghosts"
            elseif  self.state == Self.states.EATEN then
                if self.direction[1] == -1 then
                    self.renderSprite = "el"
                elseif self.direction[1] == 1 then
                    self.renderSprite = "er"
                elseif self.direction[2] == -1 then
                    self.renderSprite = "eu"
                elseif self.direction[2] == 1 then
                    self.renderSprite = "ed"
                end
                self.renderType = "ghosts"
            else
                if self.direction[1] == -1 then
                    self.renderSprite = "l"..tostring(self.frame)
                elseif self.direction[1] == 1 then
                    self.renderSprite = "r"..tostring(self.frame)
                elseif self.direction[2] == -1 then
                    self.renderSprite = "u"..tostring(self.frame)
                elseif self.direction[2] == 1 then
                    self.renderSprite = "d"..tostring(self.frame)
                end
                self.renderType = self.name
            end
        end
        engine.graphics.setColor(1,1,1)
        local img = engine.graphics.newImage("sprites/"..self.renderType.."/"..self.renderSprite..".png")
        local imgWidth, imgHeight = img:getDimensions()
        img:setFilter("nearest", "nearest")
        engine.graphics.draw(img, self.position[1]-self.grid.tilePX, self.position[2]-self.grid.tilePX, 0, self.grid.tilePX*2/imgWidth, self.grid.tilePX*2/imgHeight)
    end

    ghost.loadedTime = engine.timer.getTime()
    ghost.lastFrameTime = engine.timer.getTime()
    return ghost
end

Ghosts.LoadGhosts = function (Self, grid, gameControl, pacman)
    Blinky, Inky, Pinky, Clyde = Ghosts:Ghost(grid, grid.blinkyGridInfo, gameControl, pacman, "blinky"), Ghosts:Ghost(grid, grid.inkyGridInfo, gameControl, pacman, "inky"),
                                 Ghosts:Ghost(grid, grid.pinkyGridInfo, gameControl, pacman, "pinky"), Ghosts:Ghost(grid, grid.clydeGridInfo, gameControl, pacman, "clyde")

    Blinky.spawn[1] = false
    Blinky.direction = {-1, 0}
    Blinky.getTarget = function (self)
        if self.state == Self.states.SCATTER then
            return {grid.blinkyGridInfo.scatterTile[1], grid.blinkyGridInfo.scatterTile[2]}
        elseif self.state == Self.states.CHASE then
            return {pacman.tile[1], pacman.tile[2]}
        elseif self.state == Self.states.EATEN then
            return {grid.eatenTargetTile[1], grid.eatenTargetTile[2]}
        end
    end

    Pinky.spawn[2] = "out"
    Pinky.getTarget = function (self)
        if self.state == Self.states.SCATTER then
            return {grid.pinkyGridInfo.scatterTile[1], grid.pinkyGridInfo.scatterTile[2]}
        elseif self.state == Self.states.CHASE then
            if pacman.facing[2] == -1 then
                return {pacman.tile[1]-4, pacman.tile[2]-4}
            end
            return {pacman.tile[1] + (4 * pacman.facing[1]), pacman.tile[2] + (4 * pacman.facing[2])}
        elseif self.state == Self.states.EATEN then
            return {grid.eatenTargetTile[1], grid.eatenTargetTile[2]}
        end
    end

    Inky.startTimeInSpawn = 4
    Inky.direction = {1, 0}
    Inky.getTarget = function (self)
        if self.state == Self.states.SCATTER then
            return {grid.inkyGridInfo.scatterTile[1], grid.inkyGridInfo.scatterTile[2]}
        elseif self.state == Self.states.CHASE then
            local inFrontTile = {pacman.tile[1] + (2 * pacman.facing[1]), pacman.tile[2] + (2 * pacman.facing[2])}
            if pacman.facing[2] == -1 then
                inFrontTile[1] = pacman.tile[1]-2
            end

            return {math.ceil((2*inFrontTile[1])-Blinky.tile[1]), math.ceil((2*inFrontTile[2])-Blinky.tile[2])}
        elseif self.state == Self.states.EATEN then
            return {grid.eatenTargetTile[1], grid.eatenTargetTile[2]}
        end
    end

    Clyde.startTimeInSpawn = 8
    Clyde.direction = {-1, 0}
    Clyde.getTarget = function (self)
        if self.state == Self.states.SCATTER then
            return {grid.clydeGridInfo.scatterTile[1], grid.clydeGridInfo.scatterTile[2]}
        elseif self.state == Self.states.CHASE then
            if math.floor(math.sqrt((pacman.tile[1]-self.tile[1])^2 + (pacman.tile[2]-self.tile[2])^2 )) < 8 then
                return {grid.clydeGridInfo.scatterTile[1], grid.clydeGridInfo.scatterTile[2]}
            else
                return {pacman.tile[1], pacman.tile[2]}
            end
        elseif self.state == Self.states.EATEN then
            return {grid.eatenTargetTile[1], grid.eatenTargetTile[2]}
        end
    end

    return {inky=Inky, blinky=Blinky, pinky=Pinky, clyde=Clyde}
end

return Ghosts