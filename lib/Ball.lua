Class = require 'vendor/vrdl/hump/class'

Ball = Class {}

local function setVelocity()
    dx = math.random(2) == 1 and 100 or -100
    dy = math.random(-50, 50)

    return dx, dy
end

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- keep track of velocity
    self.dx, self.dy = setVelocity()
end

function Ball:reset(gameWidth, gameHeight)
    self.x = gameWidth / 2 - 2
    self.y = gameHeight / 2 - 2

    -- reset velocity
    self.dx, self.dy = setVelocity()
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:tostring()
    return string.format("(%d, %d)-(%d, %d)", self.x, self.y, self.dx, self.dy)
end
