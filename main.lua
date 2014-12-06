require "player"
bump = require "util/bump"

function love.load()
  love.graphics.setBackgroundColor(0, 100, 100)
  love.graphics.setDefaultFilter("nearest", "nearest")

  --Create the physics world
  -- love.physics.setMeter(64)
  -- world = love.physics.newWorld(0, 9.81*64, true)

  --Create bump world
  world = bump.newWorld(64)

  --Load Objects
  player = Player:new(world, 128, 128)
  -- ground = {}
  -- ground.body = love.physics.newBody(world, 650/2, 650-50/2, "static")
  -- ground.shape = love.physics.newRectangleShape(650, 50)
  -- ground.fixture = love.physics.newFixture(ground.body, ground.shape)
  -- ground.fixture:setUserData("ground")
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
  -- world:update(dt)
end

function love.draw()
  --Draw ground
  love.graphics.setColor(72, 160, 14)
  love.graphics.polygon("fill", 0, 600, 0, 768, 1080, 768, 1080, 600)

  --Draw player
  love.graphics.setColor(255, 255, 255)
  player:draw()
end