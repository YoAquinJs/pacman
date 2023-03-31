Font = {}

Font.drawText = function (text, x, y, scale, color, centerd, shadowColor, rotation)
    if rotation == nil then rotation = 0 end
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

        local imgCharPath = "sprites/font/"..char..".png"
        if isPropup == true then
            imgCharPath = "sprites/popupfont/"..char..".png"
        end
        local img = engine.graphics.newImage(imgCharPath)

        img:setFilter("nearest", "nearest")
        if shadowColor ~= nil then
            engine.graphics.setColor(shadowColor[1],shadowColor[2],shadowColor[3])
            engine.graphics.draw(img, x+(charSize*(i-1)*scale) - (.36*scale), y - (.6*scale), rotation, scale*1.15, scale*1.15)
        end
        engine.graphics.setColor(color[1],color[2],color[3])
        if isPropup == true then
            engine.graphics.draw(img, x+(charSize*(i-2)*scale), y, rotation, scale, scale)
        else
            engine.graphics.draw(img, x+(charSize*(i-1)*scale), y, rotation, scale, scale)
        end

        ::continue::
    end
end

return Font