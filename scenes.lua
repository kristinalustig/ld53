p = require "packages"

S = {}

--imported images
local background
local sprites
local title
local map
local packageList
local intro1
local intro2
local intro3
local endOfDay
local gameOver
local delivering
local upgrades
local help

--quad helpers
local tileSize
local sheetW
local sheetH

--quads
local menuButtons
local cutscene

--sounds/music
local theme
local deliveryTheme
local gameOverTheme
local clickUp
local clickDown
local clickSuccess
local clickBad
local pressUp
local pressDown

--other vars
local scenes
local unlocks
local money
local currentScene
local deliveryCounter
local modifier
local frame
local iter
local packListPage
local musicEnabled
local sfxEnabled

--stats
local stats
local gameOverStats
local totalDelivered
local totalMoney
local basePay
local gameOverReasons
local totalLate
local totalDamaged
local hadChanceToRedeem
local specialText
local upgraded
local upgradeError
local day

function S.load()
  
  deliveryCounter = 0
  modifier = 20
  frame = 1
  iter = 1
  
  packListPage = 1
  
  hadChanceToRedeem = false
  totalLate = 0
  totalDamaged = 0
  upgradeError = false
  
  musicEnabled = true
  sfxEnabled = true
  
  --images
  background = lg.newImage("/assets/background.png")
  sprites = lg.newImage("/assets/sprites.png")
  title = lg.newImage("/assets/title.png")
  map = lg.newImage("/assets/map.png")
  packageList = lg.newImage("/assets/package-list.png")
  intro1 = lg.newImage("/assets/intro1.png")
  intro2 = lg.newImage("/assets/intro2.png")
  intro3 = lg.newImage("/assets/intro3.png")
  endOfDay = lg.newImage("/assets/end-of-day.png")
  gameOver = lg.newImage("/assets/game-over.png")
  delivering = lg.newImage("/assets/delivering.png")
  upgrades = lg.newImage("/assets/upgrades.png")
  help = lg.newImage("/assets/help.png")
  
  sheetW = 1144
  sheetH = 832
  tileSize = 48
  
  upgraded = {
    scanner = false,
    due = false,
    late = false,
    ads = 0
    }
  
  --quads
  menuButtons = {
    lg.newQuad(0*tileSize, 0*tileSize, 3*tileSize, tileSize, sheetW, sheetH),
    lg.newQuad(3*tileSize, 0*tileSize, 4*tileSize, tileSize, sheetW, sheetH),
    lg.newQuad(7*tileSize, 0*tileSize, 4*tileSize, tileSize, sheetW, sheetH),
    lg.newQuad(11*tileSize, 0*tileSize, 3*tileSize, tileSize, sheetW, sheetH),
    lg.newQuad(14*tileSize, 0*tileSize, 3*tileSize, tileSize, sheetW, sheetH)
  }
  
  cutscene = {
    lg.newQuad(0, 0, 800, 680, 4000, 680),
    lg.newQuad(800, 0, 800, 680, 4000, 680),
    lg.newQuad(1600, 0, 800, 680, 4000, 680),
    lg.newQuad(2400, 0, 800, 680, 4000, 680),
    lg.newQuad(3200, 0, 800, 680, 4000, 680)
    }
  
  --sounds/music
  theme = la.newSource("/assets/theme.mp3", "stream")
  theme:setLooping(true)
  deliveryTheme = la.newSource("/assets/delivering.mp3", "stream")
  gameOverTheme = la.newSource("/assets/gameOver.mp3", "stream")
  clickUp = la.newSource("/assets/clickUp.mp3", "static")
  clickDown = la.newSource("/assets/clickDown.mp3", "static")
  clickSuccess = la.newSource("/assets/clickSuccess.mp3", "static")
  clickBad = la.newSource("/assets/clickBad.mp3", "static")
  pressUp = la.newSource("/assets/pressUp.mp3", "static")
  pressDown = la.newSource("/assets/pressDown.mp3", "static")
  
  --other vars
  scenes = {
    title = 1,
    intro1 = 2,
    intro2 = 3,
    intro3 = 4,
    packages = 5,
    help = 6,
    map = 7,
    packList = 8,
    upgrades = 9,
    endOfDay = 10,
    gameOver = 11,
    delivering = 12
  }
  
  gameOverReasons = {
    money = 1,
    packages = 2,
    sentiment = 3
    }
  
  currentScene = scenes.title
  
  totalDelivered = 0
  totalMoney = 100
  basePay = 100
  
  stats = {}
  day = 1
  
  P.load()
  
  PlaySfx("theme")
  
end

function S.update()
  
  local sfx = P.update()
  if sfx ~= nil then
    PlaySfx(sfx)
  end
  
end

function S.draw()
  
  if currentScene == scenes.title then
    lg.draw(title)
  elseif currentScene == scenes.packages then
    lg.draw(background)
    P.draw()
    DrawMenu()
  elseif currentScene == scenes.map then
    lg.draw(map)
    lg.setFont(titleSm)
    lg.printf("Click anywhere or press 'esc' to return", 0, 0, 800, "center")
  elseif currentScene == scenes.packList then
    lg.draw(background)
    P.draw()
    DrawMenu()
    lg.draw(packageList)
    P.drawPackageList(packListPage)
    lg.setFont(titleSm)
    lg.printf("Press 'space' to swap pages of the list.", 0, 600, 800, "center")
    lg.printf("Click anywhere or press 'esc' to return", 0, 650, 800, "center")
  elseif currentScene == scenes.help then
    lg.draw(help)
    lg.setFont(titleSm)
    lg.printf("Click anywhere or press 'esc' to return", 0, 650, 800, "center")
  elseif currentScene == scenes.intro1 then
    lg.draw(intro1)
    lg.setFont(titleSm)
    lg.printf("Click anywhere or press 'n' to continue", 0, 650, 800, "center")
  elseif currentScene == scenes.intro2 then
    lg.draw(intro2)
    lg.setFont(titleSm)
    lg.printf("Click anywhere or press 'n' to continue", 0, 650, 800, "center")
  elseif currentScene == scenes.intro3 then
    lg.draw(intro3)
    lg.setFont(titleSm)
    lg.printf("Click anywhere or press 'n' to continue", 0, 650, 800, "center")
  elseif currentScene == scenes.upgrades then
    lg.draw(upgrades)
    if upgraded.scanner then
      lg.setColor(0, 0, 0, .5)
      lg.rectangle("fill", 48, 270, 334, 132)
      lg.setColor(1, 1, 1)
      lg.setFont(titleLg)
      lg.printf("PURCHASED", 48, 300, 334, "center")
    end
    if upgraded.due then
      lg.setColor(0, 0, 0, .5)
      lg.rectangle("fill", 418, 270, 334, 132)
      lg.setColor(1, 1, 1)
      lg.setFont(titleLg)
      lg.printf("PURCHASED", 418, 300, 334, "center")
    end
    if upgraded.late then
      lg.setColor(0, 0, 0, .5)
      lg.rectangle("fill", 48, 432, 334, 132)
      lg.setColor(1, 1, 1)
      lg.setFont(titleLg)
      lg.printf("PURCHASED", 48, 462, 334, "center")
    end
    if upgraded.ads ~= 0 then
      lg.setFont(titleSm)
      lg.setColor(1, 1, 1)
      lg.printf("purchased "..upgraded.ads.." so far", 418, 566, 334, "center")
    end
    if upgradeError then
      lg.setFont(titleSm)
      lg.setColor(1, 1, 1)
      lg.printf("Can't purchase this upgrade.", 0, 220, 800, "center")
    end
    lg.reset()
  elseif currentScene == scenes.endOfDay then
    lg.draw(endOfDay)
    EndOfDayStats()
  elseif currentScene == scenes.gameOver then
    lg.draw(gameOver)
    DrawGameOverStats()
  elseif currentScene == scenes.delivering then
    deliveryCounter = deliveryCounter + 1
    if deliveryCounter == 2 * modifier then
      frame = 2
    elseif deliveryCounter == 3 * modifier then
      frame = 3
    elseif deliveryCounter == 4 * modifier then
      frame = 4
    elseif deliveryCounter == 5 * modifier then
      frame = 5
    elseif deliveryCounter == 6 * modifier then
      frame = 1
      deliveryCounter = 2* modifier
      if iter == 2 then
        iter = 1
        currentScene = scenes.endOfDay
        deliveryCounter = 1
      else
        iter = iter + 1
      end
    end
    lg.draw(delivering, cutscene[frame])
  end
  
end

function S.handleMouseMove(x, y, dx, dy)
  
  if currentScene == scenes.packages then
    P.handleMouseMove(x, y, dx, dy)
  end

end

function S.handleMousePress(x, y, button)
  
  if currentScene == scenes.packages then
    local sfx = P.handleMousePress(x, y, button)
    if sfx ~= nil then
      PlaySfx(sfx)
    end
  end
  
  if currentScene < 5 and button == 1 then
    currentScene = currentScene + 1
    
  elseif currentScene > 5 and currentScene < 9 and button == 1 then
    currentScene = scenes.packages
    
  elseif currentScene == scenes.upgrades then
    upgradeError = false
    local money, u, sfx = p.upgradeMousePresses(x, y, totalMoney)
    if sfx ~= nil then
      PlaySfx(sfx)
    end
    if u == "broke" then
      upgradeError = true
      return
    end
    if money ~= 0 then
      totalMoney = totalMoney - money
      if u == "ads" then
        upgraded.ads = upgraded.ads + 1
      elseif u == "scanner" then
        upgraded.scanner = true
      elseif u == "due" then
        upgraded.due = true
      elseif u == "late" then
        upgraded.late = true
      end
    end
    
  
  elseif currentScene == scenes.endOfDay then
    
    if x >= 600 and x <= 700 and y > 500 and y < 660 then
      
      currentScene = scenes.packages
      day = day + 1
      P.startNewDay()
      
    end
  else
  
    CheckMenuPresses(x, y)
  end

end

function S.handleMouseRelease(x, y, button)
  
  if currentScene == scenes.packages then
    local sfx = P.handleMouseRelease(x, y, button)
    PlaySfx(sfx)
  end

end

function S.handleKeyPress(key)
  
  if currentScene == scenes.packages then
    P.handleKeyPress(key)
  end
  
  if currentScene < 5 then
    if key == "n" then
      currentScene = currentScene + 1
    end
  end
  
  if currentScene == scenes.packList then
    if key == "space" then
      if packListPage == 1 then
        packListPage = 2
      else
        packListPage = 1
      end
    end
  end
    
  if currentScene > 5 and currentScene < 10 then
    if key == "escape" then
      currentScene = scenes.packages
    end
  end
  
  if currentScene == scenes.endOfDay then
    
    if key == "n" then
      currentScene = scenes.packages
      day = stats.day
      deliveryTheme:stop()
      PlaySfx("theme")
      P.startNewDay()
    end
    
  end

end

function PlaySfx(s)
  
  if sfxEnabled then
  
    if s == "success" then
      clickSuccess:play()
    elseif s == "down" then
      clickDown:play()
    elseif s == "up" then
      clickUp:play()
    elseif s == "pDown" then
      pressDown:play()
    elseif s == "pUp" then
      pressUp:play()
    elseif s == "bad" then
      clickBad:play()
    end
    
  end
  
  if musicEnabled then
  
    if s == "delivery" then
      deliveryTheme:play()
    elseif s == "gameOver" then
      gameOverTheme:play()
    elseif s == "theme" then
      theme:play()
    end
    
  end
  
end

function EndOfDay()
  
  stats = p.deliverPackages()

  totalDelivered = totalDelivered + stats.num
  
  stats.spent = basePay + (100-stats.eff)
  
  totalMoney = totalMoney + stats.earned - stats.spent
  --day
  --num packages delivered
  --total packages delivered
  --packages delivered late
  --packages efficiency score
  --packages left 'til tomorrow
  --star rating
  --cash earned
  --cash spent
  --net cash
  --cash earned to date
  
  local tooManyBadDeliveries = (totalDamaged + totalLate) / totalDelivered
  
  if totalMoney < 0 then
    if hadChanceToRedeem then
      GameOverStats(gameOverReasons.money)
      currentScene = scenes.gameOver
      return true
    else
      hadChanceToRedeem = true
      specialText = true
      return
    end
  elseif totalDelivered >= 280 then
    GameOverStats(gameOverReasons.packages)
    currentScene = scenes.gameOver
    return true
  elseif tooManyBadDeliveries > .5 and stats.day > 3 then
    GameOverStats(gameOverReasons.sentiment)
    currentScene = scenes.gameOver
    return true
  end
  
  specialText = false
  return false
end

function DrawMenu()
  
  lg.setFont(titleSm)
  lg.printf("Day "..day, 100, 570, 200, "center")

  lg.setFont(titleLg)
  if totalMoney <= 0 then
    lg.setColor(GetRgb(238, 117, 117))
  else
    lg.setColor(0, 0, 0)
  end
  lg.printf("$".. totalMoney, 550, 605, 200, "left")
  
  if not sfxEnabled then
    lg.setColor(0, 0, 0, .5)
    lg.rectangle("fill", 660, 613, 50, 21)
  end
  
  if not musicEnabled then
    lg.setColor(0, 0, 0, .5)
    lg.rectangle("fill", 660, 642, 50, 21)
  end

  lg.reset()
  
end

function EndOfDayStats()
  
  lg.setFont(titleSm)
  
  --day
  lg.printf(stats.day, 468, 104, 100, "left")
  --delivered today
  lg.printf(stats.num, 468, 164, 100, "left")
  if stats.late > 0 then
    lg.setColor(GetRgb(238, 117, 117))
  end
  --delivered late
  lg.printf(stats.late, 468, 196, 100, "left")
  lg.setColor(1, 1, 1)
  if stats.damaged > 0 then
    lg.setColor(GetRgb(238, 117, 117))
  end
  --damaged
  lg.printf(stats.damaged, 468, 226, 100, "left")
  lg.setColor(1, 1, 1)
  if stats.eff == 100 then
    lg.setColor(GetRgb(229, 250, 137))
  elseif stats.eff < 50 then
    lg.setColor(GetRgb(238, 117, 117))
  end
  --efficiency
  lg.printf(stats.eff, 468, 290, 100, "left")
  lg.setColor(1, 1, 1)
  --quality modifier
  lg.printf(stats.score, 468, 320, 100, "left")
  --base daily income
  lg.printf(stats.num * 5, 468, 380, 100, "left")
  --adjustment total
  lg.printf(stats.earned - (stats.maxBaseEarn), 468, 410, 100, "left")
  --operating costs
  lg.printf("$"..stats.spent, 468, 476, 100, "left")
  if stats.earned - stats.spent > 0 then
    lg.setColor(GetRgb(229, 250, 137))
  else
    lg.setColor(GetRgb(238, 117, 117))
  end
  --net cash earned
  lg.printf("$"..stats.earned - stats.spent, 468, 506, 100, "left")
    lg.setFont(titleXsm)
  if specialText then
    lg.printf("Your cash on hand is in the negative. Get in the positive by tomorrow, or game over!", 0, 530, 800, "center")
  end
  lg.setColor(1, 1, 1)
  --cash on hand
  lg.printf("$"..totalMoney, 468, 564, 100, "left")
  --delivered to date
  lg.printf(totalDelivered, 468, 584, 100, "left")
  --left on dock
  lg.printf(stats.left, 468, 604, 100, "left")
  
end

function GameOverStats(r)
  
  gameOverStats = {
      reason = r,
      day = stats.day,
      del = totalDelivered,
      c = totalMoney
    }
  
end

function DrawGameOverStats()
  
  lg.setFont(titleSm)
  
  local r = 
  {
    
    "You ran out of money!",
    "You finished delivering all of the packages (for now)!",
    "More than half of your deliveries were late or damaged!"
    
    }
  
  lg.printf(r[gameOverStats.reason], 420, 350, 400, "left")
  lg.printf(gameOverStats.day, 420, 414, 400, "left")
  lg.printf(gameOverStats.del, 420, 474, 400, "left")
  lg.printf("$"..gameOverStats.c, 420, 534, 400, "left")
  
end

function GetRgb(r, g, b)
  
  return r/255, g/255, b/255
  
end

function CheckMenuPresses(x, y)
  
  if y >= 615 and y <= 670 and x >= 26 then
    if x <= 134 then
      currentScene = scenes.map
      PlaySfx("up")
    elseif x <= 330 then
      currentScene = scenes.upgrades
      cPlaySfx("up")
    elseif x <= 530 then
      currentScene = scenes.packList
      PlaySfx("up")
    elseif x >= 660 and x <= 710 then
      if y >= 642 then
        musicEnabled = not musicEnabled
        if not musicEnabled then
          theme:stop()
        else
          theme:play()
        end
      else
        sfxEnabled = not sfxEnabled
      end
    elseif x >= 720 then
      currentScene = scenes.help
      PlaySfx("up")
    end
  end
  
  
  
  if y >= 10 and y <= 120 and x >= 300 and x <= 380 then
    local loss = EndOfDay()
    if not loss then
      currentScene = scenes.delivering
      theme:stop()
      PlaySfx("delivery")
    end
  end
  
end

return S