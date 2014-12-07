-- Load Libraries
class = require "lib/middleclass"
bump  = require "lib/bump"
anim8 = require "lib/anim8"
serpent = require "lib/serpent"

-- Load Mixins
require "mixins/corners"

-- Load Object Classes
require "player"
require "block"


function love.load()
  love.graphics.setBackgroundColor(0, 100, 100)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.math.setRandomSeed(os.time())

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
      if j == map.heightInTiles - 8 and i > map.widthInTiles / 2 or j == map.heightInTiles - 1 then
        print(i, j)
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
end

function love.draw()
  --Draw ground
  for i, row in pairs(map.blocks) do
    for j, tile in pairs(row) do
      tile:draw()
    end
  end

  --Draw player
  love.graphics.setColor(255, 255, 255)
  player:draw()

  --FPS
  love.graphics.print("FPS: " .. love.timer.getFPS(), 2, 2)
end