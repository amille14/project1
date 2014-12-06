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
  player = Player:new(nil, world, 128, 128)
  -- ground = {}
  -- ground.body = love.physics.newBody(world, 650/2, 650-50/2, "static")
  -- ground.shape = love.physics.newRectangleShape(650, 50)
  -- ground.fixture = love.physics.newFixture(ground.body, ground.shape)
  -- ground.fixture:setUserData("ground")
end

function love.keyreleased(key)
  if key == " " then
    player:attackReleased()
  end

  if key == "up" then
    player:jumpReleased()
  end
end

function love.update(dt)
  player:update(dt)
  -- world:update(dt)
end

function love.draw()
  --Draw ground
  love.graphics.setColor(72, 160, 14)
  -- x1, y1, x2, y2, x3, y3, x4, y4 = ground.body:getWorldPoints(ground.shape:getPoints())
  -- love.graphics.polygon("fill", x1, y1 + 50, x2, y2 + 50, x3, y3 + 50, x4, y4 + 50)

  --Draw player
  love.graphics.setColor(255, 255, 255)
  player:draw()
end