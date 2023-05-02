PD = require "packageData"

P = {}

local sprites
local scanner
local lateDue
local dueQ
local lateQ

--quads
local pkgSm
local pkgLg
local packagesIrregular --TODO: draw and include these
local cart
local label
local layerSelectors
local layerGrey
local layerHighlightSelector
local layerHighlightTruck

--quad helpers
local tileSize
local sheetW
local sheetH

--otherVars
local currentlyHeld
local inTruck
local daysBoxes
local areaSelected
local dayNum
local areas
local showDetails

local niceScanner
local scanCost
local showDue
local dueCost
local showLate
local lateCost
local adsBought
local adsCost

local truckXCoords
local truckYCoords
local cellWidth
local cellHeight
local isValid
local earnPerPackage

local pkgNum

function P.load()
  
  pkgNum = 9200
  
  earnPerPackage = 5
  
  sheetW = 1144
  sheetH = 832
  tileSize = 48
  
  dayNum = 1
  
  areas = {
    back = 3,
    mid = 2,
    front = 1
  }
  
  sprites = lg.newImage("/assets/sprites.png")
  scanner = lg.newImage("/assets/scanner.png")
  lateDue = lg.newImage("/assets/due-late.png")
  
  niceScanner = false
  showDue = false
  showLate = false
  adsBought = 0
  scanCost = 105
  dueCost = 40
  lateCost = 60
  adsCost = 150
  
  --quads
  pkgSm = 
  {
    CreatePackageTable(1, 0, 3),
    CreatePackageTable(1, 1, 3),
    CreatePackageTable(1, 2, 3),
    CreatePackageTable(1, 3, 3),
    CreatePackageTable(1, 4, 3),
    CreatePackageTable(1, 5, 3),
    CreatePackageTable(1, 6, 3)
  } 
  
  pkgLg = 
  {
    CreatePackageTable(2, 8, 3, 12),
    CreatePackageTable(2, 11, 3, 12),
    CreatePackageTable(2, 14, 3, 12),
    CreatePackageTable(2, 17, 3, 12),
    CreatePackageTable(2, 20, 3, 12)
  }
  
  -- 1 = TOP
  truckYCoords = {
    {187, 235, 280},
    {277, 325, 370},
    {365, 414, 458}
  }
  
  truckXCoords = {
    52, 112, 172, 230, 292
  }
  
  dueQ = lg.newQuad(0, 0, 48, 20, 96, 20)
  lateQ = lg.newQuad(48, 0, 48, 20, 96, 20)
  
  cart = lg.newQuad(0*tileSize, 7*tileSize, 7*tileSize, 6*tileSize, sheetW, sheetH)
  label = lg.newQuad(11*tileSize, 1*tileSize, 3*tileSize, 2*tileSize, sheetW, sheetH)
  layerGrey = lg.newQuad(8*tileSize, 1*tileSize, tileSize+16, tileSize+16, sheetW, sheetH)
  layerHighlightSelector = lg.newQuad(6*tileSize, 1*tileSize, tileSize+24, tileSize+24, sheetW, sheetH)
  layerHighlightTruck = lg.newQuad(16*tileSize, 11*tileSize, 7*tileSize, 3*tileSize, sheetW, sheetH)
  
  allPackages = PD.load()
    
  --otherVars
  currentlyHeld = nil
  daysBoxes = GetPackages(dayNum)
  
  areaSelected = areas.back
  
  inTruck = CreateTruckBed()
  
  DayStart()
  
  isValid = true
  
end

function P.update()
  
  ArrangePackages()
  local temp = isValid
  isValid = CheckPackageRules()
  if temp and not isValid then
    return "bad"
  end
  
end

function P.draw()
  
  if not isValid then
    --show an error
    lg.setFont(titleXsm)
    lg.setColor(238/255, 117/255, 117/255)
    lg.printf("Packing issues, box safety not guaranteed.", 14, 124, 379, "center")
    lg.reset()
 end
  
  for k, v in ipairs(daysBoxes) do
    if currentlyHeld ~= v and not v[11] then
      lg.draw(sprites, v[8], v[6], v[7])
      if dayNum - v[14] == 1 then
        lg.draw(lateDue, dueQ, v[6], v[7])
        lg.setFont(titleXsm)
        lg.setColor(0, 0, 0)
        lg.printf("DUE", v[6], v[7], 48, "center")
      elseif v[14] < dayNum then
        lg.draw(lateDue, lateQ, v[6], v[7])
        lg.setFont(titleXsm)
        lg.setColor(0, 0, 0)
        lg.printf("LATE", v[6], v[7]-1, 48, "center")
      end
    end
    lg.reset()
  end
  
  
  
  if showDetails ~= nil then
    if niceScanner then
      lg.draw(scanner, 650, 506)
      lg.setColor(1, 1, 1)
      lg.setFont(bodyXsm)
      lg.printf(showDetails[2], 668, 526, 200, "left")
      lg.printf(showDetails[3], 668, 544, 200, "left")
      lg.printf(showDetails[14] .. pkgNum..showDetails[12], 660, 572, 134, "right")
      lg.reset()
    else
      lg.draw(sprites, label, 660, 510)
      lg.setColor(0, 0, 0)
      lg.setFont(bodySm)
      bodySm:setLineHeight(.8)
      lg.printf(showDetails[2], 665, 530, 120, "left")
      lg.printf(showDetails[14] .. pkgNum..showDetails[12], 660, 584, 140, "center")
      lg.reset()
    end
  else
    if niceScanner then
      lg.draw(scanner, 772, 506)
    else
      lg.draw(sprites, label, 780, 500)
    end
  end
  
  if areaSelected == areas.back then
    lg.draw(sprites, layerHighlightTruck, 46, 180)
    lg.draw(sprites, layerHighlightSelector, 186, 46)
  end
  
  for k, v in ipairs(inTruck[3]) do
    for k1, v1 in ipairs(v) do
      if v1 ~= 0 and v1 ~= "n" then
        lg.draw(sprites, v1[8], v1[6], v1[7])
      end
    end
  end
  
  if areaSelected == areas.mid then
    lg.draw(sprites, layerHighlightTruck, 46, 270)
    lg.draw(sprites, layerHighlightSelector, 106, 46)
  end

  for k, v in ipairs(inTruck[2]) do
    for k1, v1 in ipairs(v) do
      if v1 ~= 0 and v1 ~= "n" then
        lg.draw(sprites, v1[8], v1[6], v1[7])
      end
    end
  end
  
  if areaSelected == areas.front then
    lg.draw(sprites, layerHighlightTruck, 46, 360)
    lg.draw(sprites, layerHighlightSelector, 26, 46)
  end
  
  for k, v in ipairs(inTruck[1]) do
    for k1, v1 in ipairs(v) do
      if v1 ~= 0 and v1 ~= "n" then
        lg.draw(sprites, v1[8], v1[6], v1[7])
      end
    end
  end
  
  if currentlyHeld ~= nil then
    lg.draw(sprites, currentlyHeld[8], currentlyHeld[6], currentlyHeld[7])
  end
  
end

function P.deliverPackages()
  
  --first figure out efficiency bonus. also go ahead and count them/score them
  
  local nh = {
    {0, 0, 0},
    {0, 0, 0},
    {0, 0, 0}
  }
  
  local totalEarned = 0
  local numPackages = 0
  local leftoverPackages = 0
  local damagedInTransit = 0
  local score = 10
  local efficiencyScore = 100
  local latePackages = 0
  local maxBaseEarn = 0
  
  for k, v in ipairs(inTruck) do
    for k1, v1 in ipairs(v) do
      for k2, v2 in ipairs(v1) do
        if v2 ~= 0 and v2 ~= "n" then
          local earning = earnPerPackage+(.1*earnPerPackage*adsBought)
          if v2[1] >= 8 then
            earning = earning * 2
          end
          maxBaseEarn = maxBaseEarn + earning
          nh[k][v2[4]] = nh[k][v2[4]] + 1 --neighborhoods
          numPackages = numPackages + 1
          for k3, v3 in ipairs(daysBoxes) do
            if v3 == v2  then
              daysBoxes[k3][5] = true
            end
          end
          local d = v2[14]
          if d + 1 < dayNum then
            earning = max(earning - dayNum-d, 1)
            score = score - .5
            latePackages = latePackages + 1
          end
          if not v2[13] then
            local r = love.math.random(2)
            if r == 1 then
              earning = earning / 2
              damagedInTransit = damagedInTransit + 1
              score = score - 1
            end
          end
          totalEarned = totalEarned + earning
        end
      end
    end
  end
  
  
  if nh[1][1] > 0 and nh[1][3] > 0 then
    efficiencyScore = efficiencyScore - (5 * math.min(nh[1][1], nh[1][3]))
  end
  if nh[3][1] > 0 and nh[3][3] > 0 then
    efficiencyScore = efficiencyScore - (5 * math.min(nh[1][1], nh[1][3]))
  end
  
  if nh[1][1] + nh[1][2] + nh[1][3] == 0 then
    efficiencyScore = efficiencyScore - 20
  end
  
  if nh[2][1] + nh[2][2] + nh[2][3] == 0 then
    efficiencyScore = efficiencyScore - 20
  end
  
  if nh[3][1] + nh[3][2] + nh[3][3] == 0 then
    efficiencyScore = efficiencyScore - 20
  end
  
  for k, v in ipairs(daysBoxes) do
    if not v[5] then
      leftoverPackages = leftoverPackages + 1
    end
  end
    
  
  local tempTable = {
    day = dayNum,
    num = numPackages,
    late = latePackages,
    eff = efficiencyScore,
    left = leftoverPackages,
    score = score,
    damaged = damagedInTransit,
    earned = totalEarned,
    maxBaseEarn = maxBaseEarn
  }
  
  return tempTable
  
end

function P.upgradeMousePresses(x, y, cash)
  
  local h = 132
  local w = 334

  if x >= 48 and x <= 48 + w and y >= 270 and y <= 270 + h then
    if cash >= scanCost and not niceScanner then
      niceScanner = true
      return scanCost, "scanner", "pUp"
    else
      return 0, "broke", "pDown"
    end
  elseif  x >= 418 and x <= 418 + w and y >= 270 and y <= 270 + h then
    if cash >= dueCost and not showDue then
      showDue = true
      return dueCost, "due", "pUp"
    else
      return 0, "broke", "pDown"
    end
  elseif  x >= 48 and x <= 48 + w and y >= 432 and y <= 432 + h then
    if cash >= lateCost and not showLate then
      showLate = true
      return lateCost, "late", "pUp"
    else
      return 0, "broke", "pDown"
    end
  elseif x >= 418 and x <= 418 + w and y >= 432 and y <= 432 + h then
    if cash >= adsCost then
      adsBought = adsBought + 1
      return adsCost, "ads", "pUp"
    else
      return 0, "broke", "pDown"
    end
  end
  
  return 0, nil, nil

end

function P.drawPackageList(l)
  
  local start = 1
  local endList = #daysBoxes
  
  if l == 2 and #daysBoxes >= 15 then
    start = #daysBoxes / 2
  elseif l == 1 and #daysBoxes >= 15 then
    endList = (#daysBoxes/2) - 1
  end
  
  local x = 214
  local x2 = 282
  local x3 = 540
  local y = 136
  
  lg.setFont(handSm)
  lg.setColor(0, 0, 0)
  
  for i = start, endList do
    local v = daysBoxes[i]
    lg.printf(v[14] .. pkgNum..v[12], x, y, 100, "left")
    lg.printf(v[2] .. ": "..v[3], x2, y,  400, "left")
    lg.printf("day "..v[14],  x3, y, 100, "left")
    y = y + 27
  end
    
  lg.reset()
  

end

function P.handleMouseMove(x, y, dx, dy)
  
  if currentlyHeld ~= nil then
    currentlyHeld[6] = currentlyHeld[6] + dx
    currentlyHeld[7] = currentlyHeld[7] + dy
  end
  
end

function P.handleMousePress(x, y, button)

  if button == 1 and currentlyHeld == nil then
    local _, success = CheckBoxOverlap(x, y)
    if success then
      return "up"
    end
    ArrangePackages()
  end
  if button == 2 and currentlyHeld == nil then
    local i = showDetails
    local j, sfx = CheckInspect(x, y)
    if i == j then
      showDetails = nil
      return "pDown"
    end
    if sfx == "pUp" then
      return "pUp"
    end
  end
  if currentlyHeld == nil then
    CheckHandleButtonPress(x, y, button)
  end
  
end

function P.handleMouseRelease(x, y, button)

  if currentlyHeld ~= nil and button == 1 then
    local success = TryPlaceBox(x, y, currentlyHeld[6], currentlyHeld[7])
    if success then
      currentlyHeld = nil
      ArrangePackages()
      return "success"
    else
      currentlyHeld[6] = currentlyHeld[9]
      currentlyHeld[7] = currentlyHeld[10]
      currentlyHeld = nil
      ArrangePackages()
      return "down"
    end
  end
  
end

function P.handleKeyPress(key)
  
  
  
end

function P.startNewDay()
  
  dayNum = dayNum + 1
  
  currentlyHeld = nil
  
  daysBoxes = GetPackages(dayNum)
  
  areaSelected = areas.back
  
  inTruck = CreateTruckBed()
  
  DayStart()
  
end


--mousex, mousey, box x, box y
function TryPlaceBox(x, y, bx, by)
  
  if x >= truckXCoords[1] and x <= 346 then
    
    if areaSelected == areas.back and y >= 187 and y <= 320 then
      return PlaceBox(x, y, bx, by)
    elseif areaSelected == areas.mid and y >= 277 and y <= 408 then
      return PlaceBox(x, y, bx, by)
    elseif areaSelected == areas.front and y >= 366 and y <= 500  then
      return PlaceBox(x, y, bx, by)
    end
    
    if areaSelected == areas.back and by >= 187 and by <= 320 then
      return PlaceBox(x, y, bx, by)
    elseif areaSelected == areas.mid and by >= 277 and by <= 408 then
      return PlaceBox(x, y, bx, by)
    elseif areaSelected == areas.front and by >= 366 and by <= 500  then
      return PlaceBox(x, y, bx, by)
    end

  end
  
  return false
    
end

--oh god the jank hurts my eyes and soul
function PlaceBox(x, y, bx, by)
  
  if bx <= 106 then
    return DropBoxInCol(1)
  elseif bx <= 167 then
    return DropBoxInCol(2)
  elseif bx <= 226 then
    return DropBoxInCol(3)
  elseif bx <= 286 then
    return DropBoxInCol(4)
  elseif bx <= 346 then
    return DropBoxInCol(5)
  end
  
  if x <= 106 then
    return DropBoxInCol(1)
  elseif x <= 167 then
    return DropBoxInCol(2)
  elseif x <= 226 then
    return DropBoxInCol(3)
  elseif x <= 286 then
    return DropBoxInCol(4)
  elseif x <= 346 then
    return DropBoxInCol(5)
  end

end

function DropBoxInCol(c)
  
  truckArea = inTruck[3]
  local coordIndex = 1
  
  if areaSelected == areas.back then
    truckArea = inTruck[3]
  elseif areaSelected == areas.mid then
    truckArea = inTruck[2]
    coordIndex = 2
  elseif areaSelected == areas.front then
    truckArea = inTruck[1]
    coordIndex = 3
  end
  
  if currentlyHeld[1] >= 8 then
    if truckArea[c][3] ~= 0 or c == 5 then
      return false
    elseif truckArea[c+1][3] ~= 0 then
      return false
    else
      local b = FindDayBox(currentlyHeld)
      truckArea[c][2] = b
      truckArea[c][3] = "n"
      truckArea[c+1][2] = "n"
      truckArea[c+1][3] = "n"
      b[6] = truckXCoords[c]+4
      b[7] = truckYCoords[coordIndex][2]-8
      b[11] = c
      if areaSelected == areas.back then
        b[8] = pkgLg[b[1]-7].back
      elseif areaSelected == areas.mid then
        b[8] = pkgLg[b[1]-7].mid
      end
      return true
    end
  else
    if truckArea[c][3] == 0 then
      local b = FindDayBox(currentlyHeld)
      truckArea[c][3] = b
      b[6] = truckXCoords[c]+4
      b[7] = truckYCoords[coordIndex][3]-8
      b[11] = c
      if areaSelected == areas.back then
        b[8] = pkgSm[b[1]].back
      elseif areaSelected == areas.mid then
        b[8] = pkgSm[b[1]].mid
      end
      return true
    elseif truckArea[c][2] == 0 then
      local b = FindDayBox(currentlyHeld)
      truckArea[c][2] = b
      b[6] = truckXCoords[c]+4
      b[7] = truckYCoords[coordIndex][2]-8
      b[11] = c
      if areaSelected == areas.back then
        b[8] = pkgSm[b[1]].back
      elseif areaSelected == areas.mid then
        b[8] = pkgSm[b[1]].mid
      end
      return true
    elseif truckArea[c][1] == 0 then
      local b = FindDayBox(currentlyHeld)
      truckArea[c][1] = b
      b[6] = truckXCoords[c]+4
      b[7] = truckYCoords[coordIndex][1]-8
      b[11] = c
      if areaSelected == areas.back then
        b[8] = pkgSm[b[1]].back
      elseif areaSelected == areas.mid then
        b[8] = pkgSm[b[1]].mid
      end
      return true
    end
  end
  
  return false
  
end

function CheckInspect(x, y)
  
  for k, v in ipairs(daysBoxes) do
    local size = tileSize
    if v[1] >= 8 then
      size = size * 2
    end
    if x >= v[6] and x <= v[6] + size then
      if y >= v[7] and y <= v[7] + size then
        local a = GetLayer(v)
        if a == areaSelected or a == nil then
          showDetails = v
          return v, "pUp"
        end
      end
    end
  end
  
  showDetails = nil
  return nil, nil
  
end

function CheckBoxOverlap(x, y)
  
  local found = false
  
  for k, v in ipairs(daysBoxes) do
    local size = tileSize
    if v[1] >= 8 then
      size = size * 2
    end
    if x >= v[6] and x <= v[6] + size then
      if y >= v[7] and y <= v[7] + size then
        local a = GetLayer(v)
        if a == areaSelected or a == nil then
          if v[11] ~= false and v[1] >= 8 then
            local c = v[11]
            if inTruck[1][c][2] ~= 0 and inTruck[1][c][2][12] == v[12] then
              inTruck[1][c][2] = 0
              inTruck[1][c][3] = 0
              inTruck[1][c+1][2] = 0
              inTruck[1][c+1][3] = 0
            elseif inTruck[2][c][2] ~= 0  and inTruck[2][c][2][12] == v[12] then
              inTruck[2][c][2] = 0
              inTruck[2][c][3] = 0
              inTruck[2][c+1][2] = 0
              inTruck[2][c+1][3] = 0
            elseif inTruck[3][c][2] ~= 0  and inTruck[3][c][2][12] == v[12] then
              inTruck[3][c][2] = 0
              inTruck[3][c][3] = 0
              inTruck[3][c+1][2] = 0
              inTruck[3][c+1][3] = 0
            end
            v[11] = false
            v[8] = pkgLg[v[1]-7].front
          elseif v[11] ~= false then
            for k1, v1 in ipairs(inTruck) do --front mid back
              for k2, v2 in ipairs(v1) do --cols
                for k3, v3 in ipairs(v2) do --top mid bottom
                  if v3 ~= 0 then
                    if v3[12] == v[12] then
                      inTruck[k1][k2][k3] = 0
                      v[11] = false
                      v[8] = pkgSm[v[1]].front
                    end
                  end
                end
              end
            end
          end
          found = true
          currentlyHeld = v
          return found, true
        end
      end
    end
  end
  
  return found, false
  
end

function GetLayer(b)
  
  for k, v in ipairs(inTruck) do
    for k1, v1 in ipairs(v) do
      for k2, v2 in ipairs(v1) do
        if v2 == b then
          return k
        end
      end
    end
  end
  
  return nil
  
end

function CheckHandleButtonPress(x, y, button)
    
  if button ~= 1 then
    return
  elseif y >= 50 and y <= 116 then
    --front layer
    if x >= 30 and x <= 94 then
      areaSelected = areas.front
    --mid layer
    elseif x >= 110 and x <= 174 then
      areaSelected = areas.mid
    --back layer
    elseif x >= 190 and x <= 260 then
      areaSelected = areas.back
    end
  end
  
end

function DayStart()
  
  local currXLg = 424
  local currYLg = 10
  
  local currXSm = 424
  local currYSm = 240
  
  for k, v in ipairs(daysBoxes) do
    if v[1] >= 8 then
      v[6] = currXLg
      v[7] = currYLg
      v[8] = pkgLg[v[1]-7].front
      v[9] = currXLg
      v[10] = currYLg
      if currXLg >= 650 then
        currXLg = 424
        currYLg = currYLg + 110
      else
        currXLg = currXLg + 120
      end
    else
      v[6] = currXSm
      v[7] = currYSm
      v[8] = pkgSm[v[1]].front
      v[9] = currXSm
      v[10] = currYSm
      if currXSm >= 680 then
        currXSm = 424
        currYSm= currYSm + 60
      else
        currXSm = currXSm + 60
      end
    end
    if v[14] < 1 then
      v[14] = dayNum
    end
  end
  
end

function GetPackages(day)
  
  local tempTable = {}
  local n = day-1
  local numLg = 0
  local numSm = 0
  for i=1, 300, 1 do
    if not allPackages[i][5] then
      if allPackages[i][1] >= 8 then
        numLg = numLg + 1
        if numLg <= 6 then
          table.insert(tempTable, allPackages[i])
        end
      else
        numSm = numSm + 1
        if numSm <= 24 then
          table.insert(tempTable, allPackages[i])
        end
      end
      if #tempTable >= 30 then
        return tempTable
      end
    end
  end

  return tempTable
  
end

function CreateTruckBed()
  
  local tempTable = {
    { --front
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0}
    },
  
    { --mid
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0}
    },
  
    { --back
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0},
      {0, 0, 0}
    }
  }
  
  return tempTable
  
end

function ArrangePackages()  
  
  if (currentlyHeld ~= nil) then
    return
  end
  
  for k, v in ipairs(inTruck) do
    for k1, v1 in ipairs(v) do
      if v1[3] == 0 then
        if v1[2] ~= 0 then
          v1[3] = FindDayBox(v1[2])
          v1[2] = 0
          v1[3][7] = truckYCoords[4-k][3]-8
          return
        elseif v1[1] ~= 0 then
          v1[3] = FindDayBox(v1[1])
          v1[1] = 0
          v1[3][7] = truckYCoords[4-k][3]-8
          return
        end
      elseif v1[2] == 0 and v1[1] ~= 0 then
        v1[2] = FindDayBox(v1[1])
        v1[1] = 0
        v1[2][7] = truckYCoords[4-k][2]-8
        return
      end
    end
  end
  
end

function FindDayBox(b)
  
  for k, v in ipairs(daysBoxes) do
    if v[12] == b[12] then
      return v
    end
  end
end

function CheckPackageRules()
  
  for k, v in ipairs(inTruck) do
    for k1, v1 in ipairs(v) do
      for k2, v2 in ipairs(v1) do
        if v2 ~= 0 and v2 ~= "n" then
          v2[13] = true
        end
      end
    end
  end
  
  local f = PassFragileRule()
  local h = PassHeavyRule()
  
  --fragile boxes can only be in a section with other fragile boxes
  --heavy boxes cannot be on top of any other boxes
  --large boxes cannot be on top of small boxes
  --the sections must be ordered to minimize driving (neighborhood order or inverse)
  
  return (f and h)
  
end

function PassFragileRule(t)
  
  local passing = true
  
  for k, v in ipairs(inTruck) do
    local frag = 0
    local nonFrag = 0
    for k1, v1 in ipairs(v) do
      for k2, v2 in ipairs(v1) do
        if v2 ~= 0 and v2 ~= "n" then
          if v2[1] == 7 or v2[1] == 12 then
            frag = frag + 1
          else
            nonFrag = nonFrag + 1
          end
        end
      end
    end
    if nonFrag > 0 and frag > 0 then
      passing = false
      for k1, v1 in ipairs(v) do
        for k2, v2 in ipairs(v1) do
          if v2 ~= 0 and v2 ~= "n" then
            if v2[1] == 7 then
              v2[13] = false
              v2[8] = pkgSm[7].error
            elseif v2[1] == 12 then
              v2[13] = false
              v2[8] = pkgLg[5].error
            end
          end
        end
      end
    else
      for k1, v1 in ipairs(v) do
        for k2, v2 in ipairs(v1) do
          if v2 ~= 0 and v2 ~= "n" then
            if v2[1] == 7 then
              v2[13] = true
              if k == 1 then
                v2[8] = pkgSm[7].front
              elseif k == 2 then
                v2[8] = pkgSm[7].mid
              elseif k == 3 then
                v2[8] = pkgSm[7].back
              end
            elseif v2[1] == 12 then
              v2[13] = true
              if k == 1 then
                v2[8] = pkgLg[5].front
              elseif k == 2 then
                v2[8] = pkgLg[5].mid
              elseif k == 3 then
                v2[8] = pkgLg[5].back
              end
            end
          end
        end
      end
    end
  end
  
  return passing
  
end

function PassHeavyRule(t)
  
  local passing = true
  
  for k, v in ipairs(inTruck) do
    local found = false
    for k1, v1 in ipairs(v) do
      for k2, v2 in ipairs(v1) do
        if v2 ~= 0 and v2 ~= "n" then
          if v2[1] == 6 and k2 ~= 3 then
            passing = false
            v2[13] = false
            v2[8] = pkgSm[6].error
            found = true
          end
        end
      end
    end
    if not found then
      for k1, v1 in ipairs(v) do
        for k2, v2 in ipairs(v1) do
          if v2 ~= 0 and v2 ~= "n" then
            if v2[1] == 6 then
              if k == 1 then
                v2[8] = pkgSm[6].front
              elseif k == 2 then
                v2[8] = pkgSm[6].mid
              elseif k == 3 then
                v2[8] = pkgSm[6].back
              end
              v2[13] = true
            end
          end
        end
      end
    end
  end
  
  return passing
  
end


--n = num tiles wide/high, x = which x tile, y = which y tile, ex = extra for big boxes
function CreatePackageTable(n, x, y, ex)
  
  ex = ex or 0
  
  local tempTable = {}
  
  tempTable.front = lg.newQuad(x*tileSize, y*tileSize, (tileSize*n)+ex, tileSize*n, sheetW, sheetH)
  tempTable.mid = lg.newQuad(x*tileSize, (y+(1*n))*tileSize, (tileSize*n)+ex, tileSize*n, sheetW, sheetH)
  tempTable.back = lg.newQuad(x*tileSize, (y+(2*n))*tileSize, (tileSize*n)+ex, tileSize*n, sheetW, sheetH)
  tempTable.error = lg.newQuad(x*tileSize, (y+(3*n))*tileSize, (tileSize*n)+ex, tileSize*n, sheetW, sheetH)
  
  return tempTable
  
end

return P