require "ball"
require "vector"
require "reset"


GAME_STATE = {
  IN_PLAY = 0,
  TRY_AGAIN = 1,
}
wrongSound = nil
bounceSound = nil
function love.load()
  love.window.setTitle("prototype 2")
  love.window.setMode(800, 600)
  sti = require 'libraries/sti'
  artMap = sti('background/simple.lua')
  throwSound = love.audio.newSource("sounds/throw.mp3", "static")
throwSound:setVolume(0.1)
wrongSound = love.audio.newSource("sounds/wrong.mp3", "static")
wrongSound:setVolume(0.5)
bounceSound = love.audio.newSource("sounds/bounce.mp3", "static")
bounceSound:setVolume(0.5)
switchSound = love.audio.newSource("sounds/switch.mp3", "static")
switchSound:setVolume(0.5)

  -- load object layer 
  local objectLayer = artMap.layers["Objects"]

  -- get each location
  -- if objectLayer then
  --   for _, obj in pairs(objectLayer.objects) do
  --     if obj.name == "yellowbody" then
  --       local yellowbody ={
  --         x= obj.x,
  --         y=obj.y,
  --         width = obj.width,
  --         height = obj.height,
  --         gid = obj.gid,
  --         collected = false        
  --       }
  --       table.insert(yellowbodys, yellowbody)
  --     end
  --   end
  -- end

  local centerX = love.graphics.getWidth() / 2
  local centerY = love.graphics.getHeight() / 2
  ball = Ball:new(40, 600, 0, 0, 15)
  resetPopup = Reset:new(centerX, centerY)
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

  -- draw yellow objects
  -- for _, yellowbody in ipairs(yellowbodys) do
  --   if not yellowbody.collected then 
  --     love.graphics.setColor(1,1,0)
  --     love.graphics.circle("fill", yellowbody.x + yellowbody.width/2, yellowbody.y + yellowbody.height/2, yellowbody.width/2)
  --   end
  -- end
  
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
  
  if state == GAME_STATE.TRY_AGAIN then
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    resetPopup:draw()
    return
  end

  ball:draw()
  
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
  
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.print("click ball and drag to fling | click colors to change ball color | press C to clear", 10, 10)
  love.graphics.print("Mouse: " .. tostring(mousePos.x) .. ", " .. tostring(mousePos.y))
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
  ball:move(dt)
  ball:collideWall()

  -- add for color detection
  local r, g, b = ball.rgb.r, ball.rgb.g, ball.rgb.b
  local isNotRed = math.abs(r - 1) > 0.1 or math.abs(g - 0.2) > 0.1 or math.abs(b - 0.2) > 0.1
  local isNotYellow = math.abs(r - 1) > 0.1 or math.abs(g - 1) > 0.1 or math.abs(b - 0.2) > 0.1
  local isNotBlue = math.abs(r - 0.2) > 0.1 or math.abs(g - 0.6) > 0.1 or math.abs(b - 1.0) > 0.1


  if (isTouchingRed(ball) and isNotRed) then
      resetGame()
  end
  if isTouchingYellow(ball) and isNotYellow then 
    resetGame()
  end
  if isTouchingBlue(ball) and isNotBlue then
    resetGame()
  end
  ball:drawTrail(canvas)

  if resetPopup:checkForMouseOverYes(mousePos) then
    resetPopup.state = RESET_STATE.HOVER_YES
  elseif resetPopup:checkForMouseOverNo(mousePos) then
    resetPopup.state = RESET_STATE.HOVER_NO
  else
    resetPopup.state = RESET_STATE.IDLE
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

  state = GAME_STATE.TRY_AGAIN
end
