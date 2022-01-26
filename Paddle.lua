Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- paddle's moving speed along the y axis
    self.dy = 0
end

function Paddle:update(dt)
    -- if the current moving speed is negative
    if self.dy < 0 then
        -- set the y position to the maximum between 0 and y + speed every frame
        -- it'll make sure that the paddle stays within the top boundary
        self.y = math.max(0, self.y + self.dy * dt)
    else
        -- set the y position to the minimum between virtual height and y + speed every frame
        -- it'll make sure that the paddle stays within the bottom boundary
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end