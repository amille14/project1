require "util/class"
require "physics_body"
anim8 = require "util/anim8"
bump = require "util/bump"

Player = createClass("PhysicsBody")
local attackEnded = false
local gravity = 9.81
local friction = 10
local airDamping = 6
local maxJumpTime = 28
local jumpTime = maxJumpTime
local jumpConstant = 0.5

function Player:new (o, world, x, y)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- Initialize variables
  -- self.body = love.physics.newBody(world, x, y, "dynamic")
  -- self.shape = love.physics.newRectangleShape(64, 64)
  -- self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  -- self.fixture:setUserData("player")

  self.state = "idle"
  self.direction = "right"
  self.grounded = true

  self.x = x
  self.y = y
  self.width = 64
  self.height = 64
  self.mass = 8
  self.speed = 80
  self.velX = 0
  self.velY = 0
  self.accX = 0
  self.accY = gravity * self.mass

  -- Add player to bump world
  world:add(self, self.x, self.y, self.width, self.height)

  -- Load spritesheets & create animations
  self.images = {
    ["idle"] = love.graphics.newImage("images/player/idle-right.png"),
    ["walking"] = love.graphics.newImage("images/player/walking-right.png"),
    ["chargingAttack"] = love.graphics.newImage("images/player/attacking-right.png"),
    ["attacking"] = love.graphics.newImage("images/player/attacking-right.png")
  }
  self.frames = {
    ["idle"] = anim8.newGrid(32, 32, self.images["idle"]:getWidth(), self.images["idle"]:getHeight()),
    ["walking"] = anim8.newGrid(32, 32, self.images["walking"]:getWidth(), self.images["walking"]:getHeight()),
    ["attacking"] = anim8.newGrid(64, 48, self.images["attacking"]:getWidth(), self.images["attacking"]:getHeight())
  }
  self.animations = {
    ["idle"] = anim8.newAnimation(self.frames["idle"]('1-2', 1), {0.6, 0.4}),
    ["walking"] = anim8.newAnimation(self.frames["walking"]('1-4', 1), 0.1),
    ["chargingAttack"] = anim8.newAnimation(self.frames["attacking"]('1-1', 1), 0.1),
    ["attacking"] = anim8.newAnimation(self.frames["attacking"]('1-5', 1), {0.06, 0.1, 0.02, 0.02, 0.3},
      function(anim, loops)
        anim:pauseAtEnd()
        attackEnded = true
      end)
  }

  return o
end

function Player:attackReleased()
  self.state = "attacking"
end

function Player:jumpReleased()
  if not self.grounded and self.velY > 0 then
    self.velY = self.velY * 0.5
  end
end

function Player:update (dt)
  -- local stateChanged = false

  -- if attackEnded then
  --   self.state = "idle"
  --   attackEnded = false
  -- end

  -- if self.state ~= "attacking" then
  --   if love.keyboard.isDown(" ") then
  --     if self.state ~= "chargingAttack" then stateChanged = true end
  --     if stateChanged then
  --       self.animations["attacking"]:gotoFrame(1)
  --       self.animations["attacking"]:resume()
  --     end
  --     self.state = "chargingAttack"
  --   end

  --   if self.state ~= "chargingAttack" then
  --     if love.keyboard.isDown("right") then
  --       -- self.body:applyForce(200, 0)
  --       if self.state ~= "walking" then stateChanged = true end
  --       self.state = "walking"
  --       self.direction = "right"

  --     elseif love.keyboard.isDown("left") then
  --       -- self.body:applyForce(-200, 0)
  --       if self.state ~= "walking" then stateChanged = true end
  --       self.state = "walking"
  --       self.direction = "left"

  --     else
  --       if self.state ~= "idle" then stateChanged = true end
  --       self.state = "idle"
  --     end
  --   end
  -- end

  -- if love.keyboard.isDown("up") and self.grounded then
  --   -- self.body:applyLinearImpulse(0, -10)
  -- end

  -- Horizontal Movement
  if love.keyboard.isDown("right") then
    self.state = "walking"
    self.direction = "right"
    if self.velX < self.speed then self.velX = self.velX + self.speed * dt end

  elseif love.keyboard.isDown("left") then
    self.state = "walking"
    self.direction = "left"
    if self.velX > -self.speed then self.velX = self.velX - self.speed * dt end

  else
    self.state = "idle"
  end

  -- Vertical Movement
  if love.keyboard.isDown("up") then
    -- if jumpTime > 0 then
    --   grounded = false
    --   jumpTime = jumpTime - dt * 100
    --   self.velY = -jumpTime * jumpConstant
    -- end
    
    self.grounded = false
    self.velY = self.velY - 300 * dt
  end

  -- Update position
  self.velX = self.velX + self.accX * dt
  self.velY = self.velY + self.accY * dt
  if grounded then self.velX = self.velX * (1 - math.min(dt * friction, 1)) end  -- Friction
  if not grounded then self.velX = self.velX * (1 - math.min(dt * airDamping, 1)) end  -- Air Damping
  self.x = self.x + self.velX
  self.y = self.y + self.velY

  print(self.velY)
  -- print(jumpTime)

  if self.y > 600 then
    self.y = 600
    self.velY = 0
    self.grounded = true
    jumpTime = maxJumpTime
  end

  -- Update animation
  self.currentAnim = self.animations[self.state]
  if stateChanged then self.currentAnim:gotoFrame(1) end
  self.currentAnim:update(dt)
end


function Player:draw ()
  local sx, sy, ox, oy = 2, 2, 0, 0

  if self.direction == "right" then
    self.currentAnim.flippedH = false
  elseif self.direction == "left" then
    self.currentAnim.flippedH = true
  end

  if self.state == "attacking" or self.state == "chargingAttack" then
    ox = 16
  end

  self.currentAnim:draw(self.images[self.state], self.x, self.y, 0, sx, sy, ox, oy)

  -- self.currentAnim:draw(self.images[self.state], self.body:getX(), self.body:getY(), 0, sx, sy, ox, oy)
end