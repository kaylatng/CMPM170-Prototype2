require "vector"

Win = {}

WIN_STATE = {
  IDLE = 0,
  HOVER_RETRY = 1,
  HOVER_EXIT = 2,
}

local winImage = nil

function Win:new(xPos, yPos)
  local win = {}
  local metadata = {__index = Win}
  setmetatable(win, metadata)

  win.position = Vector(xPos, yPos)
  win.size = Vector(433, 320)
  win.state = WIN_STATE.IDLE

  win.positionRETRY = Vector(xPos - 150, yPos + 28)
  win.positionEXIT = Vector(xPos + 70, yPos + 28)

  return win
end

function Win:update(dt)

end

function Win:loadImage()
  if not winImage then
    winImage = love.graphics.newImage("sprites/win.png")
  end
  return winImage
end

function Win:draw()
  resetFont = love.graphics.newFont(50)
  normalFont = love.graphics.newFont(10)
  love.graphics.setFont(resetFont)
  love.graphics.setColor(1, 1, 1, 1)

  self:loadImage()
  quad = love.graphics.newQuad(0, 0, self.size.x, self.size.y, winImage:getWidth(), winImage:getHeight())
  love.graphics.draw(winImage, quad, self.position.x/2, self.position.y/2 - 50)

  if(self.state == WIN_STATE.HOVER_RETRY) then
    love.graphics.setColor(1, 0.2, 0.2, 1)
  else
    love.graphics.setColor(0, 0, 0, 1)
  end
  love.graphics.print("RETRY", self.positionRETRY.x, self.positionRETRY.y)

  if(self.state == WIN_STATE.HOVER_EXIT) then
    love.graphics.setColor(1, 0.2, 0.2, 1)
  else
    love.graphics.setColor(0, 0, 0, 1)
  end
  love.graphics.print("EXIT", self.positionEXIT.x, self.positionEXIT.y)
  love.graphics.setFont(normalFont)
  love.graphics.setColor(0, 0, 0, 1)
end

function Win:checkForMouseOverRetry(mousePos)
  return mousePos.x > self.positionRETRY.x and
        mousePos.x < self.positionRETRY.x + 155 and
        mousePos.y > self.positionRETRY.y and
        mousePos.y < self.positionRETRY.y + 40
end

function Win:checkForMouseOverExit(mousePos)
  return mousePos.x > self.positionEXIT.x and
        mousePos.x < self.positionEXIT.x + 105 and
        mousePos.y > self.positionEXIT.y and
        mousePos.y < self.positionEXIT.y + 40
end

function Win:mousePressed()
  return true
end