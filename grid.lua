Grid = {}

Grid.LoadGrid = function (gameControl, tilePX)

    local grid = {
        gameControl = gameControl,

        tilePX = tilePX,
        TILES = {},
        tunnels = {},
        biscuits={},
        pills={},
        consumables = 0,
        blinkyGridInfo = {},
        inkyGridInfo = {},
        pinkyGridInfo = {},
        clydeGridInfo = {},
        mazeColor = {1,1,1},
        getCoordOffset = {3, 2},
        mazeImgCoords = nil,
        EMPTY         = 0,
        WALL          = 1,
        BLOCK         = 2,
        BISCUIT       = 3,
        PILL          = 4,
        TUNNEL        = 5,
        WALKABLE      = 6,
        draw = function (self)
            engine.graphics.setColor(self.mazeColor[1], self.mazeColor[2], self.mazeColor[3])
            Utils:draw(self.mazeImg, self.mazeImgCoords[1], self.mazeImgCoords[2], self.tilePX/(Utils:getImgSize(self.mazeImg)/(#self.TILES-4)))

            local imgSize = Utils:getImgSize("props/dot")
            local scale = self.tilePX*2/imgSize
            engine.graphics.setColor(1,1,1)

            for _, coords in pairs(self.biscuits) do
                Utils:draw("props/dot", coords[1], coords[2], scale)
            end
            for _, coords in pairs(self.pills) do
                Utils:draw("props/pill", coords[1], coords[2], scale)
            end
        end,
        getTile = function (self, x, y)
            return {math.ceil(x/self.tilePX), math.ceil(y/self.tilePX)}
        end,
        getCoordinates = function (self, tileX, tileY)
            return {(tileX * self.tilePX) - (self.tilePX*self.getCoordOffset[1]), (tileY * self.tilePX) - (self.tilePX*self.getCoordOffset[2])}
        end,
        getTileContent = function (self, tileX, tileY)
            if self.TILES[tileX] == nil or self.TILES[tileX][tileY] == nil then
                return {content=self.EMPTY}
            end
            return self.TILES[tileX][tileY]
        end,
        getCenterCoordinates = function (self, tileX, tileY)
            local upperLeftCornerPX = self:getCoordinates(tileX, tileY)
            return {upperLeftCornerPX[1] + math.ceil(self.tilePX/2), upperLeftCornerPX[2] + math.ceil(self.tilePX/2)}
        end,
        consume = function (self, consumable, tileX, tileY)
            self.consumables = self.consumables - 1
            self.TILES[tileX][tileY].consumable = nil

            if consumable == self.PILL then
                self.gameControl:addScore(50)
                self.gameControl:frightenedMode()
                self.pills[tileX..":"..tileY] = nil
            else
                self.gameControl:addScore(10)
                self.biscuits[tileX..":"..tileY] = nil
            end

            if self.consumables == 0 then
                Utils:programAction(-1, function ()
                    self.gameControl:winLevel()
                end)
            end
        end,
        reloadConsumeables = function (self)
            self.consumables = 0
            local mapFile = assert(io.open("./datafiles/mapdata", "r"))

            local mapStr = mapFile:read("a")
            local x, y = 1, 1
            for i = 1, #mapStr do
                local c = mapStr:sub(i,i)

                if c == "\n" then
                    x = 1
                    y = y + 1
                else
                    local parsedC = tonumber(c, 10)
                    if parsedC == self.BISCUIT then
                        self.TILES[x][y].consumable = self.BISCUIT
                        self.consumables = self.consumables + 1

                        local coordinates = self:getCoordinates(x, y)
                        self.biscuits[x..":"..y] = {coordinates[1]-(self.tilePX/2), coordinates[2]-(self.tilePX/2)}
                    elseif parsedC == self.PILL then
                        self.TILES[x][y].consumable = self.PILL
                        self.consumables = self.consumables + 1

                        local coordinates = self:getCoordinates(x, y)
                        self.pills[x..":"..y] = {coordinates[1]-(self.tilePX/2), coordinates[2]-(self.tilePX/2)}
                    end

                    x = x + 1
                end
            end

            io.close(mapFile)
        end,
    }

    local mapFile = assert(io.open("./datafiles/mapdata", "r"))
    local mapStr = mapFile:read("a")

    if gameControl.isFullscreen == true then
        local width, height = engine.window.getDesktopDimensions(gameControl.display)
        grid.getCoordOffset = {1,1}
        local gridHeight = 0
        for _ in io.lines("./datafiles/mapdata") do
            gridHeight = gridHeight + 1
        end
        grid.tilePX = height / gridHeight

        for i = 1, #mapStr do
            if mapStr:sub(i+1,i+1) == "\n" then
                if Utils.gridXOffset == nil then
                    Utils.gridXOffset = (width - (grid.tilePX*i))/2
                    break
                end
            end
        end

    end

    local x, y = 1, 1
    for i = 1, #mapStr do
        local c = mapStr:sub(i,i)

        if c == "\n" then
            x = 1
            y = y + 1
        end

        if grid.TILES[x] == nil then
            grid.TILES[x] = {}
        end

        if c ~= "\n" then
            local parsedC = tonumber(c, 10)
            if parsedC ~= nil then
                grid.TILES[x][y] = {content=parsedC}

                if grid.mazeImgCoords == nil and parsedC == grid.WALL then
                    local coordinates = grid:getCoordinates(x, y)
                    grid.mazeImgCoords = {coordinates[1], coordinates[2]}
                elseif parsedC == grid.BISCUIT then
                    grid.TILES[x][y] = {content=grid.EMPTY, consumable = grid.BISCUIT, walkable = true}
                    grid.consumables = grid.consumables + 1

                    local coordinates = grid:getCoordinates(x, y)
                    grid.biscuits[x..":"..y] = {coordinates[1]-(grid.tilePX/2), coordinates[2]-(grid.tilePX/2)}
                elseif parsedC == grid.PILL then
                    grid.TILES[x][y] = {content=grid.EMPTY, consumable = grid.PILL, walkable = true}
                    grid.consumables = grid.consumables + 1

                    local coordinates = grid:getCoordinates(x, y)
                    grid.pills[x..":"..y] = {coordinates[1]-(grid.tilePX/2), coordinates[2]-(grid.tilePX/2)}
                elseif parsedC == grid.TUNNEL then
                    grid.TILES[x][y] = {content=grid.TUNNEL, tunnelHallway=true, tunnelExit={}}
                    table.insert(grid.tunnels, {x, y})
                elseif parsedC == grid.WALKABLE then
                    grid.TILES[x][y] = {content=grid.EMPTY, walkable = true}
                elseif parsedC == grid.BLOCK and grid.spawnXCenter == nil then
                    local blockCoordinates = grid:getCoordinates(x, y)
                    grid.spawnXCenter = blockCoordinates[1] + grid.tilePX
                    grid.spawnYEntrance = blockCoordinates[2] - (grid.tilePX/2)
                    grid.spawnYRange = {blockCoordinates[2] + (grid.tilePX*1.9), blockCoordinates[2] + (grid.tilePX*3.1)}
                end
            end

            if c == "M" then --Player Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY, walkable = true}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.pacmanGridInfo = {startTile={x, y}, startPosition={centerCoords[1] + (grid.tilePX/2), centerCoords[2]}}
            elseif c == "B" then --Blinky Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY, walkable=true}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.blinkyGridInfo.startTile = {x, y}
                grid.blinkyGridInfo.startPosition = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}

                grid.eatenTargetTile = {x, y}
            elseif c == "I" then --Inky Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.inkyGridInfo.startTile = {grid.blinkyGridInfo.startTile[1], grid.blinkyGridInfo.startTile[2]}
                grid.inkyGridInfo.startPosition = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}
            elseif c == "P" then --Pinky Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.pinkyGridInfo.startTile = {grid.blinkyGridInfo.startTile[1], grid.blinkyGridInfo.startTile[2]}
                grid.pinkyGridInfo.startPosition = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}
            elseif c == "C" then --Clyde Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.clydeGridInfo.startTile = {grid.blinkyGridInfo.startTile[1], grid.blinkyGridInfo.startTile[2]}
                grid.clydeGridInfo.startPosition = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}
            elseif c == "b" then --Blinky Scatter Tile
                grid.TILES[x][y] = {content=grid.EMPTY}
                grid.blinkyGridInfo.scatterTile = {x, y}
            elseif c == "i" then --Inky Scatter Tile
                grid.TILES[x][y] = {content=grid.EMPTY}
                grid.inkyGridInfo.scatterTile = {x, y}
            elseif c == "p" then --Pinky Scatter Tile
                grid.TILES[x][y] = {content=grid.EMPTY}
                grid.pinkyGridInfo.scatterTile = {x, y}
            elseif c == "c" then --Clyde Scatter Tile
                grid.TILES[x][y] = {content=grid.EMPTY}
                grid.clydeGridInfo.scatterTile = {x, y}
            elseif c == "!" then --LIFESCOUNTER 
                local lifesCounterCoords = grid:getCoordinates(x, y)
                grid.gameControl.lifesCounterCoords = {lifesCounterCoords[1], lifesCounterCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == "@" then --LEVELCOUNTER
                local levelCounterCoords = grid:getCoordinates(x, y)
                grid.gameControl.levelCounterCoords = {levelCounterCoords[1], levelCounterCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == "#" then --HIGHSCORELABEL
                local highScoreLabelCoords = grid:getCoordinates(x, y)
                grid.gameControl.highScoreLabelCoords = {highScoreLabelCoords[1], highScoreLabelCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == "$" then --HIGHSCOREVALUE
                local highScoreValueCoords = grid:getCoordinates(x, y)
                grid.gameControl.highScoreValueCoords = {highScoreValueCoords[1], highScoreValueCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == "%" then --NAMETAG
                local nameTagCoords = grid:getCoordinates(x, y)
                grid.gameControl.nameTagCoords = {nameTagCoords[1], nameTagCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == "^" then --SCORECOUNTER
                local scoreCounterCoords = grid:getCoordinates(x, y)
                grid.gameControl.scoreCounterCoords = {scoreCounterCoords[1], scoreCounterCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == "*" then --SCORECOUNTER
                local gameOverLabel = grid:getCoordinates(x, y)
                grid.gameControl.gameOverLabel = {gameOverLabel[1], gameOverLabel[2]}
                grid.TILES[x][y] = {content=grid.EMPTY, walkable = true}
            elseif c == "(" then --SCORECOUNTER
                local pressAnyKeyLabel = grid:getCoordinates(x, y)
                grid.gameControl.pressAnyKeyLabel = {pressAnyKeyLabel[1], pressAnyKeyLabel[2]}
                grid.TILES[x][y] = {content=grid.EMPTY}
            elseif c == ")" then --PROPSPAWN
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.propSpawnCoords = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}
                grid.TILES[x][y] = {content=grid.EMPTY, walkable=true}
            elseif c == "-" then --TUNNELHALLWAY
                grid.TILES[x][y] = {content=grid.EMPTY, tunnelHallway=true}
            end
            x = x + 1
        end
    end

    for y = 1, #grid.TILES[1] do
        for x = 1, #grid.TILES do

            if grid.TILES[x][y].walkable ~= nil then
                if grid.TILES[x][y-1].walkable ~= nil or grid.TILES[x][y+1].walkable ~= nil then
                    if grid.TILES[x-1][y].walkable ~= nil or grid.TILES[x+1][y].walkable ~= nil then
                        grid.TILES[x][y].isIntersection = true
                    end
                elseif grid.TILES[x-1][y].walkable ~= nil or grid.TILES[x+1][y].walkable ~= nil then
                    if grid.TILES[x][y-1].walkable ~= nil or grid.TILES[x][y+1].walkable ~= nil then
                        grid.TILES[x][y].isIntersection = true
                    end
                end
            end
        end
    end

    io.close(mapFile)

    grid.TILES[grid.tunnels[1][1]][grid.tunnels[1][2]].tunnelExit = {grid.tunnels[2][1], grid.tunnels[2][2]}
    grid.TILES[grid.tunnels[2][1]][grid.tunnels[2][2]].tunnelExit = {grid.tunnels[1][1], grid.tunnels[1][2]}

    Utils.screenMiddle = ((grid.tilePX*#grid.TILES)/2)
    return grid
end

return Grid