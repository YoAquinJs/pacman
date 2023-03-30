Font = {}

Font.drawText = function (text, x, y, scale, color, centerd, shadowColor, rotation)
    if rotation == nil then rotation = 0 end

    if centerd == true then
        x = x - (#text*scale*6/2)
    end

    for i = 1, #text do
        local char = text:sub(i,i)
        if char == " " then
            goto continue
        elseif char == "/" then
            char = "slash"
        end

        local img = engine.graphics.newImage("sprites/font/"..char..".png")
        img:setFilter("nearest", "nearest")
        if shadowColor ~= nil then
            engine.graphics.setColor(shadowColor[1],shadowColor[2],shadowColor[3])
            engine.graphics.draw(img, x+(6*(i-1)*scale) - (.36*scale), y - (.6*scale), rotation, scale*1.15, scale*1.15)
        end
        engine.graphics.setColor(color[1],color[2],color[3])
        engine.graphics.draw(img, x+(6*(i-1)*scale), y, rotation, scale, scale)

        ::continue::
    end
end

return Font