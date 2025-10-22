Ball = {}
Ball.__index = Ball

function Ball:new(x, y, xSpeed, ySpeed, radius)
  local ball = {
    x = x,
    y = y,
    xSpeed = xSpeed,
    ySpeed = ySpeed,
    radius = radius,
    rgb = {
      r = 1,
      g = 0.2,
      b = 0.2,
    },
    trail = {}
  }
  
  setmetatable(ball, self)
  return ball
end

function Ball:draw()
  love.graphics.setColor(self.rgb.r, self.rgb.g, self.rgb.b)
  love.graphics.circle("fill", self.x, self.y, self.radius)

  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.setLineWidth(1)
  love.graphics.circle("line", self.x, self.y, self.radius)
end

function Ball:move(dt)
  table.insert(self.trail, {x = self.x, y = self.y})
  
  if #self.trail > 50 then
    table.remove(self.trail, 1)
  end
  
  -- GRAVITY
  self.ySpeed = self.ySpeed + (800 * dt)
  
  self.x = self.x + (self.xSpeed * dt)
  self.y = self.y + (self.ySpeed * dt)
  
  -- AIR RESISTANCE
  self.xSpeed = self.xSpeed * 0.995
end

function Ball:collideWall()
  if self.x + self.radius > love.graphics.getWidth() or self.x - self.radius < 0 then
    self.xSpeed = self.xSpeed * -0.85

    if self.x + self.radius > love.graphics.getWidth() then
      self.x = love.graphics.getWidth() - self.radius
    else
      self.x = self.radius
    end
    
  end
  
  -- PLATFORM/COLOR PICKER
  local platformY = love.graphics.getHeight() - 60
  if self.y + self.radius > platformY then
    -- bounce off platform
    self.ySpeed = self.ySpeed * -0.75
    self.y = platformY - self.radius
    -- friction when rolling on platform
    self.xSpeed = self.xSpeed * 0.95
  elseif self.y - self.radius < 0 then
    -- bounce off top
    self.ySpeed = self.ySpeed * -0.75
    self.y = self.radius
  end
end

function Ball:drawTrail(canvas)
  if #self.trail > 1 then
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(self.rgb.r, self.rgb.g, self.rgb.b, 0.8)
    
    for i = 2, #self.trail do
      local alpha = (i / #self.trail) * 0.8
      love.graphics.setColor(self.rgb.r, self.rgb.g, self.rgb.b, alpha)
      love.graphics.setLineWidth(self.radius * 1.5)
      love.graphics.line(
        self.trail[i-1].x,
        self.trail[i-1].y,
        self.trail[i].x,
        self.trail[i].y
      )
    end
    
    love.graphics.setCanvas()
  end
end