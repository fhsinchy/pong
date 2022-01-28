push = require 'push'

Class = require 'class'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

WINNING_SCORE = 10

DEBUG = true

-- invoked once
function love.load()
	math.randomseed(os.time())

	love.window.setTitle('Pong')

	love.graphics.setDefaultFilter('nearest', 'nearest')

	smallFont = love.graphics.newFont('font.ttf', 8)
	largeFont = love.graphics.newFont('font.ttf', 16)
	scoreFont = love.graphics.newFont('font.ttf', 32)
	love.graphics.setFont(smallFont)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
		{
			fullscreen = false,
			resizable = false,
			vsync = true
		}
	)

	player1Score = 0
    player2Score = 0

	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
	
	servingPlayer = 1

	gameState = 'start'
end

-- invoked every frame
function love.update(dt)
	if gameState == 'serve' then
		-- give the ball a random speed along the y axis
		ball.dy = math.random(-50, 50)
		
		if servingPlayer == 1 then
			-- if player 1 is servicng, then the ball will have a positive speed along the x axis
			ball.dx = math.random(140, 200)
		else
			-- if player 2 is servicng, then the ball will have a negative speed along the x axis
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
		-- collision detection between the ball and player 1
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			sounds['paddle_hit']:play()
			ball.x = player1.x + 5
		end
	
		-- collision detection between the ball and player 2
		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			sounds['paddle_hit']:play()
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
			sounds['wall_hit']:play()
		end
	
		-- -4 to account for the ball's size
		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end

		-- checks if the ball has passed through the left side of the screen
		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			sounds['score']:play()

			if player2Score == WINNING_SCORE then
				gameState = 'done'
				winningPlayer = 2
			else
				ball:reset()
				gameState = 'serve'
			end
		end

		-- checks if the ball has passed through the right side of the screen
		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			sounds['score']:play()
			
			if player1Score == WINNING_SCORE then
				gameState = 'done'
				winningPlayer = 1
			else
				ball:reset()
				gameState = 'serve'
			end
		end
	end

	-- control for player 1
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	-- control for player 2
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
            gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'

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

-- invoked every frame
function love.draw()
	push:apply('start')

	love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	if DEBUG then
		showDebugInfo()
	end

	love.graphics.setFont(smallFont)

    showScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

	-- left paddle
	player1:render()
	
	-- right paddle
	player2:render()

	-- ball
	ball:render()

	push:apply('end')
end

function showDebugInfo()
	love.graphics.setFont(smallFont)

	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print('STATE: ' .. gameState, 10, 18)
end

function showScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end