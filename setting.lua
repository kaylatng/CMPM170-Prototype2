require "vector"

Setting = {}

SETTING_STATE = {
  IDLE = 0,
  HOVER = 1,
  SETTINGS = 2,
}

SETTING_SCREEN_STATE = {
  IDLE = 0,
  HOVER_EASY = 1,
  HOVER_HARD = 2,
  HOVER_EXIT = 3,
  HOVER_JOY = 4,
}

local positionEASY = Vector(340, 250) 
local positionHARD = Vector(330, 305)
local positionEXIT = Vector(500, 133)
local positionJOY = Vector(385, 365)

local settingImage = nil
local settingScreen = nil

function Setting:new(xPos, yPos)
  local setting = {}
  local metadata = {__index = Setting}
  setmetatable(setting, metadata)

  setting.position = Vector(xPos, yPos)
  setting.size = Vector(40, 40)
  setting.state = SETTING_STATE.IDLE
  setting.screen_state = SETTING_SCREEN_STATE.IDLE

  return setting
end

function Setting:update(dt)

end

function Setting:loadImage()
  if not settingImage then
    settingImage = love.graphics.newImage("sprites/gear.png")
  end
  return settingImage
end

function Setting:loadScreen()
  if not settingScreen then
    settingScreen = love.graphics.newImage("sprites/setting_popup.png")
  end
  return settingScreen
end

function Setting:draw()
  if self.state == SETTING_STATE.SETTINGS then 
    screen = self:loadScreen()
    quadScreen = love.graphics.newQuad(0, 0, 281, 314, screen:getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(screen, quadScreen, love.graphics.getWidth()/2 - 140, 110)

    settingFont = love.graphics.newFont(50)
    exitFont = love.graphics.newFont(20)
    normalFont = love.graphics.newFont(20)
    love.graphics.setFont(settingFont)

    if(self.screen_state == SETTING_SCREEN_STATE.HOVER_EASY) then
      love.graphics.setColor(1, 0.2, 0.2, 1)
    else
      love.graphics.setColor(0, 0, 0, 1)
    end
    love.graphics.print("EASY", positionEASY.x, positionEASY.y)

    if(self.screen_state == SETTING_SCREEN_STATE.HOVER_HARD) then
      love.graphics.setColor(1, 0.2, 0.2, 1)
    else
      love.graphics.setColor(0, 0, 0, 1)
    end
    love.graphics.print("HARD", positionHARD.x, positionHARD.y)

    love.graphics.setFont(exitFont)
    if(self.screen_state == SETTING_SCREEN_STATE.HOVER_EXIT) then
      love.graphics.setColor(1, 0.2, 0.2, 1)
    else
      love.graphics.setColor(0, 0, 0, 1)
    end
    love.graphics.print("×", positionEXIT.x, positionEXIT.y)

    if(self.screen_state == SETTING_SCREEN_STATE.HOVER_JOY) then
      love.graphics.setColor(1, 0.2, 0.2, 1)
    else
      love.graphics.setColor(0, 0, 0, 1)
    end
    love.graphics.print("JOY", positionJOY.x, positionJOY.y)

    love.graphics.setFont(normalFont)
  else
    spritesheet = self:loadImage()
    quad = love.graphics.newQuad(0, 0, self.size.x, self.size.y, spritesheet:getDimensions())
    colorBoxSize = 40

    settingX = love.graphics.getWidth() - 60 + 10
    settingY = love.graphics.getHeight() - 60 + 10

    if self.state == SETTING_STATE.HOVER then
      love.graphics.setColor(1, 0.2, 0.2, 1)
    else 
      love.graphics.setColor(0.53, 0.53, 0.53, 1)
    end
    love.graphics.circle("fill", settingX + 20, settingY + 20, colorBoxSize/2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(spritesheet, quad, settingX, settingY)
  end

end

function Setting:checkForMouseOver(mousePos)
  return mousePos.x > self.position.x and
        mousePos.x < self.position.x + self.size.x and
        mousePos.y > self.position.y and
        mousePos.y < self.position.y + self.size.y
end

function Setting:checkForMouseOverEasy(mousePos)
  return mousePos.x > positionEASY.x and
        mousePos.x < positionEASY.x + 120 and
        mousePos.y > positionEASY.y and
        mousePos.y < positionEASY.y + 50
end

function Setting:checkForMouseOverHard(mousePos)
  return mousePos.x > positionHARD.x and
        mousePos.x < positionHARD.x + 135 and
        mousePos.y > positionHARD.y and
        mousePos.y < positionHARD.y + 50
end

function Setting:checkForMouseOverExit(mousePos)
  return mousePos.x > positionEXIT.x and
        mousePos.x < positionEXIT.x + 135 and
        mousePos.y > positionEXIT.y and
        mousePos.y < positionEXIT.y + 50
end

function Setting:checkForMouseOverJoy(mousePos)
  return mousePos.x > positionJOY.x and
        mousePos.x < positionJOY.x + 40 and
        mousePos.y > positionJOY.y and
        mousePos.y < positionJOY.y + 20
end

function Setting:mousePressed()
  return true
end
