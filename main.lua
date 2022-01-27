push = require 'push'

Class = require 'class'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

-- invoked once
function love.load()
	math.randomseed(os.time())

	love.window.setTitle('Pong')

	love.graphics.setDefaultFilter('nearest', 'nearest')

	smallFont = love.graphics.newFont('font.ttf', 8)
	-- scoreFont = love.graphics.newFont('font.ttf', 32)

	love.graphics.setFont(smallFont)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
		{
			fullscreen = false,
			resizable = false,
			vsync = true
		}
	)

	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	gameState = 'start'
end

-- invoked every frame
function love.update(dt)
	if ball:collides(player1) then
		ball.dx = -ball.dx * 1.03
		ball.x = player1.x + 5
	end

	if ball:collides(player2) then
		ball.dx = -ball.dx * 1.03
		ball.x = player2.x - 5
	end

	if ball.dy < 0 then
		-- if the ball has a negative speed in y axis (goes up), then keep it negative but randomize the value
		ball.dy = -math.random(10, 150)
	else
		-- if the ball has a positive speed in y axis (goes down), then keep it positive but randomize the value
		ball.dy = math.random(10, 150)
	end

	-- detect upper and lower screen boundary collision and reverse if collided
	if ball.y <= 0 then
		ball.y = 0
		ball.dy = -ball.dy
	end

	-- -4 to account for the ball's size
	if ball.y >= VIRTUAL_HEIGHT - 4 then
		ball.y = VIRTUAL_HEIGHT - 4
		ball.dy = -ball.dy
	end

	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
        player1.dy = 0
    end

	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
        player2.dy = 0
	end

	if gameState == 'play' then
		ball:update(dt)
    end

	player1:update(dt)
	player2:update(dt)
end

-- invoked every key press
function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            
			ball:reset()
        end
    end
end

-- invoked every frame
function love.draw()
	push:apply('start')

	love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	love.graphics.setFont(smallFont)

	love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 0, 0, VIRTUAL_WIDTH, 'center')

	if gameState == 'start' then
        love.graphics.printf('Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    end

	-- left paddle
	player1:render()
	
	-- right paddle
	player2:render()

	-- ball
	ball:render()

	push:apply('end')
end
