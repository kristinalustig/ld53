A = require "address"

D = {}

local numPackages

--include heavy, fragile, addressId, delivered, spriteId
function D.load()
  
  numPackages = 300
  
  A.load()
  
  local tempTable = {}
  
  for i=1, numPackages do
    local rollH = love.math.random(20)
    local rollF = love.math.random(10)
    local rollL = love.math.random(10)
    local addressId = love.math.random(117)
    local isFragile = rollF == 1
    local isHeavy = rollH == 1
    local isLarge = rollL >= 8
    local spriteId = 1
    if isFragile then
      if isHeavy then
        isHeavy = false
      end
      spriteId = 7
    end
    if isHeavy then
      spriteId = 6
    end
    if isLarge then
      if isHeavy or isFragile then
        spriteId = spriteId + 5
      else
        spriteId = math.random(8, 11)
      end
    else
      if not isHeavy and not isFragile then
        spriteId = love.math.random(7)
      end
    end
    local addr = A.getAddress(addressId)
    table.insert(tempTable, {
        spriteId,
        addr[1][love.math.random(#addr[1])], --address line 1
        addr[2], --address line 2
        addr[3], --neighborhood
        false, --delivered
        0, --xCoord
        0, --ycoord
        nil, --sprite
        0, --original X
        0, --original Y
        false, --is on truck
        i, --id
        true, --is correct
        0 --day req
      })
  end
    
  return tempTable
  
end

return D