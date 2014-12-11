require "physics_body"

Player = class("Player", PhysicsBody)
local attackEnded = false

function Player:initialize(world, x, y)
  PhysicsBody.initialize(self, 32, 48, x, y, 40, 0.4, 4.5, 9.81 * 7, 0, false)

  self.state = "idle"
  self.direction = "right"
  self.speed = 140
  self.airSpeed = (1 / self.mass) * 8  -- Coefficient of air speed
  self.jumpTime = 0
  self.maxJumpTime = 80 -- in milliseconds
  self.jumpReleased = true
  self.chargeTime = 0
  self.maxChargeTime = 1000 -- in milliseconds

  -- Add body to bump world
  world:add(self, self.x, self.y, self.w, self.h)

  -- Load spritesheets & create animations
  self.images = {
    ["idle"] = love.graphics.newImage("images/player/idle.png"),
    ["walking"] = love.graphics.newImage("images/player/walking.png"),
    ["jumping"] = love.graphics.newImage("images/player/jumping.png"),
    ["falling"] = love.graphics.newImage("images/player/falling.png"),
    ["chargingAttack"] = love.graphics.newImage("images/player/attacking.png"),
    ["attacking"] = love.graphics.newImage("images/player/attacking.png"),
    ["airStabbing"] = love.graphics.newImage("images/player/air-stab.png")
  }
  self.frames = {
    ["idle"] = anim8.newGrid(32, 32, self.images["idle"]:getWidth(), self.images["idle"]:getHeight()),
    ["walking"] = anim8.newGrid(32, 32, self.images["walking"]:getWidth(), self.images["walking"]:getHeight()),
    ["jumping"] = anim8.newGrid(32, 32, self.images["jumping"]:getWidth(), self.images["jumping"]:getHeight()),
    ["falling"] = anim8.newGrid(32, 32, self.images["falling"]:getWidth(), self.images["falling"]:getHeight()),
    ["attacking"] = anim8.newGrid(64, 48, self.images["attacking"]:getWidth(), self.images["attacking"]:getHeight()),
    ["airStabbing"] = anim8.newGrid(64, 48, self.images["airStabbing"]:getWidth(), self.images["airStabbing"]:getHeight())
  }
  self.animations = {
    ["idle"] = anim8.newAnimation(self.frames["idle"]('1-2', 1), {0.6, 0.4}),
    ["walking"] = anim8.newAnimation(self.frames["walking"]('1-4', 1), 0.14),
    ["jumping"] = anim8.newAnimation(self.frames["jumping"]('1-1', 1), 0.1),
    ["falling"] = anim8.newAnimation(self.frames["falling"]('1-2', 1), {0.15, 0.1}),
    ["chargingAttack"] = anim8.newAnimation(self.frames["attacking"]('1-1', 1), 0.1),
    ["attacking"] = anim8.newAnimation(self.frames["attacking"]('1-5', 1), {0.06, 0.1, 0.02, 0.02, 0.3},
      function(anim, loops)
        anim:pauseAtEnd()
        attackEnded = true
      end),
    ["airStabbing"] = anim8.newAnimation(self.frames["airStabbing"]('3-3', 1), {0.3},
      function(anim, loops)
        anim:pauseAtEnd()
      end)
  }
end


-- Movement
------------------------------------
function Player:releaseAttack()
  self.state = "attacking"
end

function Player:releaseJump()
  self.jumpReleased = true
end

function Player:move(dt)
  -- Jumping
  if love.keyboard.isDown("up") then
    if self.grounded and self.jumpReleased then
      self:applyImpulse(0, -7)
      self.grounded = false
      self.jumpReleased = false

    elseif not self.grounded and self.jumpTime > 0 and not self.jumpReleased then
      self:applyImpulse(0, -6)
      self.jumpTime = self.jumpTime - dt * 1000
    end
  end

  -- Horizontal movement
  if love.keyboard.isDown("right") then
    self.direction = "right"
    if self.grounded then self.state = "walking" end
    if self.state ~= "walking" then stateChanged = true end
    
    if self.grounded then
      if self.vx < self.speed then self.vx = self.vx + self.speed * dt end
    else
      if self.vx < self.speed * self.airSpeed then self.vx = self.vx + self.speed * self.airSpeed * dt end
    end

  elseif love.keyboard.isDown("left") then
    self.direction = "left"
    if self.grounded then self.state = "walking" end
    if self.state ~= "walking" then stateChanged = true end
    
    if self.grounded then
      if self.vx > -self.speed then self.vx = self.vx - self.speed * dt end
    else
      if self.vx > -self.speed * self.airSpeed then self.vx = self.vx - self.speed * self.airSpeed * dt end
    end

  elseif self.grounded then
    if self.state ~= "idle" then stateChanged = true end
    self.state = "idle"
  end

  if not self.grounded and self.state ~= "airStabbing" then
    if self.vy < 6 then
      self.state = "jumping"
    else
      self.state = "falling"
    end
  end
end


-- Collisions
------------------------------------
function Player:handleCollisions()
  local x, y, cols, len = world:move(self, self.x, self.y, playerCollisionFilter)
  self.x, self.y = x, y

  if len > 0 then
    for i, v in ipairs(cols) do
      if v.other:typeOf("Block") then
        if v.normal.x == 0 and v.normal.y == -1 then
          self.grounded = true
          self.vy = 0
          self.jumpTime = self.maxJumpTime
        elseif v.normal.x == 0 and v.normal.y == 1 then
          self.vy = -self.vy * self.restitution
        end
      end
    end
  end
end

local playerCollisionFilter = function(other)
  if other:typeOf("Block") then
    return "slide"
  end
end



-- Update & Draw
------------------------------------
function Player:update (dt)
  local stateChanged = false

  -- Reset attack
  if attackEnded then
    self.state = "idle"
    attackEnded = false
    self.chargeTime = 0
  end

  if self.state ~= "attacking" then

    -- Air Stab
    if love.keyboard.isDown("down") and not self.grounded then
      if self.state ~= "airStabbing" then stateChanged = true end
      if stateChanged then
        self.animations["airStabbing"]:gotoFrame(1)
        self.animations["airStabbing"]:resume()
      end
      self.state = "airStabbing"
    
    -- Charge attack
    elseif love.keyboard.isDown(" ") then
      if self.state ~= "chargingAttack" then stateChanged = true end
      if stateChanged then
        self.animations["attacking"]:gotoFrame(1)
        self.animations["attacking"]:resume()
      end
      self.state = "chargingAttack"

      self.chargeTime = self.chargeTime + dt * 1000
    end

    -- Movement
    if self.state ~= "chargingAttack" then
      self:move(dt)
    end
  end

  -- Update physics
  self:updatePhysics(dt)

  -- Collision detection
  self:handleCollisions()
  if self.grounded then  
    self.jumpTime = self.maxJumpTime
  end

  -- Update animation
  self.currentAnim = self.animations[self.state]
  if stateChanged then self.currentAnim:gotoFrame(1) end
  self.currentAnim:update(dt)

  -- Attack self-knockback
  -- if self.state == "attacking" and self.currentAnim.position == 4 and self.chargeTime > 200 then
  --   if self.direction == "right" then
  --     self:applyForce(-self.chargeTime * 10, 0)
  --   else
  --     self:applyForce(self.chargeTime * 10, 0)
  --   end
  -- end
  -- if self.chargeTime > self.maxChargeTime then self:releaseAttack() end
end


function Player:draw ()
  local sx, sy, ox, oy = 2, 2, 0, 0
  local drawOffset = {
    x = -16,
    y = -16
  }

  if self.direction == "right" then
    self.currentAnim.flippedH = false
  elseif self.direction == "left" then
    self.currentAnim.flippedH = true
  end

  if self.state == "attacking" or self.state == "chargingAttack" or self.state == "airStabbing" then
    ox = 16
  end

  self.currentAnim:draw(self.images[self.state], self.x + drawOffset.x, self.y + drawOffset.y, 0, sx, sy, ox, oy)
  -- self:drawOutline()
end