Pacman = { }

Pacman.LoadPacman = function (grid, initDir, gameControl)
    local pacman = {
        grid = grid,
        gameControl = gameControl,
        ghosts = nil,
        ghostsEatened = 0,

        lastFrameTime = 0,
        nextFrameTime = 0.07,
        frame = 1,
        renderSprite = "fill",
        position = {grid.pacmanGridInfo.startPosition[1], grid.pacmanGridInfo.startPosition[2]},
        velocity = 8,
        direction = initDir,
        facing = initDir,
        dirAxis = 1,
        tile = {grid.pacmanGridInfo.startTile[1], grid.pacmanGridInfo.startTile[2]},

        lockInput = false,
        isInDots = false,
        tunnel = nil,
        stoped = false,
        render = true,
        dying = false
    }

    pacman.update = function (self, dt)
        if self.stoped == true or self.gameControl.frameCount < 2 then
            return
        end

        if self.position[self.dirAxis] * self.direction[self.dirAxis] >
        (self.grid:getCoordinates(self.tile[1] + self.direction[1], self.tile[2] + self.direction[2])[self.dirAxis] + ((self.grid.tilePX-1) * (1 - self.direction[self.dirAxis])/2)) * self.direction[self.dirAxis] then
            self.tile[self.dirAxis] = self.tile[self.dirAxis] + self.direction[self.dirAxis]
            self.passedCenter = false

            if self.tunnel ~= nil then
                self.tunnel = nil
                self.lockInput = false
            end

            if self.grid:getTileContent(self.tile[1], self.tile[2]).content == self.grid.TUNNEL then
                local tunnelExit = self.grid:getTileContent(self.tile[1], self.tile[2]).tunnelExit
                self.tunnel = {tunnelExit[1], tunnelExit[2]}
                self.lockInput = true
            end
        end

        if self.ghostsEatened > 0 then
            for key, _ in pairs(self.ghosts) do
                if math.abs(self.position[1] - self.ghosts[key].position[1]) < (self.grid.tilePX/2) and math.abs(self.position[2] - self.ghosts[key].position[2]) < (self.grid.tilePX/2)
                and self.ghosts[key].state == self.gameControl.states.FRIGHTENED then
                    self.render = false
                    self.ghosts[key].render = false
                    self.gameControl:eatGhost(key, self.ghostsEatened)
                    self.ghostsEatened = self.ghostsEatened + 1
                end
            end
        end

        if self.lockInput == false then
            local isIntersection, previousDir = self.grid:getTileContent(self.tile[1], self.tile[2]).isIntersection == true, {self.direction[1], self.direction[2]}

            if self.dirAxis == 1 then--X axis current movement
                if isIntersection == true then
                    if Utils.input.up == true and (self.passedCenter == false or self.direction[1]==0) and self.grid:getTileContent(self.tile[1], self.tile[2]-1).content ~= self.grid.WALL then
                        self.dirAxis = 2
                        self.direction[2] = -1
                        self.lockInput = true
                        goto skipinput
                    end
                    if Utils.input.down == true and (self.passedCenter == false or self.direction[1]==0) and self.grid:getTileContent(self.tile[1], self.tile[2]+1).content ~= self.grid.WALL then
                        self.dirAxis = 2
                        self.direction[2] = 1
                        self.lockInput = true
                        goto skipinput
                    end
                end
                if Utils.input.left == true and self.grid:getTileContent(self.tile[1]-1, self.tile[2]).content ~= self.grid.WALL then self.direction = {-1,0} end
                if Utils.input.right == true and self.grid:getTileContent(self.tile[1]+1, self.tile[2]).content ~= self.grid.WALL then self.direction = {1,0} end
            else--Y axis current movement
                if isIntersection == true then
                    if Utils.input.left == true and (self.passedCenter == false or self.direction[2]==0) and self.grid:getTileContent(self.tile[1]-1, self.tile[2]).content ~= self.grid.WALL then
                        self.dirAxis = 1
                        self.direction[1] = -1
                        self.lockInput = true
                        goto skipinput
                    end
                    if Utils.input.right == true and (self.passedCenter == false or self.direction[2]==0) and self.grid:getTileContent(self.tile[1]+1, self.tile[2]).content ~= self.grid.WALL then
                        self.dirAxis = 1
                        self.direction[1] = 1
                        self.lockInput = true
                        goto skipinput
                    end
                end
                if Utils.input.up == true and self.grid:getTileContent(self.tile[1], self.tile[2]-1).content ~= self.grid.WALL then self.direction = {0,-1} end
                if Utils.input.down == true and self.grid:getTileContent(self.tile[1], self.tile[2]+1).content ~= self.grid.WALL then self.direction = {0,1} end
            end

            if self.direction[1] ~= previousDir[1] or self.direction[2] ~= previousDir[2] then
                self.facing = {self.direction[1], self.direction[2]}
            end

            ::skipinput::
        elseif self.tunnel == nil then
            local centerCoords, oppositeAxis = self.grid:getCenterCoordinates(self.tile[1], self.tile[2]), 1+tonumber(self.dirAxis==1 and 1 or 0)

            if self.position[oppositeAxis] * self.direction[oppositeAxis] >= centerCoords[oppositeAxis] * self.direction[oppositeAxis] then
                self.position[oppositeAxis] = centerCoords[oppositeAxis]
                self.lockInput = false
                self.direction[oppositeAxis] = 0
            end
        end

        if self.passedCenter == false then
            if self.position[self.dirAxis] * self.direction[self.dirAxis] >=
            self.grid:getCenterCoordinates(self.tile[1], self.tile[2])[self.dirAxis] * self.direction[self.dirAxis] then
                self.passedCenter = true

                if self.lockInput == false then
                    local nextTileContent = self.grid:getTileContent(self.tile[1]+self.direction[1], self.tile[2]+self.direction[2]).content
                    if nextTileContent == self.grid.WALL or nextTileContent == self.grid.BLOCK then
                        self.direction[self.dirAxis] = 0
                    end
                end
                local consumable = self.grid:getTileContent(self.tile[1], self.tile[2]).consumable
                if consumable ~= nil then
                    self.grid:consume(consumable, self.tile[1], self.tile[2])
                end

                if self.tunnel ~= nil then
                    self.tile = {self.tunnel[1], self.tunnel[2]}
                    local centerCoordinates = self.grid:getCenterCoordinates(self.tunnel[1], self.tunnel[2])
                    self.position = {centerCoordinates[1], centerCoordinates[2]}
                end
            end
        end

        if dt < .2 then
            self.position[1] = self.position[1] + (self.direction[1] * self.velocity * self.grid.tilePX * dt)
            self.position[2] = self.position[2] + (self.direction[2] * self.velocity * self.grid.tilePX * dt)
        end
    end


    pacman.draw = function (self, time)
        if self.render == false then return end

        if not self.stoped then
            if (time - self.lastFrameTime) >= self.nextFrameTime then
                self.lastFrameTime = time
                self.frame = self.frame + 1
                if self.frame > 3 then self.frame = 1 end
            end
            if self.frame ~= 3 then
                if self.dirAxis == 1 then
                    if self.direction[1] == -1 then
                        self.renderSprite = "l"..tostring(self.frame)
                    elseif self.direction[1] == 1 then
                        self.renderSprite = "r"..tostring(self.frame)
                    end
                else
                    if self.direction[2] == -1 then
                        self.renderSprite = "u"..tostring(self.frame)
                    elseif self.direction[2] == 1 then
                        self.renderSprite = "d"..tostring(self.frame)
                    end
                end
            elseif self.direction[1] ~= 0 or self.direction[2] ~= 0 then
                self.renderSprite = "fill"
            end
        end

        if self.dying == true then
            if (time - self.lastFrameTime) >= self.nextFrameTime then
                self.lastFrameTime = time
                self.frame = self.frame + 1

                if self.frame == 13 then
                    self.gameControl:pacmanDie()
                end

                self.renderSprite = "dh"..tostring(self.frame)

                if self.frame < 1 then self.renderSprite = "fill" end
            end
        end

        if self.frame < 12 then
            if self.gameControl.frameCount < 2 then
                self.renderSprite = "fill"
            end

            local img = "pacman/"..self.renderSprite
            Utils:draw(img, self.position[1]-self.grid.tilePX, self.position[2]-self.grid.tilePX, self.grid.tilePX*2/Utils:getImgSize(img))
        end
    end

    pacman.lastFrameTime = Utils:getTime()
    return pacman
end

return Pacman