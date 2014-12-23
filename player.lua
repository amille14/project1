require "physics_body"

------------------------------------
-- INITIALIZE PLAYER
------------------------------------
Player = class("Player", PhysicsBody)
function Player:initialize(x, y)
  PhysicsBody.initialize(self, x, y, 32, 48, 40, 0.4, 4.5, 140, 9.81 * 7, 0.5)
  world:add(self, self.x, self.y, self.w, self.h)

  self.state = "idle"
  self.direction = "right"
  self.stateChanged = false
  self.abilityEnded = false

  self.jumpTime = 0
  self.maxJumpTime = 80 -- in milliseconds
  self.jumpReleased = true
  self.canJump = true
  self.jumpCount = 0

  self.hitStunned = false
  self.hitStunTime = 0
  self.maxHitStunTime = 500 -- in milliseconds

  debugger.state = debug.add("state")
  debugger.vx = debug.add("vx")
  debugger.vy = debug.add("vy")
  debugger.ability = debug.add("ability")


  -- -- Colliders
  -- ------------------------------------
  -- self.colliders = {
  --   ["attack"] = Collider:new("Attack", "Attack", self.x + self.w, self.y + 8, 40, self.h, function()
  --     local this = self.colliders["attack"]
  --     if self.direction == "right" then this.x = self.x + self.w
  --     else this.x = self.x - this.w end
  --     this.y = self.y + 8
  --   end),
  --   ["airStab"] = Collider:new("AirStab", "Attack", self.x + 4, self.y + self.h - 16, 24, 32, function()
  --     self.colliders["airStab"].x = self.x + 4
  --     self.colliders["airStab"].y = self.y + self.h - 16
  --   end)
  -- }


  -- Spritesheets & Animations
  ------------------------------------
  local img = {
    ["idle"]    = love.graphics.newImage("images/player/idle.png"),
    ["walking"] = love.graphics.newImage("images/player/walking.png"),
    ["jumping"] = love.graphics.newImage("images/player/jumping.png"),
    ["falling"] = love.graphics.newImage("images/player/falling.png"),

    ["sword-neutral"] = love.graphics.newImage("images/player/sword/sword-neutral.png"),
    -- ["sword-neutral-charging"] = love.graphics.newImage("images/player/sword/sword-neutral-charging.png"),
    -- ["sword-neutral-charged"] = love.graphics.newImage("images/player/sword/sword-neutral-charged.png")
    ["sword-down-air"] = love.graphics.newImage("images/player/sword/sword-down-air.png")

    -- ["chargingAttack"] = love.graphics.newImage("images/player/attacking.png"),
    -- ["attacking"]      = love.graphics.newImage("images/player/attacking.png"),
    -- ["airStabbing"]    = love.graphics.newImage("images/player/air-stab.png")
  }
  local frames = {
    ["idle"]    = anim8.newGrid(32, 32, img["idle"]:getWidth(), img["idle"]:getHeight()),
    ["walking"] = anim8.newGrid(32, 32, img["walking"]:getWidth(), img["walking"]:getHeight()),
    ["jumping"] = anim8.newGrid(32, 32, img["jumping"]:getWidth(), img["jumping"]:getHeight()),
    ["falling"] = anim8.newGrid(32, 32, img["falling"]:getWidth(), img["falling"]:getHeight()),

    ["sword-neutral"] = anim8.newGrid(64, 48, img["sword-neutral"]:getWidth(), img["sword-neutral"]:getHeight()),
    ["sword-neutral-charging"] = anim8.newGrid(64, 48, img["sword-neutral"]:getWidth(), img["sword-neutral"]:getHeight()),
    ["sword-neutral-charged"] = anim8.newGrid(64, 48, img["sword-neutral"]:getWidth(), img["sword-neutral"]:getHeight()),
    ["sword-down-air"] = anim8.newGrid(64, 48, img["sword-down-air"]:getWidth(), img["sword-down-air"]:getHeight())

    -- ["attacking"]   = anim8.newGrid(64, 48, self.images["attacking"]:getWidth(), self.images["attacking"]:getHeight()),
    -- ["airStabbing"] = anim8.newGrid(64, 48, self.images["airStabbing"]:getWidth(), self.images["airStabbing"]:getHeight())
  }
  self.anims = {
    ["idle"]    = anim8.newAnimation(img["idle"], frames["idle"]('1-2', 1), {0.6, 0.4}),
    ["walking"] = anim8.newAnimation(img["walking"], frames["walking"]('1-4', 1), 0.14),
    ["jumping"] = anim8.newAnimation(img["jumping"], frames["jumping"]('1-1', 1), 0.1),
    ["falling"] = anim8.newAnimation(img["falling"], frames["falling"]('1-2', 1), {0.15, 0.1}),
    ["ability"] = {
      ["sword-neutral"] = anim8.newAnimation(img["sword-neutral"], frames["sword-neutral"]('1-5', 1), {0.06, 0.1, 0.02, 0.02, 0.3}, function(anim, loops) signal.emit("player-sword-neutral-ended", anim) end),
      ["sword-neutral-charging"] = anim8.newAnimation(img["sword-neutral"], frames["sword-neutral"]('1-1', 1), 0.1),
      ["sword-neutral-charged"] = anim8.newAnimation(img["sword-neutral"], frames["sword-neutral-charged"]('1-5', 1), {0.06, 0.1, 0.02, 0.02, 0.3}, function(anim, loops) signal.emit("player-sword-neutral-ended", anim) end),
      ["sword-down-air"] = anim8.newAnimation(img["sword-down-air"], frames["sword-down-air"]('1-3', 1), {0.04, 0.04, 0.1}, function(anim, loops) signal.emit("player-sword-down-air-ended", anim) end)
    }

    -- ["chargingAttack"] = anim8.newAnimation(self.frames["attacking"]('1-1', 1), 0.1),
    -- ["attacking"] = anim8.newAnimation(self.frames["attacking"]('1-5', 1), {0.06, 0.1, 0.02, 0.02, 0.3},
    --   function(anim, loops)
    --     anim:pauseAtEnd()
    --     signal.emit("player-attack-ended", anim)
    --   end),
    -- ["airStabbing"] = anim8.newAnimation(self.frames["airStabbing"]('1-3', 1), {0.04, 0.04, 0.1},
    --   function(anim, loops)
    --     anim:pauseAtEnd()
    --   end)
  }


  -- Abilities
  ------------------------------------
  self.abilities = {
    {
      ["neutral"] = SwordNeutral:new(self, "player-sword-neutral-ended", {
                      ["uncharged"] = self.anims["ability"]["sword-neutral"],
                      ["charging"] = self.anims["ability"]["sword-neutral-charging"],
                      ["charged"] = self.anims["ability"]["sword-neutral-charged"]}),

      ["down-air"] = SwordDownAir:new(self, "player-sword-down-air-ended", {
                      ["uncharged"] = self.anims["ability"]["sword-down-air"]})
      -- ["side"] = SwordSide:new(),
      -- ["up"]   = SwordUp:new(),
      -- ["down"] = SwordDown:new()
    }
  }

  self.currentAbility = nil

  signal.register("player-ability-ended", function()
    self.abilityEnded = true
  end)
end

function Player:typeOf(type)
  return type == "Player"
end


------------------------------------
-- MOVEMENT & ABILITIES
------------------------------------
function Player:move(dt)


  -- Jumping
  ------------------------------------
  if love.keyboard.isDown("up") then
    if self.grounded and self.jumpReleased then
      self.canJump = true

    elseif not self.grounded and self.jumpTime > 0 and not self.jumpReleased then
      self:applyImpulse(0, -6)
      self.jumpTime = self.jumpTime - dt * 1000
    end
  end


  -- Horizontal Movement
  ------------------------------------

  -- Walk Right
  if love.keyboard.isDown("right") then
    self.direction = "right"
    if self.grounded then self.state = "walking" end
    if self.state ~= "walking" then self.stateChanged = true end
    
    if self.grounded then
      if self.vx < self.speed then self.vx = self.vx + self.speed * dt end
    else
      if self.vx < self.airSpeed then self.vx = self.vx + self.airSpeed * dt end
    end

  -- Walk Left
  elseif love.keyboard.isDown("left") then
    self.direction = "left"
    if self.grounded then self.state = "walking" end
    if self.state ~= "walking" then self.stateChanged = true end
    
    if self.grounded then
      if self.vx > -self.speed then self.vx = self.vx - self.speed * dt end
    else
      if self.vx > -self.airSpeed then self.vx = self.vx - self.airSpeed * dt end
    end

  -- Idle
  elseif self.grounded then
    if self.state ~= "idle" then self.stateChanged = true end
    self.state = "idle"
  end

  -- Jumping & Falling
  if not self.grounded and self.state ~= "ability" then
    if self.vy < 6 then
      self.state = "jumping"
    else
      self.state = "falling"
    end
  end
end


-- Keypress/Keyrelease Callbacks
------------------------------------
-- function Player:releaseAttack()
--   self.state = "attacking"
-- end

-- function Player:releaseAirStab()
--   self.colliders["airStab"]:remove()
--   if self.state == "airStabbing" then self.state = "falling" end
-- end

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

function Player:executeAbility(slot, direction)
  if self.state ~= "ability" then
    if not self.grounded and self.abilities[slot][direction.."-air"] ~= nil then direction = direction .. "-air" end
    if self.abilities[slot][direction] ~= nil then
      self.state = "ability"
      self.stateChanged = true
      self.currentAbility = self.abilities[slot][direction]
      self.currentAbility:execute()
    end
  end
end

function Player:releaseAbility()
  if self.state == "ability" and self.currentAbility ~= nil then
    self.currentAbility:release()
  end
end



------------------------------------
-- UPDATE
------------------------------------
function Player:update (dt)

  -- -- Reset Attack
  -- if self.attackEnded then
  --   self.state = "idle"
  --   self.chargeTime = 0
  --   self.attackEnded = false
  -- end

  -- if self.state ~= "attacking" then

  --   -- Start Air Stab
  --   if love.keyboard.isDown("down") and not self.grounded then
  --     if self.state ~= "airStabbing" then stateChanged = true end
  --     if stateChanged then
  --       self.anims["airStabbing"]:gotoFrame(1)
  --       self.anims["airStabbing"]:resume()
  --       self:applyImpulse(0, 10)
  --       self.colliders["airStab"]:add()
  --       self.state = "airStabbing"
  --     end

  --   -- Start Charge attack
  --   elseif love.keyboard.isDown(" ") then
  --     if self.state ~= "chargingAttack" then stateChanged = true end
  --     if stateChanged then
  --       self.anims["attacking"]:gotoFrame(1)
  --       self.anims["attacking"]:resume()
  --       self.state = "chargingAttack"
  --     end
  --     self.chargeTime = self.chargeTime + dt * 1000
  --   end

  --   -- Movement
  --   if self.state ~= "chargingAttack" then
  --     self:move(dt)
  --   end

  -- else
  --   local frame = self.anims["attacking"].position
  --   if frame == 3 then
  --     self.colliders["attack"]:add()
  --   elseif frame == 5 then
  --     self.colliders["attack"]:remove()
  --   end
  -- end

  if self.abilityEnded then
    self.state = "idle"
    self.currentAbility:reset()
    self.currentAbility = nil
    self.abilityEnded = false
  end

  if self.state ~= "ability" or (self.state == "ability" and self.currentAbility.canMove) then
    self:move(dt)
  end

  -- Update Physics
  ------------------------------------
  self:updatePhysics(dt)
  self.grounded = false
  -- for name, collider in pairs(self.colliders) do
  --   collider:update(dt)
  -- end
  self:handleCollisions()
  -- self:handleAirStabCollisions()
  -- self:handleAttackCollisions()

  if self.currentAbility ~= nil then
    self.currentAbility:update(dt)
  end


  -- Update Animation
  ------------------------------------
  if self.state ~= "ability" then
    self.currentAnim = self.anims[self.state]
    if self.stateChanged then
      self.currentAnim:gotoFrame(1)
      self.stateChanged = false
    end
  else
    self.currentAnim = self.currentAbility.currentAnim
  end
  self.currentAnim:update(dt)


  -- Update Debugger
  ------------------------------------
  debug.update(debugger.state, self.state)
  debug.update(debugger.vx, self.vx)
  debug.update(debugger.vy, self.vy)
  if self.currentAbility ~= nil then
    debug.update(debugger.ability, serialize.dump(self.currentAbility))
  else
    debug.update(debugger.ability, "none")
  end
end



------------------------------------
-- COLLISIONS
------------------------------------


-- Collision Filters
------------------------------------
local collisionFilter = function(other)
  if other:typeOf("Block") then
    return "slide"
  elseif other:typeOf("Enemy") then
    return "bounce"
  end
end

-- local airStabCollisionFilter = function(other)
--   if other:typeOf("Enemy") then
--     return "slide"
--   end
-- end

-- local attackCollisionFilter = function(other)
--   if other:typeOf("Enemy") then
--     return "cross"
--   end
-- end


-- Collision Handlers
------------------------------------
function Player:handleCollisions()
  local x, y, cols, len = world:move(self, self.x, self.y, collisionFilter)
  self.x, self.y = x, y

  if len > 0 then
    for i, col in ipairs(cols) do

      -- Block Collisions
      if col.other:typeOf("Block") then
        if col.normal.x == 0 and col.normal.y == -1 then
          if not self.grounded and self.jumpReleased and col.other:typeOf("Block") then player.canJump = true end
          self.grounded = true
          self.vy = 0
          self.jumpTime = self.maxJumpTime
        elseif col.normal.x == 0 and col.normal.y == 1 then
          self.vy = self.vy * self.restitution -- This works because blocks have "infinite" mass. Change this if you add movable blocks with mass!
        end
      end

      -- Enemy Collisions
      if col.other:typeOf("Enemy") then
        if col.normal.x == 0 and col.normal.y == -1 then
          self.vy = 0
          self:applyImpulse(0, -20)
          col.other:knockback(self, 0, 8)
        end
      end
    end
  end
end

-- -- Air Stab
-- function Player:handleAirStabCollisions()
--   local collider = self.colliders["airStab"]
--   if self.state == "airStabbing" and world:hasItem(collider) then
--     local x, y, cols, len = world:move(collider, collider.x, collider.y, airStabCollisionFilter)
--     collider.x = x
--     collider.y = y

--     if len > 0 then
--       for i, col in ipairs(cols) do
--         if col.normal.x == 0 and col.normal.y == -1 then

--           -- Enemy Collisions
--           if col.other:typeOf("Enemy") then
--             self.vy = 0
--             self:applyImpulse(0, -25)
--             col.other:knockback(self, 0, 12)
--           end
--         end
--       end
--     end  
--   end
-- end

-- -- Attack
-- function Player:handleAttackCollisions()
--   local collider = self.colliders["attack"]
--   if self.state == "attacking" and world:hasItem(collider) then
--     local x, y, cols, len = world:check(collider, collider.x, collider.y, attackCollisionFilter)
--     collider.x = x
--     collider.y = y

--     if len > 0 then
--       for i, col in ipairs(cols) do

--         -- Enemy Collisions
--         if col.other:typeOf("Enemy") and not collider.collidedWith[col.other] then
--           collider.collidedWith[col.other] = true
--           self.vx = 0
--           local power = self.chargeTime / 1000 * 16 + 12
--           if     self.direction == "right" then col.other:knockback(self, power, -power/4)
--           elseif self.direction == "left" then col.other:knockback(self, -power, -power/4) end
--         end
--       end
--     end 
--   end
-- end



------------------------------------
-- DRAW
------------------------------------
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
  if self.state == "ability" then
    ox = 16
  end

  self.currentAnim:draw(self.x + drawOffset.x, self.y + drawOffset.y, 0, sx, sy, ox, oy)


  -- Debugging
  ------------------------------------
  if debug.__debugMode then
    self:drawOutline()

    if self.state == "ability" then
      for k, col in pairs(self.currentAbility.colliders) do
        if world:hasItem(col) then col:drawOutline(255, 0, 0) end
      end
    end
  end
end

