WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- invoked once
function love.load()
	love.window.setMode(
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		{
			fullscreen = false,
			resizable = false,
			vsync = true
		}
	)
end

-- invoked every frame
function love.draw()
	love.graphics.printf (
		'Hello Pong!',
		0,
		WINDOW_HEIGHT / 2 - 6,
		WINDOW_WIDTH,
		'center'
	)
end
