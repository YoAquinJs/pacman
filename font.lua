Font = {}

Font.drawText = function (text, x, y, scale, color, rotation)
    if rotation == nil then rotation = 0 end

    for i = 1, #text do
        local char = text:sub(i,i)
        if char == " " then
            goto continue
        end
        engine.graphics.setColor(color[1],color[2],color[3])
        local img = engine.graphics.newImage("sprites/font/"..text:sub(i,i)..".png")
        img:setFilter("nearest", "nearest")
        engine.graphics.draw(img, x+(6*(i-1)*scale), y, rotation, scale, scale)

        ::continue::
    end
end

return Font