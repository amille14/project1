------------------------------------
-- LOAD LIBRARIES
------------------------------------
_ = require "lib/lume"
class = require "lib/middleclass"
bump  = require "lib/bump"
anim8 = require "lib/anim8"
flux  = require "lib/flux"
donut = require("lib/donut")
serialize = require "lib/serpent"
camera    = require "lib/hump/camera"
gamestate = require "lib/hump/gamestate"
signal    = require "lib/hump/signal"
timer     = require "lib/hump/timer"
vector    = require "lib/hump/vector"


-- Load Mixins
------------------------------------
require "mixins/corners"


-- Load Classes
------------------------------------
require "collider"
require "abilities/ability"
require "abilities/sword/sword_neutral"
require "abilities/sword/sword_down_air"
require "player"
require "block"
require "bat"



------------------------------------
-- GLOBALS OBJECTS
------------------------------------
debug = Donut.init(5, 5)
debugger = {
  fps = debug.add("FPS"),
  keypressed = debug.add("Last Key Pressed")
}
world  = bump.newWorld(64)
map    = {}
player = {}
cam    = {}



------------------------------------
-- LOAD LOVE
------------------------------------
function love.load()
  love.graphics.setBackgroundColor(0, 100, 100)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.math.setRandomSeed(os.time())


  -- Initialize Objects
  ------------------------------------
  player = Player:new(128, 128)
  cam = camera(player.x, player.y)
  bats = { Bat:new(world, 640, 480), Bat:new(world, 380, 380), Bat:new(world, 280, 280) }

  map = {
    blocks = {},
    width = love.window.getWidth()*3,
    height = love.window.getHeight(),
    tileSize = 32
  }
  map.widthInTiles = map.width / map.tileSize
  map.heightInTiles = map.height / map.tileSize

  for i = 0, map.widthInTiles do
    for j = 0, map.heightInTiles do
      if j == map.heightInTiles - 7 and i > map.widthInTiles / 2 or j == map.heightInTiles - 1 then
        map.blocks[i] = map.blocks[i] or {}
        map.blocks[i][j] = Block:new(world, i * map.tileSize, j * map.tileSize, map.tileSize, map.tileSize)
      end
    end
  end

  map.blocks[map.widthInTiles - 8] = {}
  map.blocks[map.widthInTiles - 8][map.heightInTiles - 8] = Block:new(world, (map.widthInTiles - 8) * map.tileSize, (map.heightInTiles - 8) * map.tileSize, map.tileSize, map.tileSize)
  map.blocks[map.widthInTiles - 8][map.heightInTiles - 9] = Block:new(world, (map.widthInTiles - 8) * map.tileSize, (map.heightInTiles - 9) * map.tileSize, map.tileSize, map.tileSize)
  map.blocks[map.widthInTiles - 8][map.heightInTiles - 10] = Block:new(world, (map.widthInTiles - 8) * map.tileSize, (map.heightInTiles - 10) * map.tileSize, map.tileSize, map.tileSize)
end



------------------------------------
-- KEYPRESSES/KEYRELEASES
------------------------------------
function love.keyreleased(key)
  if key == "escape" then love.event.quit()

  elseif key == "z" then player:releaseAbility()
  -- elseif key == "x" then player:releaseAbility()
  -- elseif key == "c" then player:releaseAbility()
  -- elseif key == "v" then player:releaseAbility()
  elseif key == "up" and notUsingAbility() then player:releaseJump()
  end
end

function love.keypressed(key)
  if key == "1" then debug.toggle()

  elseif key == "z" then
    if     love.keyboard.isDown("up") then player:executeAbility(1, "up")
    elseif love.keyboard.isDown("down") then player:executeAbility(1, "down")
    elseif love.keyboard.isDown("left") then player:executeAbility(1, "side")
    elseif love.keyboard.isDown("right") then player:executeAbility(1, "side")
    else player:executeAbility(1, "neutral") end

  -- elseif key == "x" then
  --   if     love.keyboard.isDown("up") then player:executeAbility(2, "up")
  --   elseif love.keyboard.isDown("down") then player:executeAbility(2, "down")
  --   elseif love.keyboard.isDown("left") then player:executeAbility(2, "side")
  --   elseif love.keyboard.isDown("right") then player:executeAbility(2, "side")
  --   else player:executeAbility(2, "neutral") end

  -- elseif key == "c" then player:releaseAbility3()
  --   if     love.keyboard.isDown("up") then player:executeAbility(3, "up")
  --   elseif love.keyboard.isDown("down") then player:executeAbility(3, "down")
  --   elseif love.keyboard.isDown("left") then player:executeAbility(3, "side")
  --   elseif love.keyboard.isDown("right") then player:executeAbility(3, "side")
  --   else player:executeAbility(3, "neutral") end

  -- elseif key == "v" then player:releaseAbility4()
  --   if     love.keyboard.isDown("up") then player:executeAbility(4, "up")
  --   elseif love.keyboard.isDown("down") then player:executeAbility(4, "down")
  --   elseif love.keyboard.isDown("left") then player:executeAbility(4, "side")
  --   elseif love.keyboard.isDown("right") then player:executeAbility(4, "side")
  --   else player:executeAbility(4, "neutral") end

  elseif key == "up" and notUsingAbility() then player:jump()
  end

  debug.update(debugger.keypressed, key)
end



------------------------------------
-- LOVE UPDATE
------------------------------------
function love.update(dt)
  player:update(dt)
  for i, bat in ipairs(bats) do
    bat:update(dt)
  end


  -- Update Camera
  ------------------------------------
  if math.abs(player.x - cam.x) > 64 then
    tweenX = flux.to(cam, 0.1, {x = getNewCamX(cam.x, cam.y, player.x, player.y, 64)}):ease("linear")
  end
  cam.y = player.y
  flux.update(dt)


  -- Update Debugger
  ------------------------------------
  debug.update(debugger.fps, love.timer.getFPS())
end



------------------------------------
-- LOVE DRAW
------------------------------------
function love.draw()
  cam:attach()


  -- Draw Ground
  ------------------------------------
  for i, row in pairs(map.blocks) do
    for j, tile in pairs(row) do
      tile:draw()
    end
  end


  -- Draw Player & Objects
  ------------------------------------
  love.graphics.setColor(255, 255, 255)
  for i, bat in ipairs(bats) do
    bat:draw()
  end
  love.graphics.setColor(255, 255, 255)
  player:draw()


  --Debugging
  ------------------------------------
  if debug.__debugMode then
    drawCamera()
  end

  cam:detach()
  debug.draw()
end



------------------------------------
-- UTILITY HELPERS
------------------------------------
function notUsingAbility()
  return not love.keyboard.isDown("z")
         and not love.keyboard.isDown("x")
         and not love.keyboard.isDown("c")
         and not love.keyboard.isDown("v")
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


-- Camera helpers
----------------------------------
function drawCamera()
  love.graphics.setColor(255, 255, 255)
  love.graphics.line(cam.x, cam.y, player.x, player.y)
  love.graphics.setColor(0, 0, 255)
  love.graphics.circle("fill", cam.x, cam.y, 6, 20)
end

-- Returns a point d distance along the line from (x1, y1) to (x2, y2)
function getNewCamX(x1, y1, x2, y2, d)
  local vx = math.abs(x2 - x1)
  local vy = math.abs(y2 - y1)
  local magnitude = math.sqrt(vx*vx + vy*vy)

  vx = vx / magnitude

  if x1 < x2 then
    return x1 + vx * (magnitude - d)
  else
    return x1 - vx * (magnitude - d)
  end
end

-- Returns a point d distance along the line from (x1, y1) to (x2, y2)
function getNewCamY(x1, y1, x2, y2, d)
  local vx = math.abs(x2 - x1)
  local vy = math.abs(y2 - y1)
  local magnitude = math.sqrt(vx*vx + vy*vy)

  vy = vy / magnitude

  if y1 < y2 then
    return y1 + vy * (magnitude - d)
  else
    return y1 - vy * (magnitude - d)
  end
end