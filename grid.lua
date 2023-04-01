Grid = {}

Grid.LoadGrid = function (gameControl, tilePX)

    local grid = {
        gameControl = gameControl,

        consumableScale=0,
        dotImg = engine.graphics.newImage("sprites/props/dot.png"),
        pillImg = engine.graphics.newImage("sprites/props/pill.png"),
        tilePX = tilePX,
        TILES = {},
        tunnels = {},
        consumables = 0,
        blinkyGridInfo = {},
        inkyGridInfo = {},
        pinkyGridInfo = {},
        clydeGridInfo = {},
        mazeColor = {1,1,1},
        mazeImgCoords = nil,
        EMPTY         = 0,
        WALL          = 1,
        BLOCK         = 2,
        BISCUIT       = 3,
        PILL          = 4,
        TUNNEL        = 5,
        WALKABLE      = 6,
        draw = function (self)
            engine.graphics.setColor(self.mazeColor[1],self.mazeColor[2],self.mazeColor[3])
            local mazeImg = "map/maze.png"
            if self.gameControl.winTime ~= 0 then mazeImg = "map/winmaze.png" end

            local mazeImg = engine.graphics.newImage(mazeImg)
            local imgWidth, imgHeight = mazeImg:getDimensions()
            local scale = self.tilePX/(imgWidth/(#self.TILES-4))
            mazeImg:setFilter("nearest", "nearest")
            engine.graphics.draw(mazeImg, self.mazeImgCoords[1], self.mazeImgCoords[2], 0, scale, scale)
            for x=1,#self.TILES do
                for y=1,#self.TILES[x] do
                    engine.graphics.setColor(1,1,1)
                    local coordinates = self:getCenterCoordinates(x, y)

                    if self.TILES[x][y].consumable == self.BISCUIT then--BISCUIT
                        engine.graphics.draw(self.dotImg, coordinates[1]-(self.consumablesImgSize*self.consumableScale/2), coordinates[2]-(self.consumablesImgSize*self.consumableScale/2), 0, self.consumableScale, self.consumableScale)
                    elseif self.TILES[x][y].consumable == self.PILL then--PILL`
                        engine.graphics.draw(self.pillImg, coordinates[1]-(self.consumablesImgSize*self.consumableScale/2), coordinates[2]-(self.consumablesImgSize*self.consumableScale/2), 0, self.consumableScale, self.consumableScale)
                    end
                end
            end
        end,
        getTile = function (self, x, y)
            return {math.ceil(x/self.tilePX), math.ceil(y/self.tilePX)}
        end,
        getCoordinates = function (self, tileX, tileY)
            return {(tileX * self.tilePX) - (self.tilePX*3), (tileY * self.tilePX) - (self.tilePX*2)}
        end,
        getTileContent = function (self, tileX, tileY)
            if self.TILES[tileX] == nil or self.TILES[tileX][tileY] == nil then
                return self.EMPTY
            end
            return self.TILES[tileX][tileY].content
        end,
        getCenterCoordinates = function (self, tileX, tileY)
            local upperLeftCornerPX = self:getCoordinates(tileX, tileY)
            return {upperLeftCornerPX[1] + math.ceil(self.tilePX/2), upperLeftCornerPX[2] + math.ceil(self.tilePX/2)}
        end,
        consume = function (self, consumable, tileX, tileY)
            self.consumables = self.consumables - 1
            self.TILES[tileX][tileY].consumable = nil
            self.gameControl.score = self.gameControl.score + 10

            if consumable == self.PILL then
                self.gameControl.score = self.gameControl.score + 40
                self.gameControl:frightenedMode()
            end

            if self.consumables == 0 then
                self.gameControl:winLevel()
            end
        end,
        reloadConsumeables = function (self)
            self.consumables = 0
            local mapFile = io.open("mapdata", "r")
            assert(type(mapFile) ~= nil, "Couldnt open map file")

            ---@diagnostic disable-next-line: need-check-nil
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
                    elseif parsedC == self.PILL then
                        self.TILES[x][y].consumable = self.PILL
                        self.consumables = self.consumables + 1
                    end

                    x = x + 1
                end
            end
        end
    }

    local mapFile = io.open("mapdata", "r")
    assert(type(mapFile) ~= nil, "Couldnt open map file")

    ---@diagnostic disable-next-line: need-check-nil
    local mapStr = mapFile:read("a")
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
                elseif parsedC == grid.PILL then
                    grid.TILES[x][y] = {content=grid.EMPTY, consumable = grid.PILL, walkable = true}
                    grid.consumables = grid.consumables + 1
                elseif parsedC == grid.TUNNEL then
                    grid.TILES[x][y] = {content=grid.TUNNEL, tunnelHallway=true, tunnelExit={}}
                    table.insert(grid.tunnels, {x, y})
                elseif parsedC == grid.WALKABLE then
                    grid.TILES[x][y] = {content=grid.EMPTY, walkable = true}
                elseif parsedC == grid.BLOCK and grid.ghostSpawnCenterCoordinates == nil and grid.ghostSpawnCenterCoordinates == nil then
                    local blockCoordinates = grid:getCoordinates(x, y)
                    grid.ghostSpawnCenterCoordinates = {blockCoordinates[1] + grid.tilePX - 1, blockCoordinates[2] + (grid.tilePX * 2.5)}
                    grid.ghostSpawnEntranceCoordinates = {blockCoordinates[1] + grid.tilePX - 1, blockCoordinates[2] - (grid.tilePX/2)}end
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
                grid.inkyGridInfo.startTile = {x, y}
                grid.inkyGridInfo.startPosition = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}
            elseif c == "P" then --Pinky Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.pinkyGridInfo.startTile = {x, y}
                grid.pinkyGridInfo.startPosition = {centerCoords[1] + (grid.tilePX/2), centerCoords[2]}
            elseif c == "C" then --Clyde Grid Info
                grid.TILES[x][y] = {content=grid.EMPTY}
                local centerCoords = grid:getCenterCoordinates(x, y)
                grid.clydeGridInfo.startTile = {x, y}
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
            elseif c == "-" then --PROPSPAWN
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

    grid.dotImg:setFilter("nearest", "nearest")
    grid.pillImg:setFilter("nearest", "nearest")
    local imgWidth, imgHeight = grid.dotImg:getDimensions()
    grid.consumableScale = grid.tilePX*2/imgWidth
    grid.consumablesImgSize = imgWidth

    return grid
end

return Grid