Ghosts = { }

Ghosts.states = {
    SCATTER=0,
    CHASE=1,
    FRIGHTENED=2,
    EATEN=3
}

function Ghosts.Ghost (Self, grid, ghostStart, gameControl, pacman, name, bumpsInSpawn, direction)
    local ghost = {
        grid = grid,
        pacman = pacman,
        gameControl = gameControl,
        name = name,

        lastFrameTime = 0,
        nextFrameTime = 0.15,
        frame = 1,
        renderSprite = "r1",
        frightenedColor="B",
        renderType = name,
        velocity = 8,
        bumpsInSpawn = bumpsInSpawn,
        bumps=0,
        state = Self.states.CHASE,
        position = {ghostStart.startPosition[1], ghostStart.startPosition[2]},
        direction = direction,
        directionAxis = 1,
        tile = {ghostStart.startTile[1], ghostStart.startTile[2]},
        nextTile = {ghostStart.startTile[1], ghostStart.startTile[2]},
        target = {1, 1},

        inSpawn = bumpsInSpawn ~= 0,
        spawnDir = 1,
        tunnel = nil,
        turnFrightened = false,
        stoped = false,
        render = true,
        getDirection = function (self)
            self.target = self:getTarget()
            local closestDistance, nextDirection, distance, possibleRoute = 100000, {0, 0}, 0, {}
            possibleRoute[1] = self.grid:getTileContent(self.tile[1]+1, self.tile[2]).content ~= self.grid.WALL and self.direction[1] ~= -1 --Right
            possibleRoute[2] = self.grid:getTileContent(self.tile[1], self.tile[2]+1).content ~= self.grid.WALL and self.direction[2] ~= -1 --Down
            possibleRoute[3] = self.grid:getTileContent(self.tile[1]-1, self.tile[2]).content ~= self.grid.WALL and self.direction[1] ~= 1 --Left
            possibleRoute[4] = self.grid:getTileContent(self.tile[1], self.tile[2]-1).content ~= self.grid.WALL and self.direction[2] ~= 1 --Up
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
    }

    ghost.update = function (self, dt)
        if self.stoped == true or self.gameControl.frameCount < 3 then
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

        if math.sqrt(math.pow(self.pacman.position[1] - self.position[1], 2) + math.pow(self.pacman.position[2] - self.position[2], 2)) < self.grid.tilePX/1.5 and self.state ~= Self.states.FRIGHTENED and self.state ~= Self.states.EATEN then
            self.gameControl:eatPacman()
        end

        if self.inSpawn == true then
            if self.bumps < self.bumpsInSpawn then
                if self.direction[2] == -1 and self.grid.spawnYRange[1] >= self.position[2] then
                    self.position[2] = self.grid.spawnYRange[1]
                    self.direction[2] = 1
                    self.bumps = self.bumps + 1
                    if self.bumps > self.bumpsInSpawn-1 then
                        if self.position[1] < self.grid.spawnXCenter then
                            self.direction = {1,0}
                        else
                            self.direction = {-1,0}
                        end
                    end
                elseif self.direction[2] == 1 and self.grid.spawnYRange[2] <= self.position[2] then
                    self.position[2] = self.grid.spawnYRange[2]
                    self.direction[2] = -1
                    self.bumps = self.bumps + 1
                    if self.bumps > self.bumpsInSpawn-1 then
                        if self.position[1] < self.grid.spawnXCenter then
                            self.direction = {1,0}
                        else
                            self.direction = {-1,0}
                        end
                    end
                end
            else
                if self.position[1] ~= self.grid.spawnXCenter then
                    if (self.direction[1] == -1 and self.grid.spawnXCenter >= self.position[1]) or (self.direction[1] == 1 and self.grid.spawnXCenter <= self.position[1]) then
                        self.position[1] = self.grid.spawnXCenter
                        self.direction = {0,-1*self.spawnDir}
                    end
                else
                    if self.spawnDir == -1 then
                        if self.position[2] >= self.grid.spawnYRange[2] then
                            self.position[2] = self.grid.spawnYRange[2]
                            self.spawnDir = 1
                            self.direction = {0,-1}
                            self.state = self.gameControl.generalState
                            if self.turnFrightened == true then self.state = Self.states.FRIGHTENED end

                            local anyEaten = false
                            for key, _ in pairs(self.gameControl.ghosts) do
                                if self.gameControl.ghosts[key].state == Self.states.EATEN then
                                    anyEaten = true
                                end
                            end

                            if anyEaten == false then
                                Utils:audio("eaten", false)
                                Utils:audio("siren", not self.gameControl.isFrightened, true, 1, self.gameControl.sirenPitch)
                                Utils:audio("frigthtened", self.gameControl.isFrightened, true)
                            end
                        end
                    elseif self.position[2] <= self.grid.spawnYEntrance then
                        self.position[2] = self.grid.spawnYEntrance
                        self.inSpawn = false
                        self:getDirection()
                    end
                end
            end
        else
            if self.position[self.directionAxis] * self.direction[self.directionAxis]+1 >=
            self.grid:getCenterCoordinates(self.nextTile[1], self.nextTile[2])[self.directionAxis] * self.direction[self.directionAxis] then
                if self.state == Self.states.EATEN and self.tile[2] == self.grid.eatenTargetTile[2] and (self.tile[1] == self.grid.eatenTargetTile[1] or self.tile[1] == self.grid.eatenTargetTile[1+1]) then
                    self.spawnDir = -1
                    self.inSpawn = true
                end
                if self.grid:getTileContent(self.tile[1], self.tile[2]).isIntersection == true then
                    self:getDirection()
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

        if dt < .2 then
            self.position[1] = self.position[1] + (self.direction[1] * self.velocity * self.grid.tilePX * dt)
            self.position[2] = self.position[2] + (self.direction[2] * self.velocity * self.grid.tilePX * dt)

            if self.inSpawn == false then
                local centerCoords = self.grid:getCenterCoordinates(self.tile[1], self.tile[2])
                if self.direction[1] ~= 0 and self.position[2] ~= centerCoords[2] then
                    self.position[2] = centerCoords[2]
                elseif self.direction[2] ~= 0 and self.position[1] ~= centerCoords[1] then
                    self.position[1] = centerCoords[1]
                end
            end
        end
    end


    ghost.draw = function (self, time)
        if not self.render == true then return end

        if not self.stoped then
            if (time - self.lastFrameTime) >= self.nextFrameTime then
                self.lastFrameTime = time
                self.frame = self.frame + 1
                if self.frame > 2 then self.frame = 1 end
            end

            if self.state == Self.states.FRIGHTENED then
                self.renderSprite = "f"..self.frightenedColor..tostring(self.frame)
                self.renderType = "ghosts"
            elseif self.state == Self.states.EATEN then
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

        local img = self.renderType.."/"..self.renderSprite
        Utils:draw(img, self.position[1]-self.grid.tilePX, self.position[2]-self.grid.tilePX, self.grid.tilePX*2/Utils:getImgSize(img))
    end

    ghost.lastFrameTime = Utils:getTime()

    if ghost.direction[1] == 1 then ghost.renderSprite = "r1" end
    if ghost.direction[1] == -1 then ghost.renderSprite = "l1" end
    if ghost.direction[2] == 1 then ghost.renderSprite = "b1" end
    if ghost.direction[2] == -1 then ghost.renderSprite = "u1" end

    return ghost
end

Ghosts.LoadGhosts = function (Self, grid, gameControl, pacman, blinkyDir, firstRun)
    Blinky, Inky, Pinky, Clyde = Ghosts:Ghost(grid, grid.blinkyGridInfo, gameControl, pacman, "blinky", 0, blinkyDir), nil, Ghosts:Ghost(grid, grid.pinkyGridInfo, gameControl, pacman, "pinky", 1, {0,1}), nil
    if firstRun == true then
        Inky, Clyde = Ghosts:Ghost(grid, grid.inkyGridInfo, gameControl, pacman, "inky", 14, {0,-1}), Ghosts:Ghost(grid, grid.clydeGridInfo, gameControl, pacman, "clyde", 42, {0,-1})
    else
        Inky, Clyde = Ghosts:Ghost(grid, grid.inkyGridInfo, gameControl, pacman, "inky", 4, {0,-1}), Ghosts:Ghost(grid, grid.clydeGridInfo, gameControl, pacman, "clyde", 12, {0,-1})
    end

    Blinky.getTarget = function (self)
        if self.state == Self.states.SCATTER then
            return {grid.blinkyGridInfo.scatterTile[1], grid.blinkyGridInfo.scatterTile[2]}
        elseif self.state == Self.states.CHASE then
            return {pacman.tile[1], pacman.tile[2]}
        elseif self.state == Self.states.EATEN then
            return {grid.eatenTargetTile[1], grid.eatenTargetTile[2]}
        end
    end

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