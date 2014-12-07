require "player"
require "block"
bump = require "util/bump"

function love.load()
  love.graphics.setBackgroundColor(0, 100, 100)
  love.graphics.setDefaultFilter("nearest", "nearest")

  --Create bump world
  world = bump.newWorld(64)

  --Load Objects
  player = Player:new(world, 128, 128)

  --Create tiles
  map = {}
  for i = 0, love.window.getWidth() / 32 do
    map[i] = Block:new(world, 32, 32, i * 32, love.window.getHeight() - 32)
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
  -- love.graphics.setColor(72, 160, 14)
  -- love.graphics.polygon("fill", 0, 600, 0, 768, 1080, 768, 1080, 600)
  for i, v in ipairs(map) do
    v:draw()
  end

  --Draw player
  love.graphics.setColor(255, 255, 255)
  player:draw()
end