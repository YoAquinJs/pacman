Input = {}

Input.getInput = function ()
    local input = {
        up=false,
        down=false,
        left=false,
        right=false,
        update = function (self)
            --Raspberry Pi input calculation TODO
            self.up    = engine.keyboard.isDown("w")
            self.left  = engine.keyboard.isDown("a")
            self.down  = engine.keyboard.isDown("s")
            self.right = engine.keyboard.isDown("d")
            self.start = engine.keyboard.isDown("space")
        end
    }

    return input
end

return Input