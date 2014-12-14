-- Load Libraries
_ = require "lib/lume"
class = require "lib/middleclass"
bump  = require "lib/bump"
anim8 = require "lib/anim8"
flux  = require "lib/flux"
serialize = require "lib/serpent"
camera    = require "lib/hump/camera"
gamestate = require "lib/hump/gamestate"
signal    = require "lib/hump/signal"
timer     = require "lib/hump/timer"
vector    = require "lib/hump/vector"

-- Load Mixins
require "mixins/corners"

-- Load Classes
require "collider"
require "player"
require "block"
require "bat"

function love.load()
  love.graphics.setBackgroundColor(0, 100, 100)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.math.setRandomSeed(os.time())

  --Create bump world
  world = bump.newWorld(64)

  --Create Objects
  player = Player:new(world, 128, 128)
  bats = { Bat:new(world, 480, 480), Bat:new(world, 380, 380), Bat:new(world, 280, 280) }

  --Create camera
  cam = camera(player.x, player.y)

  --Create map
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
end

function love.keyreleased(key)
  if key == "escape" then love.event.quit()
  elseif key == " "  then player:releaseAttack()
  elseif key == "up" then player:releaseJump()
  elseif key == "down" then player:releaseAirStab()
  end
end

function love.keypressed(key)
  if key == "up" then player:jump() end
end

function love.update(dt)
  player:update(dt)
  for i, bat in ipairs(bats) do
    bat:update(dt)
  end

  -- Make camera smooth-follow the player 
  if math.abs(player.x - cam.x) > 64 then
    tweenX = flux.to(cam, 0.1, {x = getNewCamX(cam.x, cam.y, player.x, player.y, 64)}):ease("linear")
  end
  cam.y = player.y 

  flux.update(dt)

  -- if love.keyboard.isDown("w") then
  --   cam.y = cam.y - 1
  -- elseif love.keyboard.isDown("s") then
  --   cam.y = cam.y + 1
  -- elseif love.keyboard.isDown("a") then
  --   cam.x = cam.x - 1
  -- elseif love.keyboard.isDown("d") then
  --   cam.x = cam.x + 1
  -- end
end

function love.draw()
  cam:attach()

  --Draw ground
  for i, row in pairs(map.blocks) do
    for j, tile in pairs(row) do
      tile:draw()
    end
  end

  --Draw player
  love.graphics.setColor(255, 255, 255)
  player:draw()
  for i, bat in ipairs(bats) do
    bat:draw()
  end

  -- drawCamera()

  cam:detach()

  --FPS
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: " .. love.timer.getFPS(), 2, 2)
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


-- Camera helpers
----------------------------------

function drawCamera()
  love.graphisc.setColor(255, 255, 255)
  love.graphics.line(cam.x, cam.y, player.x, player.y)
  love.graphics.setColor(0, 0, 255)
  love.graphics.circle("fill", cam.x, cam.y, 6, 20)
end


-- Returns a point d distance along the line from (x1, y1) to (x2, y2)
function getNewCamX(x1, y1, x2, y2, d)
  local px, py
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