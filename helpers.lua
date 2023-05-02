H = {}

S = require "scenes"

local held

function H.handleMouseMove(x, y)
  
  if lm.isDown(1) and held then
    
  end

end

function H.handleMousePress(x, y, button)
  
  local held = S.getHeld()

end

function H.handleMKeyPress(key)
  


end

return H