require "vector"

Setting = {}

SETTING_STATE = {
  IDLE = 0,
  HOVER = 1,
  SETTINGS = 2,
}

SETTING_SCREEN_STATE = {

}

local settingImage = nil
local settingScreen = nil

function Setting:new(xPos, yPos)
  local setting = {}
  local metadata = {__index = Setting}
  setmetatable(setting, metadata)

  setting.position = Vector(xPos, yPos)
  setting.size = Vector(40, 40)
  setting.state = SETTING_STATE.IDLE
  setting.screen_state = SETTING_SCREEN_STATE

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
    settingFont = love.graphics.newFont(50)
    normalFont = love.graphics.newFont(10)
    love.graphics.setFont(settingFont)

    -- if(self.screen_state == RESET_STATE.HOVER_YES) then
    --   love.graphics.setColor(1, 0.2, 0.2, 1)
    -- else
    --   love.graphics.setColor(0, 0, 0, 1)
    -- end
    -- love.graphics.print("YES", self.positionYES.x, self.positionYES.y)

    screen = self:loadScreen()
    quadScreen = love.graphics.newQuad(0, 0, 281, 314, screen:getDimensions())
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(screen, quadScreen, love.graphics.getWidth()/2 - 140, 140)
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

function Setting:mousePressed()
  return true
end
