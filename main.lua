--[[
GD50 2018
Pong Remake

pong-0
"The Day-0 Update"

-- Main Program --

Authors:
- Colton Ogden <cogden@cs50.harvard.edu>
- Simeon Mugisha <cmeo226@gmail.com>

Originally programmed by Atari in 1972. Features two
paddles, controlled by players, with the goal of getting
the ball past your opponent's edge. First to 10 points wins.

This version is built to more closely resemble the NES than
the original Pong machines or the Atari 2600 in terms of
resolution, though in widescreen (16:9) so it looks nicer on 
modern systems.
]] -- 

local push = require "vendor/Ulydev/push/push"
local collision = require "lib/collision"

require "lib/Ball"
require "lib/Paddle"

local windowWidth, windowHeight = 1280, 720
local gameWidth, gameHeight = 432, 243

-- speed at which we will move our paddel; multiplied by dt in update
local paddleSpeed = 200

local player1Score = 0
local player2Score = 0

local player1, player2;
local ball;

local servingPlayer = 1;
local winningPlayer;
local topScore = 3;

local gameState = 'start'

local smallFont, winningFont, scoreFont;

local sounds = {};

function love.load()
    -- using nearest-neighbour filtering in upscaling and downscaling 
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('assets/fonts/04b03.ttf', 8)
    winningFont = love.graphics.newFont('assets/fonts/04b03.ttf', 16)
    scoreFont = love.graphics.newFont('assets/fonts/04b03.ttf', 32)

    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score, player2Score = 0, 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(gameWidth - 10 - 5, gameHeight - 30 - 20, 5, 20)

    -- velocity and position variables for ball
    ball = Ball(gameWidth / 2 - 2, gameHeight / 2 - 2, 5, 5)
    servingPlayer = 1

    gameState = 'start'

    sounds.paddle_hit = love.audio.newSource('assets/audio/paddle_hit.wav', 'static')
    sounds.score = love.audio.newSource('assets/audio/score.wav', 'static')
    sounds.wall_hit = love.audio.newSource('assets/audio/wall_hit.wav', 'static')
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'space' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'

            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        elseif gameState == 'play' then
            gameState = 'serve'

            ball:reset(gameWidth, gameHeight)
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset(gameWidth, gameHeight)
            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:start()
    -- love.graphics.clear(40, 45, 52)
    -- Title
    if gameState == 'start' then
        love.graphics.printf('Princess Ney Pong!', smallFont, 0, 20, gameWidth, 'center')
    elseif gameState == 'play' then
        -- love.graphics.printf('Princess Ney Pong Play State!', smallFont, 0, 20, gameWidth, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf(string.format("Player %d Serve!", servingPlayer), smallFont, 0, 20, gameWidth, 'center')
    elseif gameState == 'done' then
        love.graphics.printf(string.format("Player %d wins!", winningPlayer), winningFont, 0, 10, gameWidth, 'center')
        love.graphics.printf("Press Space to restart!", smallFont, 0, 30, gameWidth, 'center')
    end

    -- Player 1 score
    love.graphics
        .printf(string.format("%d", player1Score), scoreFont, gameWidth / 2 - 8 - 50, gameHeight / 3, gameWidth)

    -- Player 2 score
    love.graphics.printf(string.format(" %d", player2Score), scoreFont, gameWidth / 2 - 24 + 50, gameHeight / 3,
        gameWidth)

    player1:render()
    player2:render()

    ball:render()

    displayFPS()
    displayBallLocation()

    push:finish()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'play' then
        if collision:collides(ball, player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + ball.width

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
        end

        if collision:collides(ball, player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - ball.width

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

        if ball.y >= gameHeight then
            ball.y = gameHeight - ball.height
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            if player2Score == topScore then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset(gameWidth, gameHeight)
            end
            sounds.score:play()
        end
        if ball.x > gameWidth then
            servingPlayer = 2
            player1Score = player1Score + 1
            if player1Score == topScore then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset(gameWidth, gameHeight)
            end
            sounds.score:play()
        end

    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -paddleSpeed
    elseif love.keyboard.isDown('s') then
        player1.dy = paddleSpeed
    end

    -- player 2 movement

    if ball.dx > 0 and ball.x > (gameWidth / 3) then
        local top = (player2.y)
        local bottom = (player2.y + player2.height)

        if top < ball.y and bottom > ball.y then
            player2.dy = 0
        elseif top > ball.y then
            player2.dy = -paddleSpeed
        else
            player2.dy = paddleSpeed
        end
    end

    if love.keyboard.isDown('up') then
        player2.dy = -paddleSpeed
    elseif love.keyboard.isDown('down') then
        player2.dy = paddleSpeed
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt, gameHeight)
    player2:update(dt, gameHeight)
end

function displayFPS()
    local green = {0, 255, 0, 255};
    love.graphics.printf({green, 'FPS: ' .. tostring(love.timer.getFPS())}, smallFont, 10, 10, gameWidth)
end

function displayBallLocation()
    local color = {200, 255, 40, 255};
    love.graphics.printf({color, ball:tostring()}, smallFont, 0, 10, gameWidth, 'right')
end
