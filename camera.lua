local class = require "class"

local Camera = class()

function Camera:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Camera:push()
    local w, h = love.graphics.getDimensions()

    local s = h/self.h

    love.graphics.push()

    love.graphics.scale(s)
    love.graphics.translate(self.w/2 - self.x, self.h/2-self.y)
    love.graphics.translate((w / s - self.w) / 2, 0)
end

function Camera:pop()
    love.graphics.pop()
end

function Camera:moveTo(x, y)
    self.x = x
    self.y = y
end

return Camera