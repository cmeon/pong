Class = require 'vendor/vrdl/hump/class'

Paddle = Class {}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- keep track of velocity
    self.dy = 0
end

function Paddle:update(dt, gameHeight)
    if self.dy < 0 then
        self.y = math.max(0, self.y + (self.dy * dt))
    else
        self.y = math.min(gameHeight - self.height, self.y + (self.dy * dt))
    end
    self.dy = 0
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
