require "ball"
require "vector"
require "reset"
require "setting"
require "win"

GAME_STATE = {
  IN_PLAY = 0,
  TRY_AGAIN = 1,
  SETTINGS = 2,
  WON = 3,
  JOY = 4,
}

local backgroundMusic
wrongSound = nil
bounceSound = nil
twinkleSound = nil
sadhorn = nil
bgm = nil

function love.load()
  normalFont = love.graphics.newFont(20)
  love.graphics.setFont(normalFont)

  love.window.setTitle("prototype 2")
  love.window.setMode(800, 600)
  sti = require 'libraries/sti'
  artMap = sti('background/easy.lua')
  throwSound = love.audio.newSource("sounds/throw.mp3", "static")
  throwSound:setVolume(0.1)
  wrongSound = love.audio.newSource("sounds/wrong.mp3", "static")
  wrongSound:setVolume(0.5)
  bounceSound = love.audio.newSource("sounds/bounce.mp3", "static")
  bounceSound:setVolume(0.5)
  switchSound = love.audio.newSource("sounds/switch.mp3", "static")
  switchSound:setVolume(0.5)
  twinkleSound = love.audio.newSource("sounds/twinkle.mp3", "static")
  twinkleSound:setVolume(0.5)
  sadhorn = love.audio.newSource("sounds/sad_horn.wav", "static")
  sadhorn:setVolume(0.5)

  backgroundMusic = love.audio.newSource("sounds/background.mp3", "stream")
  backgroundMusic:setLooping(true)
  backgroundMusic:setVolume(0.1)
  backgroundMusic:play()

  bgmJoy = love.audio.newSource("sounds/peaceful.wav", "stream")
  bgmJoy:setLooping(true)
  bgmJoy:setVolume(0.1)


  targetZones = {}
  -- load object layer 
  local objectLayer = artMap.layers["Objects"]

  -- get each location
  if objectLayer then 
    for _, obj in pairs(objectLayer.objects) do
      if obj.name == "block" then
        table.insert(targetZones, {
          x = obj.x,
          y = obj.y,
          width = obj.width,
          height = obj.height,
          covered = false,
          visible = obj.visible
        })
      end
    end
  end

  local centerX = love.graphics.getWidth() / 2
  local centerY = love.graphics.getHeight() / 2
  ball = Ball:new(40, 600, 0, 0, 15)
  resetPopup = Reset:new(centerX, centerY)
  settingButton = Setting:new(love.graphics.getWidth() - 60 + 10, love.graphics.getHeight() - 60 + 10)
  winPopup = Win:new(centerX, centerY)
  state = GAME_STATE.IN_PLAY
  
  isDragging = false
  dragStartX = 0
  dragStartY = 0
  launchPower = 10
  
  colors = {
    {1, 0.2, 0.2},    -- red
    {1, 0.6, 0.2},    -- orange
    {1, 1, 0.2},      -- yellow
    {0.2, 1, 0.2},    -- green
    {0.2, 1, 1},      -- cyan
    {0.2, 0.6, 1},    -- blue
    {0.6, 0.2, 1},    -- purple
    {1, 0.2, 0.8},    -- pink
  }
  
  colorBoxSize = 40
  colorBoxY = love.graphics.getHeight() - 50
  mousePos = nil
  
  canvas = love.graphics.newCanvas()
  love.graphics.setCanvas(canvas)
  love.graphics.clear(1, 1, 1, 0.4)
  love.graphics.setCanvas()
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  artMap:draw()
  love.graphics.draw(canvas)

  -- draw objects
  local objectLayer = artMap.layers["Objects"]
  
  counterTrue = 0
  if objectLayer then 
    for _, zone in ipairs(objectLayer.objects) do
      if zone.visible then
        counterTrue = counterTrue + 1
      end
    end
  end

  love.graphics.setColor(1, 0, 0)
  love.graphics.print("\nVisible zones: " .. counterTrue, 10, 10)

  local platformY = love.graphics.getHeight() - 60
  love.graphics.setColor(0.3, 0.3, 0.3, 1)
  love.graphics.rectangle("fill", 0, platformY, love.graphics.getWidth(), 3)
  
  -- color picker
  love.graphics.setColor(0.9, 0.9, 0.9, 1)
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 60, love.graphics.getWidth(), 60)
  
  -- color selections
  local totalWidth = #colors * (colorBoxSize + 10)
  local startX = (love.graphics.getWidth() - totalWidth) / 2
  
  for i, color in ipairs(colors) do
    local x = startX + (i - 1) * (colorBoxSize + 10)
    
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.rectangle("fill", x, colorBoxY, colorBoxSize, colorBoxSize, 5, 5)
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, colorBoxY, colorBoxSize, colorBoxSize, 5, 5)
    
    if math.abs(ball.rgb.r - color[1]) < 0.1 and 
       math.abs(ball.rgb.g - color[2]) < 0.1 and 
       math.abs(ball.rgb.b - color[3]) < 0.1 then
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.setLineWidth(4)
      love.graphics.rectangle("line", x, colorBoxY, colorBoxSize, colorBoxSize, 5, 5)
    end
  end

  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.print("click ball and drag to fling | click colors to change ball color | press C to clear", 10, 10)
  -- love.graphics.print("Mouse: " .. tostring(mousePos.x) .. ", " .. tostring(mousePos.y))
  
  if state == GAME_STATE.TRY_AGAIN then
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    resetPopup:draw()
    return
  end

  if state == GAME_STATE.SETTINGS then
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    settingButton.state = SETTING_STATE.SETTINGS
    settingButton:draw()
    return
  end

  if state == GAME_STATE.WON then
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    winPopup:draw()
    return
  end

  ball:draw()
  settingButton:draw()
  
  if isDragging then
    local mx, my = love.mouse.getPosition()
    love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.line(ball.x, ball.y, mx, my)
    
    -- draw power indicator
    local dx = ball.x - mx
    local dy = ball.y - my
    local power = math.sqrt(dx * dx + dy * dy)
    love.graphics.setColor(0, 0, 0, 1)
    -- love.graphics.print("Power: " .. math.floor(power), 10, 10)
  end
end

local colorLayers = {
  bodyRed = {r = 1.0, g = 0.2, b = 0.2},
  bodyOrange = {r = 1.0, g = 0.6, b = 0.2},
  bodyYellow = {r = 1.0, g = 1.0, b = 0.2},
  bodyGreen = {r = 0.2, g = 1.0, b = 0.2},
  bodyCyan = {r = 0.2, g = 1.0, b = 1.0},
  bodyBlue = {r = 0.2, g = 0.6, b = 1.0},
  bodyPurple = {r = 0.6, g = 0.2, b = 1.0},
  bodyMagenta = {r = 1.0, g = 0.2, b = 0.8},
} 

-- add for color detection
function isTouchingRed(ball)
  local layer = artMap.layers["bodyRED"]
  if not layer or not layer.data then return false end

  local tileX = math.floor(ball.x / artMap.tilewidth)
  local tileY = math.floor(ball.y / artMap.tileheight)

  local tile = layer.data[tileY] and layer.data[tileY][tileX]
  return tile and tile.properties and tile.properties.bodyOne
end

function isTouchingYellow(ball)
  local layer = artMap.layers["bodyYELLOW"]
  if not layer or not layer.data then return false end

  local tileX = math.floor(ball.x / artMap.tilewidth)
  local tileY = math.floor(ball.y / artMap.tileheight)

  local tile = layer.data[tileY] and layer.data[tileY][tileX]
  return tile and tile.properties and tile.properties.bodyTwo
end

function isTouchingBlue(ball)
  local layer = artMap.layers["bodyBLUE"]
  if not layer or not layer.data then return false end

  local tileX = math.floor(ball.x / artMap.tilewidth)
  local tileY = math.floor(ball.y / artMap.tileheight)

  local tile = layer.data[tileY] and layer.data[tileY][tileX]
  return tile and tile.properties and tile.properties.bodyThree
end

function love.update(dt)

  mousePos = Vector(
    love.mouse.getX(),
    love.mouse.getY()
  )

  local objectLayer = artMap.layers["Objects"]

  ball:move(dt)
  ball:collideWall()

  -- add for color detection
  local r, g, b = ball.rgb.r, ball.rgb.g, ball.rgb.b
  local isNotRed = math.abs(r - 1) > 0.1 or math.abs(g - 0.2) > 0.1 or math.abs(b - 0.2) > 0.1
  local isNotYellow = math.abs(r - 1) > 0.1 or math.abs(g - 1) > 0.1 or math.abs(b - 0.2) > 0.1
  local isNotBlue = math.abs(r - 0.2) > 0.1 or math.abs(g - 0.6) > 0.1 or math.abs(b - 1.0) > 0.1

  function isNear(x1, y1, x2, y2, radius)
    return math.abs(x1 - x2) < radius and math.abs(y1 - y2) < radius
  end

  if isTouchingRed(ball) then
    if not isNotRed then
      -- sound maybe?  -- in here is when the ball is in the correct color space -
    elseif isNotRed then
      resetGame()
    end
  end

  if isTouchingYellow(ball) then
    if not isNotYellow then 
      -- nothing here for now -  sound maybe? 
    elseif isNotYellow then
      resetGame()
    end
  end

  if isTouchingBlue(ball) then 
    if not isNotBlue then
      -- nothing here for now -  sound maybe? 
    elseif isNotBlue then
      resetGame()
    end
  end

  -- Objects stuff --
  -- /check if ball is near object 
  if objectLayer then 
    for _, obj in ipairs(artMap.layers["Objects"].objects) do
      if obj.visible and isNear(ball.x, ball.y, obj.x, obj.y, 16) then
        obj.visible = false
      end
    end
  end

   -- Check if all objects are now invisible
  if objectLayer then
    if (counterTrue == 0) then
      gamewon()
    end
  end
  

  ball:drawTrail(canvas)

  if resetPopup:checkForMouseOverYes(mousePos) then
    resetPopup.state = RESET_STATE.HOVER_YES
  elseif resetPopup:checkForMouseOverNo(mousePos) then
    resetPopup.state = RESET_STATE.HOVER_NO
  else
    resetPopup.state = RESET_STATE.IDLE
  end

  if winPopup:checkForMouseOverRetry(mousePos) then
    winPopup.state = WIN_STATE.HOVER_RETRY
  elseif winPopup:checkForMouseOverExit(mousePos) then
    winPopup.state = WIN_STATE.HOVER_EXIT
  else
    winPopup.state = WIN_STATE.IDLE
  end

  if settingButton:checkForMouseOverEasy(mousePos) then
    settingButton.screen_state = SETTING_SCREEN_STATE.HOVER_EASY
  elseif settingButton:checkForMouseOverHard(mousePos) then
    settingButton.screen_state = SETTING_SCREEN_STATE.HOVER_HARD
  elseif settingButton:checkForMouseOverExit(mousePos) then 
    settingButton.screen_state = SETTING_SCREEN_STATE.HOVER_EXIT
  elseif settingButton:checkForMouseOverJoy(mousePos) then 
    settingButton.screen_state = SETTING_SCREEN_STATE.HOVER_JOY
  else
    settingButton.screen_state = SETTING_SCREEN_STATE.IDLE
  end

  if state == GAME_STATE.IN_PLAY and settingButton:checkForMouseOver(mousePos) then
    settingButton.state = SETTING_STATE.HOVER
  else
    settingButton.state = SETTING_STATE.IDLE
  end

end

function love.mousepressed(x, y, button)
  if state == GAME_STATE.TRY_AGAIN and resetPopup:checkForMouseOverYes(mousePos) then
    state = GAME_STATE.IN_PLAY
    return
  elseif state == GAME_STATE.TRY_AGAIN and resetPopup:checkForMouseOverNo(mousePos) then
    resetPopup:pickRandomMessage()
    return
  end

  if state == GAME_STATE.WON and winPopup:checkForMouseOverRetry(mousePos) then
    switchSound:stop()
    switchSound:play()
    resetGameWin()
    return
  elseif state == GAME_STATE.WON and winPopup:checkForMouseOverExit(mousePos) then
    switchSound:stop()
    switchSound:play()
    love.event.quit()
    return
  end

  if state == GAME_STATE.IN_PLAY and settingButton:checkForMouseOver(mousePos) then
    state = GAME_STATE.SETTINGS
    settingButton.state = SETTING_STATE.SETTINGS
    switchSound:stop()
    switchSound:play()
  end

  if state == GAME_STATE.SETTINGS and settingButton:checkForMouseOverExit(mousePos) then
    state = GAME_STATE.IN_PLAY
    settingButton.state = SETTING_STATE.IDLE
    switchSound:stop()
    switchSound:play()
  end

  if state == GAME_STATE.SETTINGS and settingButton:checkForMouseOverEasy(mousePos) then
    state = GAME_STATE.IN_PLAY
    settingButton.state = SETTING_STATE.IDLE
    ball.state = BALL_STATE.MAIN
    artMap = sti('background/easy.lua')
    switchSound:stop()
    switchSound:play()
  end

  if state == GAME_STATE.SETTINGS and settingButton:checkForMouseOverHard(mousePos) then
    state = GAME_STATE.IN_PLAY
    settingButton.state = SETTING_STATE.IDLE
    ball.state = BALL_STATE.MAIN
    artMap = sti('background/simple.lua')
    switchSound:stop()
    switchSound:play()
  end

  if state == GAME_STATE.SETTINGS and settingButton:checkForMouseOverJoy(mousePos) then
    state = GAME_STATE.IN_PLAY
    settingButton.state = SETTING_STATE.IDLE
    ball.state = BALL_STATE.JOY
    artMap = sti('background/whitebackground.lua')
    bgmJoy:play()
    backgroundMusic:stop()
    switchSound:stop()
    switchSound:play()
  end
  
  if button == 1 then
    local platformY = love.graphics.getHeight() - 60
    if y > platformY then
      local totalWidth = #colors * (colorBoxSize + 10)
      local startX = (love.graphics.getWidth() - totalWidth) / 2
      
      for i, color in ipairs(colors) do
        local boxX = startX + (i - 1) * (colorBoxSize + 10)
        if x >= boxX and x <= boxX + colorBoxSize and 
           y >= colorBoxY and y <= colorBoxY + colorBoxSize then
          ball.rgb.r = color[1]
          ball.rgb.g = color[2]
          ball.rgb.b = color[3]
          switchSound:stop()
      switchSound:play()
          return
        end
      end
    end
    
    local dx = x - ball.x
    local dy = y - ball.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance <= ball.radius + 10 then
      isDragging = true
    end
  end
end

function love.mousereleased(x, y, button)
  if button == 1 and isDragging then
    isDragging = false
    
    local dx = (ball.x - x) * launchPower
    local dy = (ball.y - y) * launchPower
    
    ball.xSpeed = dx
    ball.ySpeed = dy
    throwSound:play()
  end
end

function love.keypressed(key)
  if key == "c" then
    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 0.4)
    love.graphics.setCanvas()
    ball.x = 40
    ball.y = 600
    ball.xSpeed = 0
    ball.ySpeed = 0
    ball.trail = {}
  end
  local objectLayer = artMap.layers["Objects"]
  if objectLayer then 
    for _, obj in ipairs(artMap.layers["Objects"].objects) do
      obj.visible = true
    end
  end
end

function resetGame()
  ball.x = 40
  ball.y = 600
  ball.xSpeed = 0
  ball.ySpeed = 0
  ball.rgb.r = 1
  ball.rgb.g = 0.2
  ball.rgb.b = 0.2

  ball.xSpeed = 0
  ball.ySpeed = 0
  ball.trail = {}


  love.graphics.setCanvas(canvas)
  love.graphics.clear(1, 1, 1, 0.4)

  love.graphics.setCanvas()

  local objectLayer = artMap.layers["Objects"]
  if objectLayer then 
    for _, obj in ipairs(artMap.layers["Objects"].objects) do
      obj.visible = true
    end
  end

  state = GAME_STATE.TRY_AGAIN
  sadhorn:stop()
  sadhorn:play()
  resetPopup:pickFirstRandomMessage()
end

function gamewon()
  if state ~= GAME_STATE.WON then
    state = GAME_STATE.WON
    twinkleSound:stop()
    twinkleSound:play()
  end
end

function resetGameWin()
  state = GAME_STATE.IN_PLAY
  
  ball.x = 40
  ball.y = 600
  ball.xSpeed = 0
  ball.ySpeed = 0
  ball.rgb.r = 1
  ball.rgb.g = 0.2
  ball.rgb.b = 0.2

  ball.xSpeed = 0
  ball.ySpeed = 0
  ball.trail = {}


  love.graphics.setCanvas(canvas)
  love.graphics.clear(1, 1, 1, 0.4)

  love.graphics.setCanvas()

  local objectLayer = artMap.layers["Objects"]
  if objectLayer then 
    for _, obj in ipairs(artMap.layers["Objects"].objects) do
      obj.visible = true
    end
  end
end