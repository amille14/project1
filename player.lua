require "physics_body"

Player = class("Player", PhysicsBody)

function Player:initialize(world, x, y)
  PhysicsBody.initialize(self, x, y, 32, 48, 40, 0.4, 4.5, 9.81 * 7, 0)

  self.state = "idle"
  self.direction = "right"
  self.speed = 140
  self.airSpeed = (1 / self.mass) * 8  -- Coefficient of air speed
  self.jumpTime = 0
  self.maxJumpTime = 80 -- in milliseconds
  self.jumpReleased = true
  self.canJump = true
  self.jumpCount = 0
  self.chargeTime = 0
  self.maxChargeTime = 1000 -- in milliseconds
  self.attackEnded = false

  self.colliders = {
    ["attack"] = Collider:new("Attack", self.x + self.w, self.y, 32, self.h - 8, "Attack", function()
      local this = self.colliders["attack"]
      if self.direction == "right" then this.x = self.x + self.w
      else this.x = self.x - this.w end
      this.y = self.y + 8
    end),
    ["airStab"] = Collider:new("AirStab", self.x + 4, self.y + self.h - 16, 24, 32, "Attack", function()
      self.colliders["airStab"].x = self.x + 4
      self.colliders["airStab"].y = self.y + self.h - 16
    end)
  }

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
        signal.emit("player-attack-ended", anim)
      end),
    ["airStabbing"] = anim8.newAnimation(self.frames["airStabbing"]('1-3', 1), {0.04, 0.04, 0.1},
      function(anim, loops)
        anim:pauseAtEnd()
      end)
  }

  -- Register callbacks
  signal.register("player-attack-ended", function(anim, loops)
    self.attackEnded = true
    world:remove(self.colliders["attack"])
  end)
end


-- Movement
------------------------------------
function Player:releaseAttack()
  self.state = "attacking"
end

function Player:releaseAirStab()
  local collider = self.colliders["airStab"]
  if self.state == "airStabbing" and world:hasItem(collider) then
    world:remove(collider)
    self.state = "falling"
  end
end

function Player:releaseJump()
  self.jumpReleased = true
  if self.grounded then self.canJump = true end
end

function Player:jump()
  if self.canJump then
    self:applyImpulse(0, -7)
    self.grounded = false
    self.jumpReleased = false
    self.canJump = false
  end
end

function Player:move(dt)
  -- Jumping
  if love.keyboard.isDown("up") then
    if self.grounded and self.jumpReleased then
      self.canJump = true

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


-- Update
------------------------------------
function Player:update (dt)
  local stateChanged = false

  -- Reset attack
  if self.attackEnded then
    self.state = "idle"
    self.attackEnded = false
    self.chargeTime = 0
  end

  if self.state ~= "attacking" then

    -- Air Stab
    if love.keyboard.isDown("down") and not self.grounded then
      if self.state ~= "airStabbing" then stateChanged = true end
      if stateChanged then
        self.animations["airStabbing"]:gotoFrame(1)
        self.animations["airStabbing"]:resume()
        self:applyImpulse(0, 10)
      end

      if not world:hasItem(self.colliders["airStab"]) then
        self.colliders["airStab"]:add()
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
  self.grounded = false

  -- Update colliders
  for name, collider in pairs(self.colliders) do
    collider:update(dt)
  end

  -- Collision detection
  self:handleCollisions()

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



-- Collisions
------------------------------------
local playerCollisionFilter = function(other)
  if other:typeOf("Block") then
    return "slide"
  elseif other:typeOf("Enemy") then
    return "bounce"
  elseif other:typeOf("Attack") then
    return "cross"
  end
end

local attackCollisionFilter = function(other)
  if other:typeOf("Player") then
    return "cross"
  elseif other:typeOf("Enemy") then
    return "bounce"
  else
    return "cross"
  end
end

function Player:handleCollisions()
  -- Handle body collisions
  local x, y, cols, len = world:move(self, self.x, self.y, playerCollisionFilter)
  self.x, self.y = x, y

  if len > 0 then
    for i, col in ipairs(cols) do
      if col.other:typeOf("Block") or col.other:typeOf("Enemy") then
        if col.normal.x == 0 and col.normal.y == -1 then
          if not self.grounded and self.jumpReleased and col.other:typeOf("Block") then player.canJump = true end
          self.grounded = true
          self.vy = 0
          self.jumpTime = self.maxJumpTime
        elseif col.normal.x == 0 and col.normal.y == 1 then
          self.vy = -self.vy * self.restitution
        end
      end

      if col.other:typeOf("Enemy") then
        if col.normal.x == 0 and col.normal.y == -1 then
          if self.direction == "left" then
            self:applyImpulse(-5, -10)
            col.other:applyImpulse(5, 10)
          elseif self.direction == "right" then
            self:applyImpulse(5, -10)
            col.other:applyImpulse(-5, 10)
          end
        end
      end
    end
  end

  -- Handle attack collisions
  local collider = self.colliders["airStab"]
  if self.state == "airStabbing" and world:hasItem(collider) then
    local x, y, cols, len = world:move(collider, collider.x, collider.y, attackCollisionFilter)
    -- collider.x = x
    -- collider.y = y

    if len > 0 then
      for i, col in ipairs(cols) do
        if col.normal.x == 0 and col.normal.y == -1 then
          if col.other:typeOf("Block") then
            self.vy = 0
            self:applyImpulse(0, -25)
          end

          if col.other:typeOf("Enemy") then
            self.vy = 0
            self:applyImpulse(0, -25)
            col.other:applyImpulse(0, 20)
          end
        end
      end
    end  
  end
end


-- Draw
-----------------------------
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


  -- Debugging
  self:drawOutline()

  -- drawOutline(self.colliders["airStab"])

  for k, v in pairs(self.colliders) do
    v:drawOutline(255, 0, 0)
  end
end



-- Utility methods
--------------------------------------
function Player:typeOf(type)
  return type == "Player"
end

