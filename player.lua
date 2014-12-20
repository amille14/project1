require "physics_body"

Player = class("Player", PhysicsBody)

function Player:initialize(world, x, y)
  PhysicsBody.initialize(self, x, y, 32, 48, 40, 0.4, 4.5, 140, 9.81 * 7, 0.5)

  self.state = "idle"
  self.direction = "right"

  self.jumpTime = 0
  self.maxJumpTime = 80 -- in milliseconds
  self.jumpReleased = true
  self.canJump = true
  self.jumpCount = 0

  self.chargeTime = 0
  self.maxChargeTime = 1000 -- in milliseconds
  self.attackEnded = false

  self.hitStunned = false
  self.hitStunTime = 0
  self.maxHitStunTime = 500 -- in milliseconds

  debugger.state = debug.add("state")
  debugger.vx = debug.add("vx")
  debugger.vy = debug.add("vy")


  self.colliders = {
    ["attack"] = Collider:new("Attack", "Attack", self.x + self.w, self.y + 8, 48, self.h - 16, function()
      local this = self.colliders["attack"]
      if self.direction == "right" then this.x = self.x + self.w
      else this.x = self.x - this.w end
      this.y = self.y + 8
    end),
    ["airStab"] = Collider:new("AirStab", "Attack", self.x + 4, self.y + self.h - 16, 24, 32, function()
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
    self.colliders["attack"]:remove()
  end)
end


-- Movement
------------------------------------
function Player:releaseAttack()
  self.state = "attacking"
  self.colliders["attack"]:add()
end

function Player:releaseAirStab()
  self.colliders["airStab"]:remove()
  if self.state == "airStabbing" then self.state = "falling" end
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
      if self.vx < self.airSpeed then self.vx = self.vx + self.airSpeed * dt end
    end

  elseif love.keyboard.isDown("left") then
    self.direction = "left"
    if self.grounded then self.state = "walking" end
    if self.state ~= "walking" then stateChanged = true end
    
    if self.grounded then
      if self.vx > -self.speed then self.vx = self.vx - self.speed * dt end
    else
      if self.vx > -self.airSpeed then self.vx = self.vx - self.airSpeed * dt end
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
        self.colliders["airStab"]:add()
        self.state = "airStabbing"
      end

    -- Charge attack
    elseif love.keyboard.isDown(" ") then
      if self.state ~= "chargingAttack" then stateChanged = true end
      if stateChanged then
        self.animations["attacking"]:gotoFrame(1)
        self.animations["attacking"]:resume()
        self.state = "chargingAttack"
      end
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

  -- Hitstun
  -- if self.hitStunned then
  --   self.hitStunTime = self.hitStunTime + dt * 1000
  -- end

  -- if self.hitStunTime > self.maxHitStunTime then
  --   self.hitStunned = false
  --   self.hitStunTime = 0
  -- end

  -- Update colliders
  for name, collider in pairs(self.colliders) do
    collider:update(dt)
  end

  -- Collision detection
  self:handleCollisions()
  self:handleAirStabCollisions()
  self:handleAttackCollisions()

  -- Update animation
  self.currentAnim = self.animations[self.state]
  if stateChanged then self.currentAnim:gotoFrame(1) end
  self.currentAnim:update(dt)

  -- Update debugger
  debug.update(debugger.state, player.state)
  debug.update(debugger.vx, player.vx)
  debug.update(debugger.vy, player.vy)
end



-- Collisions
------------------------------------
local playerCollisionFilter = function(other)
  if other:typeOf("Block") then
    return "slide"
  elseif other:typeOf("Enemy") then
    return "bounce"
  end
end

local airStabCollisionFilter = function(other)
  if other:typeOf("Enemy") then
    return "bounce"
  end
end

local attackCollisionFilter = function(other)
  -- if other:typeOf("Enemy") then
  --   print("COLLIDED WITH ENEMY")
  --   return "cross"
  -- end
  return false
end

function Player:handleCollisions()
  local x, y, cols, len = world:move(self, self.x, self.y, playerCollisionFilter)
  self.x, self.y = x, y

  if len > 0 then
    for i, col in ipairs(cols) do
      if col.other:typeOf("Block") then
        if col.normal.x == 0 and col.normal.y == -1 then
          if not self.grounded and self.jumpReleased and col.other:typeOf("Block") then player.canJump = true end
          self.grounded = true
          self.vy = 0
          self.jumpTime = self.maxJumpTime
        elseif col.normal.x == 0 and col.normal.y == 1 then
          -- This works because blocks have "infinite" mass. Change this if you add movable blocks with mass!
          self.vy = self.vy * self.restitution
        end
      end

      if col.other:typeOf("Enemy") then
        if col.normal.x == 0 and col.normal.y == -1 then
          self.vy = 0
          self:applyImpulse(0, -20)
          col.other:knockback(col.other, 0, 6)
        end
      end
    end
  end
end

function Player:handleAirStabCollisions()
  local collider = self.colliders["airStab"]
  if self.state == "airStabbing" and world:hasItem(collider) then
    local x, y, cols, len = world:move(collider, collider.x, collider.y, airStabCollisionFilter)
    collider.x = x
    collider.y = y

    if len > 0 then
      for i, col in ipairs(cols) do
        if col.normal.x == 0 and col.normal.y == -1 then
          if col.other:typeOf("Enemy") then
            self.vy = 0
            self:applyImpulse(0, -25)
            col.other:knockback(col.other, 0, 8)
          end
        end
      end
    end  
  end
end

function Player:handleAttackCollisions()
  local collider = self.colliders["attack"]
  if self.state == "attacking" and world:hasItem(collider) then
    print("Here?")
    local x, y, cols, len = world:check(collider, collider.x, collider.y, attackCollisionFilter)
    collider.x = x
    collider.y = y

    print(len)

    if len > 0 then
      for i, col in ipairs(cols) do
        if col.other:typeOf("Enemy") then
          print("GOT HERE")
          self.vx = 0
          col.other:knockback(col.other, 8, 0)
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

  -- if self.hitStunned then
  --   love.graphics.setColor(255, 255 * self.hitStunTime/self.maxHitStunTime, 255 * self.hitStunTime/self.maxHitStunTime)
  -- else
  --   love.graphics.setColor(0, 255, 0)
  -- end
  self.currentAnim:draw(self.images[self.state], self.x + drawOffset.x, self.y + drawOffset.y, 0, sx, sy, ox, oy)


  -- Debugging
  if debug.__debugMode then
    self:drawOutline()
    for k, v in pairs(self.colliders) do
      if world:hasItem(v) then
        v:drawOutline(0, 0, 255)
        drawOutline(world.rects[v])
      end
    end
  end
end



-- Utility methods
--------------------------------------
function Player:typeOf(type)
  return type == "Player"
end

