Utils = {
    images = {},
    input = {
        up=false,
        down=false,
        left=false,
        right=false
    }
}

Utils.getImgSize = function (self, img)
    if self.images[img] == nil then
        self.images[img] = engine.graphics.newImage("sprites/"..img..".png")
        self.images[img]:setFilter("nearest", "nearest")
    end

    local width, _ = self.images[img]:getDimensions()
    return width
end

Utils.draw = function (self, img, x, y, scale, color, rotation)
    if rotation == nil then rotation = 0 end

    if self.images[img] == nil then
        self.images[img] = engine.graphics.newImage("sprites/"..img..".png")
        self.images[img]:setFilter("nearest", "nearest")
    end

    engine.graphics.setColor(color[1],color[2],color[3])
    engine.graphics.draw(self.images[img], x, y, rotation, scale, scale)
end

Utils.updateInput = function (self)
    --Raspberry Pi input calculation TODO
    self.input.up    = engine.keyboard.isDown("w")
    self.input.left  = engine.keyboard.isDown("a")
    self.input.down  = engine.keyboard.isDown("s")
    self.input.right = engine.keyboard.isDown("d")
    self.input.start = engine.keyboard.isDown("space")
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

return Utils