--[[
Relies on all colliding entities to have "alix-aligned bounding boxes", which
simply means their collision boxes contain no rotation in our world space
]] --

local collision = {}

setmetatable(collision, collision)

function collision:collides(ball, paddle)
    return collision:detect(ball.x, ball.y, ball.width, ball.height, paddle.x, paddle.y, paddle.width, paddle.height)
end

function collision:detect(rect1X, rect1Y, rect1Width, rect1Height, rect2X, rect2Y, rect2Width, rect2Height)
    if (rect1X > (rect2X + rect2Width)) or (rect1X + rect1Width < rect2X) then
        return false
    end

    if (rect1Y > (rect2Y + rect2Height)) or (rect1Y + rect1Height < rect2Y) then
        return false
    end

    return true
end

return collision
