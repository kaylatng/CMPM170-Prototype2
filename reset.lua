require "vector"

Reset = {}

RESET_STATE = {
  IDLE = 0,
  HOVER = 1,
  PRESSED = 2,
}

local resetImage = nil

function Reset:new(xPos, yPos)
  local reset = {}
  local metadata = {__index = Reset}
  setmetatable(reset, metadata)

  reset.position = Vector(xPos, yPos)
  reset.size = Vector(388, 325)
  reset.state = RESET_STATE.IDLE

  reset.positionYES = Vector(xPos - 120, yPos + 40)
  reset.positionNO = Vector(xPos + 30, yPos + 40)

  return reset
end

function Reset:update(dt)

end

function Reset:loadImage()
  if not resetImage then
    resetImage = love.graphics.newImage("sprites/try_again.png")
  end
  return resetImage
end

function Reset:draw()
  resetFont = love.graphics.newFont(50)
  normalFont = love.graphics.newFont(10)
  love.graphics.setFont(resetFont)
  love.graphics.setColor(1, 1, 1, 1)

  self:loadImage()
  quad = love.graphics.newQuad(0, 0, self.size.x, self.size.y, resetImage:getWidth(), resetImage:getHeight())
  love.graphics.draw(resetImage, quad, self.position.x/2, self.position.y/2 - 30)

  if(self.state == RESET_STATE.HOVER) then
    love.graphics.setColor(1, 0.2, 0.2, 1)
  else
    love.graphics.setColor(0, 0, 0, 1)
  end
  love.graphics.print("YES", self.positionYES.x, self.positionYES.y)

  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.print("NO", self.positionNO.x, self.positionNO.y)

  love.graphics.setFont(normalFont)
end

function Reset:checkForMouseOverYes(mousePos)
  return mousePos.x > self.positionYES.x and
        mousePos.x < self.positionYES.x + 95 and
        mousePos.y > self.positionYES.y and
        mousePos.y < self.positionYES.y + 40
end

function Reset:checkForMouseOverNo(mousePos)
  return mousePos.x > self.positionNO.x and
        mousePos.x < self.positionNO.x + 70 and
        mousePos.y > self.positionNO.y and
        mousePos.y < self.positionNO.y + 40
end

function Reset:mousePressed()
  return true
end
