------------------------------------
-- INITIALIZE PLAYER
------------------------------------
Player = class("Player", PhysicsBody)
Player:include(Health)
Player:include(Hitstun)
function Player:initialize(x, y)
  PhysicsBody.initialize(self, x, y, 32, 48, 60, 0.16, 0.01, 50, -0.3)
  world:add(self, self.x, self.y, self.w, self.h)
  self:initializeHealth()
  self:initializeHitstun()

  self.state = "idle"
  self.direction = "right"
  self.stateChanged = false
  self.abilityEnded = false

  self.speed = 110
  self.airSpeed = 12

  self.jumpTime = 0
  self.maxJumpTime = 80 -- in milliseconds
  self.jumpReleased = true
  self.canJump = true

  debugger.state = debug.add("state")
  debugger.vx = debug.add("vx")
  debugger.vy = debug.add("vy")
  debugger.ability = debug.add("ability")
  debugger.damage = debug.add("damage")


  -- Spritesheets & Animations
  ------------------------------------
  local img = {
    ["idle"]    = love.graphics.newImage("images/player/idle.png"),
    ["walking"] = love.graphics.newImage("images/player/walking.png"),
    ["jumping"] = love.graphics.newImage("images/player/jumping.png"),
    ["falling"] = love.graphics.newImage("images/player/falling.png"),

    ["sword-neutral"] = love.graphics.newImage("images/player/sword/sword-neutral.png"),
    -- ["sword-neutral-charging"] = love.graphics.newImage("images/player/sword/sword-neutral-charging.png"),
    -- ["sword-neutral-charged"] = love.graphics.newImage("images/player/sword/sword-neutral-charged.png"),
    ["sword-side"] = love.graphics.newImage("images/player/sword/sword-side.png"),
    -- ["sword-side-charging"] = love.graphics.newImage("images/player/sword/sword-side-charging.png"),
    -- ["sword-side-charged"] = love.graphics.newImage("images/player/sword/sword-side-charged.png"),
    ["sword-up"] = love.graphics.newImage("images/player/sword/sword-up.png"),
    -- ["sword-up-charging"] = love.graphics.newImage("images/player/sword/sword-up-charging.png"),
    -- ["sword-up-charged"] = love.graphics.newImage("images/player/sword/sword-up-charged.png"),
    ["sword-down"] = love.graphics.newImage("images/player/sword/sword-down.png")
  }
  local frames = {
    ["idle"]    = anim8.newGrid(32, 32, img["idle"]:getWidth(), img["idle"]:getHeight()),
    ["walking"] = anim8.newGrid(32, 32, img["walking"]:getWidth(), img["walking"]:getHeight()),
    ["jumping"] = anim8.newGrid(32, 32, img["jumping"]:getWidth(), img["jumping"]:getHeight()),
    ["falling"] = anim8.newGrid(32, 32, img["falling"]:getWidth(), img["falling"]:getHeight()),

    ["sword-neutral"] = anim8.newGrid(64, 48, img["sword-neutral"]:getWidth(), img["sword-neutral"]:getHeight()),
    ["sword-neutral-charging"] = anim8.newGrid(64, 48, img["sword-neutral"]:getWidth(), img["sword-neutral"]:getHeight()),
    ["sword-neutral-charged"] = anim8.newGrid(64, 48, img["sword-neutral"]:getWidth(), img["sword-neutral"]:getHeight()),

    ["sword-side"] = anim8.newGrid(64, 48, img["sword-side"]:getWidth(), img["sword-side"]:getHeight()),
    ["sword-side-charging"] = anim8.newGrid(64, 48, img["sword-side"]:getWidth(), img["sword-side"]:getHeight()),
    ["sword-side-charged"] = anim8.newGrid(64, 48, img["sword-side"]:getWidth(), img["sword-side"]:getHeight()),

    ["sword-up"] = anim8.newGrid(64, 48, img["sword-up"]:getWidth(), img["sword-up"]:getHeight()),
    ["sword-up-charging"] = anim8.newGrid(64, 48, img["sword-up"]:getWidth(), img["sword-up"]:getHeight()),
    ["sword-up-charged"] = anim8.newGrid(64, 48, img["sword-up"]:getWidth(), img["sword-up"]:getHeight()),    

    ["sword-down"] = anim8.newGrid(64, 48, img["sword-down"]:getWidth(), img["sword-down"]:getHeight())
  }
  self.anims = {
    ["idle"]    = anim8.newAnimation(img["idle"], frames["idle"]('1-2', 1), {0.6, 0.4}),
    ["walking"] = anim8.newAnimation(img["walking"], frames["walking"]('1-4', 1), 0.14),
    ["jumping"] = anim8.newAnimation(img["jumping"], frames["jumping"]('1-1', 1), 0.1),
    ["falling"] = anim8.newAnimation(img["falling"], frames["falling"]('1-2', 1), {0.15, 0.1}),
    ["ability"] = {
      ["sword-neutral"] = anim8.newAnimation(img["sword-neutral"], frames["sword-neutral"]('1-7', 1), {0.02, 0.02, 0.1, 0.02, 0.02, 0.02, 0.2}, function(anim, loops) signal.emit("player-sword-neutral-ended", anim) end),
      ["sword-neutral-charging"] = anim8.newAnimation(img["sword-neutral"], frames["sword-neutral"]('1-1', 1), 0.1),
      ["sword-side"] = anim8.newAnimation(img["sword-side"], frames["sword-side"]('1-4', 1), {0.03, 0.04, 0.1, 0.2}, function(anim, loops) signal.emit("player-sword-side-ended", anim) end),
      ["sword-side-charging"] = anim8.newAnimation(img["sword-side"], frames["sword-side"]('1-1', 1), 0.1),
      ["sword-up"] = anim8.newAnimation(img["sword-up"], frames["sword-up"]('1-7', 1), {0.02, 0.12, 0.02, 0.02, 0.02, 0.01, 0.2}, function(anim, loops) signal.emit("player-sword-up-ended", anim) end),
      ["sword-up-charging"] = anim8.newAnimation(img["sword-up"], frames["sword-up"]('1-1', 1), 0.1),
      ["sword-down"] = anim8.newAnimation(img["sword-down"], frames["sword-down"]('1-3', 1), {0.03, 0.04, 0.1}, function(anim, loops) signal.emit("player-sword-down-ended", anim) end)
    }
  }

  self.anims["ability"]["sword-neutral-charged"] = self.anims["ability"]["sword-neutral"]
  self.anims["ability"]["sword-side-charged"] = self.anims["ability"]["sword-side"]
  self.anims["ability"]["sword-up-charged"] = self.anims["ability"]["sword-up"]


  -- Abilities
  ------------------------------------
  self.abilities = {
    {
      ["neutral"] = SwordNeutral:new(self, "player-sword-neutral-ended", {
                      ["uncharged"] = self.anims["ability"]["sword-neutral"],
                      ["charging"] = self.anims["ability"]["sword-neutral-charging"],
                      ["charged"] = self.anims["ability"]["sword-neutral-charged"]}),

      ["side"] = SwordSide:new(self, "player-sword-side-ended", {
                  ["uncharged"] = self.anims["ability"]["sword-side"],
                  ["charging"] = self.anims["ability"]["sword-side-charging"],
                  ["charged"] = self.anims["ability"]["sword-side-charged"]}),

      ["up"] = SwordUp:new(self, "player-sword-up-ended", {
                ["uncharged"] = self.anims["ability"]["sword-up"],
                ["charging"] = self.anims["ability"]["sword-up-charging"],
                ["charged"] = self.anims["ability"]["sword-up-charged"]}),

      ["down"] = SwordDown:new(self, "player-sword-down-ended", {
                  ["uncharged"] = self.anims["ability"]["sword-down"]})
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
      self:applyForce(0, -10000)
      self.jumpTime = self.jumpTime - dt * 1000
    end
  end


  -- Horizontal Movement
  ------------------------------------

  -- Walk Right
  if love.keyboard.isDown("right") then
    self.direction = "right"
    if self.grounded then
      if self.state ~= "walking" then self.stateChanged = true end
      self.state = "walking"
    end

    if self.grounded then
      if self.vx < self.speed then self:setVelocityX(self.vx + self.speed * dt) end
    else
      if self.vx < self.airSpeed then self:setVelocityX(self.vx + self.airSpeed * dt) end
    end

  -- Walk Left
  elseif love.keyboard.isDown("left") then
    self.direction = "left"
    if self.grounded then
      if self.state ~= "walking" then self.stateChanged = true end
      self.state = "walking"
    end
   
    if self.grounded then
      if self.vx > -self.speed then self:setVelocityX(self.vx - self.speed * dt) end
    else
      if self.vx > -self.airSpeed then self:setVelocityX(self.vx - self.airSpeed * dt) end
    end

  -- Idle
  elseif self.grounded then
    if self.state ~= "idle" then self.stateChanged = true end
    self.state = "idle"
  end

  -- Jumping & Falling
  if not self.grounded and self.state ~= "ability" then
    if self.vy < 4 then
      self.state = "jumping"
    else
      self.state = "falling"
    end
  end
end


-- Keypress/Keyrelease Callbacks
------------------------------------
function Player:jump()
  if self.canJump then
    self:setVelocityY(0)
    self:applyForce(0, -12000)
    self.grounded = false
    self.jumpReleased = false
    self.canJump = false
  end
end

function Player:releaseJump()
  self.jumpReleased = true
  if self.grounded then self.canJump = true end
end

function Player:executeAbility(slot, direction)
  if self.state ~= "ability" then
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
-- OTHER METHODS
------------------------------------
function Player:launch(power, angle)
  self:takeDamage(power)
  self:hitstun(power * (self.currentDamage / 100 + 1))
  self:knockback(power * 1600, angle)
end



------------------------------------
-- UPDATE
------------------------------------
function Player:update (dt)

  -- Reset ability
  if self.abilityEnded then
    self.state = "idle"
    self.currentAbility:reset()
    self.currentAbility = nil
    self.abilityEnded = false
  end

  -- Hitstun
  if self.hitstunned then
    self:updateHitstun(dt)

  -- Movement
  elseif self.state ~= "ability" or (self.state == "ability" and self.currentAbility.canMove) then
    self:move(dt)
  end


  -- Update Physics
  ------------------------------------
  self:updatePhysics(dt)
  self.grounded = false
  self:handleCollisions()

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
  debug.update(debugger.damage, self.currentDamage)
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
          self:setVelocityY(0)
          self.jumpTime = self.maxJumpTime
        elseif col.normal.x == 0 and col.normal.y == 1 then
          self:setVelocityY(self.vy * self.restitution)
        elseif col.normal.x ~= 0 and col.normal.y == 0 then
          self:setVelocityX(self.vx * self.restitution)
        end
      end

      -- Enemy Collisions
      if col.other:typeOf("Enemy") then
        if col.normal.x == 0 and col.normal.y == -1 then
          self:setVelocityY(0)
          self:applyForce(0, -40000)
          col.other:knockback(0, 14000, true)
        end
      end
    end
  end
end



------------------------------------
-- DRAW
------------------------------------
function Player:draw ()
  local sx, sy, ox, oy = 2, 2, 0, 0
  local drawOffset = {
    x = -16,
    y = -16
  }

  self.currentAnim.flippedH = self.direction == "left"

  if self.state == "ability" then
    if self.currentAbility == self.abilities[1]["up"] then oy = 16 end
    ox = 16
  end

  if self.hitstunned then love.graphics.setColor(255, 0, 0)
  else love.graphics.setColor(255, 255, 255) end
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

