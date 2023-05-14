Utils = {
    maxVolume = .7,
    sleeptTime = 0,
    programmedActions = {},
    mute = false,
    gridXOffset = nil,
    images = {},
    audios = {},
    buttons = {{"left",20}, {"right",21}, {"up",22}, {"down",23}, {"start",24}},
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

Utils.cancelAction = function (self, key)
    if self.programmedActions[key] ~= nil then
        local timeLeft = self.programmedActions[key].triggerTime - self:getTime()
        self.programmedActions[key] = nil
        return timeLeft
    end
end

Utils.programAction = function (self, time, action, key)
    if key == nil then
        key = tostring(action)
    end
    if self.programmedActions[key] ~= nil then
        if key == tostring(action) then print("repeated non key action", key, debug.getinfo(2, "Sl").short_src) end
        --self:cancelAction(key)
    end
    self.programmedActions[key] = {triggerTime=time + self:getTime(), action=action}

    return key
end

Utils.update = function (self)
    local time = self:getTime()
    for key, programmedAction in pairs(self.programmedActions) do
        if programmedAction.triggerTime - time <= 0  then
            programmedAction.action()
            self.programmedActions[key] = nil
        end
    end

    local handle, i = assert(io.popen("raspi-gpio get "..self.buttonsStr)), 1

    self.input.up    = engine.keyboard.isDown("w")
    self.input.left  = engine.keyboard.isDown("a")
    self.input.down  = engine.keyboard.isDown("s")
    self.input.right = engine.keyboard.isDown("d")
    --self.input.start = engine.keyboard.isDown("space")
    for line in handle:lines() do --Char 16 is the value of the button value
        if self.buttons[i][1] ~= "start" or self.input.start ~= true then
            self.input[self.buttons[i][1]] = line:sub(16,16) == "1"
        end
        i = i + 1
    end

    handle:close()
end

Utils.audio = function (self, audio, play, inloop, volume, pitch)
    if play == false then
        self.audios[audio]:stop()
        return self.audios[audio]:getDuration()
    end

    if type(volume) ~= "number" then volume = 1 end
    if type(pitch) ~= "number" then pitch = 1 end
    if inloop == nil then inloop = false end
    if self.mute == true then volume = 0 end

    volume = volume*self.maxVolume
    self.audios[audio]:setVolume(volume)
    self.audios[audio]:setPitch(pitch)
    self.audios[audio]:setLooping(inloop)
    self.audios[audio]:play()

    return self.audios[audio]:getDuration()
end

Utils.muteWhile = function (self, audio, volume, pitch, unmute)
    if type(volume) ~= "number" then volume = 1 end
    if type(pitch) ~= "number" then pitch = 1 end
    local duration = self:audio(audio, not self.mute, false, volume, pitch)

    if self.mute == true then return duration end

    local pastVolumes = {}
    for key, _ in pairs(self.audios) do
        pastVolumes[key] = self.audios[key]:getVolume()
        if key ~= audio then
            self.audios[key]:setVolume(0)
        end
    end

    if type(unmute) ~= "number" then unmute = duration end
    self:programAction(unmute, function ()
        self.mute = false
        for key, _ in pairs(self.audios) do
            self.audios[key]:setVolume(pastVolumes[key])
        end
    end, "mute")
    self.mute = true

    return duration
end

Utils.isPlaying = function (self, audio)
    return self.audios[audio]:isPlaying()
end

Utils.stopAllSounds = function (self)
    for key, _ in pairs(self.audios) do
        self.audios[key]:stop()
    end
    self.programmedActions["mute"] = nil
    self.mute = false
end

Utils.getImgSize = function (self, img)
    local width, _ = self.images[img]:getDimensions()
    return width
end

Utils.draw = function (self, img, x, y, scale)
    engine.graphics.draw(self.images[img], x + self.gridXOffset, y, 0, scale, scale)
end

Utils.drawText = function (self, text, x, y, scale, color, centerd, shadowColor)
    text = string.lower(text)

    local charSize, zeroCount = 6, 0

    local isPropup = text:sub(1,1) == ":"

    if centerd == true then
        x = x - (#text*scale*charSize/2)
        if isPropup == true then
            x = x + (scale*charSize/2)
        end
    end

    engine.graphics.setColor(color[1],color[2],color[3])
    for i = 1, #text do
        local char = text:sub(i,i)

        if char ~= " " and char ~= ":" then
            if char == "/" then
                char = "slash"
            elseif char == "0" and text:sub(i-1,i-1) == "0"  then
                zeroCount = zeroCount + 1
            end

            local charImg = "font/"..char
            if isPropup == true then
                charImg = "popupfont/"..char
            end

            if shadowColor ~= nil then
                engine.graphics.setColor(shadowColor[1],shadowColor[2],shadowColor[3])
                self:draw(charImg, x+(charSize*(i-1)*scale) - (.36*scale), y - (.6*scale), scale*1.1)
                engine.graphics.setColor(color[1],color[2],color[3])
            end

            if isPropup == true then
                self:draw(charImg, x+(charSize*(i-2)*scale), y, scale)
            else
                self:draw(charImg, x+(charSize*(i-1)*scale), y, scale)
            end
        end
    end
end

Utils.start = function (self)
    local assetsConfigFile = assert(io.open("./datafiles/assetsdata", "r"))

    for assetInfo in assetsConfigFile:lines() do
        local path, key = string.match(assetInfo, "^(.-)~"), string.match(assetInfo, "~(.+)$")
        local extension = string.match(path, "%.([^%.]*)$")

        if extension == "png" then
            self.images[key] = engine.graphics.newImage(path)
            self.images[key]:setFilter("nearest", "nearest")
        elseif extension == "mp3" then
            self.audios[key] = engine.audio.newSource(path, "static")
        else
            print("Non managed asset extension being imported: ", assetInfo)
        end
    end

    io.close(assetsConfigFile)

    self.buttonsStr = ""
    for _, pair in ipairs(self.buttons) do
        if self.buttonsStr ~= "" then self.buttonsStr = self.buttonsStr.."," end
        self.buttonsStr = self.buttonsStr..pair[2]
    end
    io.popen("raspi-gpio set "..self.buttonsStr.." ip pd")
end

return Utils