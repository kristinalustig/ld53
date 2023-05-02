S = require "scenes"

lg = love.graphics
la = love.audio
lk = love.keyboard
lm = love.mouse

bodyLg = lg.newFont("/assets/Carlito-Regular.ttf", 30)
bodySm = lg.newFont("/assets/Carlito-Regular.ttf", 18)
bodyXsm = lg.newFont("/assets/Carlito-Regular.ttf", 16)

handLg = lg.newFont("/assets/Merienda-Light.ttf", 30)
handSm = lg.newFont("/assets/Merienda-Light.ttf", 14)

titleLg = lg.newFont("/assets/ChelseaMarket-Regular.ttf", 50)
titleSm = lg.newFont("/assets/ChelseaMarket-Regular.ttf", 20)
titleXsm = lg.newFont("/assets/ChelseaMarket-Regular.ttf", 14)

local mx
local my

function love.load()
  
  S.load()
  
  mx = 0
  my = 0
  
end

function love.update()
  
  S.update()
  
end

function love.draw()
  
  S.draw()
  
  --lg.printf(mx .. ", " .. my, mx+10, my, 100, "left")
  
end

function love.mousemoved(x, y, dx, dy, _)
  
  mx = x
  my = y
  
  S.handleMouseMove(x, y, dx, dy)
  
end

function love.mousepressed(x, y, button, _, _)
  
  S.handleMousePress(x, y, button)
  
end

function love.mousereleased(x, y, button, _, _)
  
  S.handleMouseRelease(x, y, button)
  
end

function love.keypressed(key, _, _)
  
  S.handleKeyPress(key)
  
end