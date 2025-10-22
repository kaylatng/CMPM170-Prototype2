require "vector"

Reset = {}

RESET_STATE = {
  IDLE = 0,
  HOVER_YES = 1,
  HOVER_NO = 2,
  PRESSED_YES = 3,
  PRESSED_NO = 4,
}

local messages = {
    "you're kinda bad at this...",
    "wow, that was... something.",
    "did you even try?",
    "maybe gaming just isn’t your thing.",
    "yikes.",
    "skill issue.",
    "embarrassing.",
    "bro, seriously?",
    "i’ve seen NPCs do better.",
    "you call that an attempt?",
    "my grandma could beat this level.",
    "not your proudest moment, huh?",
    "you sure you’re playing with the screen on?",
    "it’s okay, failure builds character. supposedly.",
    "if failing was the goal, you’re crushing it.",
    "you missed. again.",
    "pro tip: don’t do that.",
    "pain. just pain.",
    "that was a bold strategy. it didn’t work.",
    "speedrun to failure complete!",
    "that was so bad, the code cried.",
    "i had to think of typing this failure screen message btw.",
    "good thing winning this game isn't part of your grade!",
    "...",
}
local currentMessage = ""

local resetImage = nil

function Reset:new(xPos, yPos)
  local reset = {}
  local metadata = {__index = Reset}
  setmetatable(reset, metadata)

  reset.position = Vector(xPos, yPos)
  reset.size = Vector(388, 325)
  reset.state = RESET_STATE.IDLE

  reset.positionYES = Vector(xPos - 120, yPos + 25)
  reset.positionNO = Vector(xPos + 30, yPos + 25)

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
  love.graphics.draw(resetImage, quad, self.position.x/2, self.position.y/2 - 50)

  if(self.state == RESET_STATE.HOVER_YES) then
    love.graphics.setColor(1, 0.2, 0.2, 1)
  else
    love.graphics.setColor(0, 0, 0, 1)
  end
  love.graphics.print("YES", self.positionYES.x, self.positionYES.y)

  if(self.state == RESET_STATE.HOVER_NO) then
    love.graphics.setColor(1, 0.2, 0.2, 1)
  else
    love.graphics.setColor(0, 0, 0, 1)
  end
  love.graphics.print("NO", self.positionNO.x, self.positionNO.y)
  love.graphics.setFont(normalFont)
  love.graphics.setColor(0, 0, 0, 1)
  local width = 300  -- arbitrary area width to center within
  love.graphics.printf(currentMessage, self.position.x - width / 2, self.position.y + 150, width, "center")
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

local lastMessage

function Reset:pickRandomMessage()
    local newMessage
    repeat
        newMessage = messages[love.math.random(#messages)]
    until newMessage ~= lastMessage
    lastMessage = newMessage
    currentMessage = newMessage
end