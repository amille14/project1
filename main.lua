-- Load Libraries
_ = require "lib/lume"
class = require "lib/middleclass"
bump  = require "lib/bump"
anim8 = require "lib/anim8"
flux  = require "lib/flux"
serialize = require "lib/ser"
camera    = require "lib/hump/camera"
gamestate = require "lib/hump/gamestate"
signal    = require "lib/hump/signal"
timer     = require "lib/hump/timer"
vector    = require "lib/hump/vector"

-- Load Mixins
require "mixins/corners"

-- Load Classes
require "player"
require "block"


function love.load()
  love.graphics.setBackgroundColor(0, 100, 100)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.math.setRandomSeed(os.time())

  --Create camera
  cam = camera(128, 128)

  --Create bump world
  world = bump.newWorld(64)

  --Load Objects
  player = Player:new(world, 128, 128)

  --Create map
  map = {
    blocks = {},
    width = love.window.getWidth(),
    height = love.window.getHeight(),
    tileSize = 32
  }
  map.widthInTiles = map.width / map.tileSize
  map.heightInTiles = map.height / map.tileSize

  for i = 0, map.widthInTiles do
    for j = 0, map.heightInTiles do
      if j == map.heightInTiles - 7 and i > map.widthInTiles / 2 or j == map.heightInTiles - 1 then
        map.blocks[i] = map.blocks[i] or {}
        map.blocks[i][j] = Block:new(world, map.tileSize, map.tileSize, i * map.tileSize, j * map.tileSize)
      end
    end
  end
end

function love.keyreleased(key)
  if key == " " then
    player:releaseAttack()
  end

  if key == "up" then
    player:releaseJump()
  end
end

function love.update(dt)
  player:update(dt)
  cam:lookAt(player.x, player.y)
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


  cam:detach()

  --FPS
  love.graphics.print("FPS: " .. love.timer.getFPS(), 2, 2)
end