Utils = {
    maxVolume = .5,
    sleeptTime = 0,
    programmedActions = {},
    images = {},
    audio = {},
    input = {
        up=false,
        down=false,
        left=false,
        right=false
    }
}

Utils.sleep = function (self, time)
    self.sleeptTime = self.sleeptTime + time
    engine.timer.sleep(time)
end

Utils.getTime = function (self)
    return engine.timer.getTime() - self.sleeptTime
end

Utils.doAfter = function (self, time, action)
    table.insert(self.programmedActions, {triggerTime=time + self:getTime(), action=action})
end

Utils.update = function (self)
    for i, action in ipairs(self.programmedActions) do
        if action.triggerTime - self:getTime() < 0  then
            action.action()
            table.remove(self.programmedActions, i)
        end
    end

    --Raspberry Pi input calculation TODO
    self.input.up    = engine.keyboard.isDown("w")
    self.input.left  = engine.keyboard.isDown("a")
    self.input.down  = engine.keyboard.isDown("s")
    self.input.right = engine.keyboard.isDown("d")
    self.input.start = engine.keyboard.isDown("space")
end

Utils.triggAudio = function (self, audio, volume, pitch, inloop, play)
    if volume == nil then volume = 1 end
    volume = volume*self.maxVolume
    if pitch == nil then pitch = 1 end
    if inloop == nil then inloop = false end

    self.audio[audio]:setVolume(volume)
    self.audio[audio]:setPitch(pitch)
    self.audio[audio]:setLooping(inloop)

    if play == true then
        self.audio[audio]:play()
    else
        self.audio[audio]:stop()
    end

    return self.audio[audio]:getDuration()
end

Utils.isPlaying = function (self, audio)
    if self.audio[audio] == nil then
        return false
    else
        return self.audio[audio]:isPlaying()
    end
end

Utils.stopAllSounds = function (self)
    for key, _ in pairs(self.audio) do
        self.audio[key]:stop()
    end
end

Utils.getImgSize = function (self, img)
    local width, _ = self.images[img]:getDimensions()
    return width
end

Utils.draw = function (self, img, x, y, scale, color, rotation)
    if rotation == nil then rotation = 0 end

    engine.graphics.setColor(color[1],color[2],color[3])
    engine.graphics.draw(self.images[img], x, y, rotation, scale, scale)
end

Utils.drawText = function (self, text, x, y, scale, color, centerd, shadowColor, rotation)
    text = string.lower(text)

    local charSize, zeroCount = 6, 0

    local isPropup = text:sub(1,1) == ":"

    if centerd == true then
        x = x - (#text*scale*charSize/2)
        if isPropup == true then
            x = x + (scale*charSize/2)
        end
    end

    for i = 1, #text do
        local char = text:sub(i,i)

        if char == " " or char == ":" then
            goto continue
        elseif char == "/" then
            char = "slash"
        elseif char == "0" and text:sub(i-1,i-1) == "0"  then
            zeroCount = zeroCount + 1
        end

        local charImg = "font/"..char
        if isPropup == true then
            charImg = "popupfont/"..char
        end

        if shadowColor ~= nil then
            self:draw(charImg, x+(charSize*(i-1)*scale) - (.36*scale), y - (.6*scale), scale*1.15, {shadowColor[1],shadowColor[2],shadowColor[3]}, rotation)
        end

        if isPropup == true then
            self:draw(charImg, x+(charSize*(i-2)*scale), y, scale, {color[1],color[2],color[3]}, rotation)
        else
            self:draw(charImg, x+(charSize*(i-1)*scale), y, scale, {color[1],color[2],color[3]}, rotation)
        end

        ::continue::
    end
end

Utils.start = function (self)
    local assetsConfigFile = assert(io.open("assets/assetsconfig", "r"))

    for assetInfo in assetsConfigFile:lines() do
        local path, key = string.match(assetInfo, "^(.-)~"), string.match(assetInfo, "~(.+)$")
        local extension = string.match(path, "%.([^%.]*)$")

        if extension == "png" then
            self.images[key] = engine.graphics.newImage(path)
            self.images[key]:setFilter("nearest", "nearest")
        elseif extension == "mp3" then
            self.audio[key] = engine.audio.newSource(path, "static")
        else
            print("Non managed asset extension being imported: ", assetInfo)
        end
    end

    assetsConfigFile:close()
end

return Utils