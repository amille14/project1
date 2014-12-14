require "physics_body"

Bat = class("Bat", PhysicsBody)

function Bat:initialize(world, x, y)
  PhysicsBody.initialize(self, x, y, 32, 32, 10, 0.4, 4.5, 0, 0)

  self.state = "flying"
  self.direction = "right"

  -- Add body to bump world
  world:add(self, self.x, self.y, self.w, self.h)

  -- Load spritesheets & create animations
  self.images = {
    ["flying"] = love.graphics.newImage("images/bat/flying.png")
  }
  self.frames = {
    ["flying"] = anim8.newGrid(48, 48, self.images["flying"]:getWidth(), self.images["flying"]:getHeight())
  }
  self.animations = {
    ["flying"] = anim8.newAnimation(self.frames["flying"]('1-4', 1), {0.1, 0.08, 0.06, 0.08})
  }
end

function Bat:typeOf(type)
  return type == "Enemy" or type == "Bat"
end

local collisionFilter = function(other)
  if other:typeOf("Player") then
    return "slide"
  elseif other:typeOf("Block") then
    return "slide"
  end
end

function Bat:handleCollisions()
  local x, y, cols, len = world:move(self, self.x, self.y, function(other) return "slide" end)
  self.x, self.y = x, y

  if len > 0 then
    for i, col in ipairs(cols) do
      if col.other:typeOf("Block") then
        if col.normal.y ~= 0 then
          self.vy = -self.vy * self.restitution
        elseif col.normal.x ~= 0 then
          self.vx = -self.vx * self.restitution
        end
      end
    end
  end
end

function Bat:update(dt)
  -- Follow Player
  if distance(self.x, self.y, player.x, player.y) < 200 then
    if self.x > player.x then self:applyImpulse(-0.3, 0)
    else self:applyImpulse(0.3, 0) end

    if self.y > player.y then self:applyImpulse(0, -0.3)
    else self:applyImpulse(0, 0.3) end
  end

  -- Update physics
  self:updatePhysics(dt)

  -- Set direction
  if self.vx > 0 then
    self.direction = "right"
  else
    self.direction = "left"
  end

  -- Collision detection
  self:handleCollisions()

  -- Update animation
  self.currentAnim = self.animations[self.state]
  self.currentAnim:update(dt)
end

function Bat:draw()
  local sx, sy, ox, oy = 2, 2, 0, 0
  local drawOffset = {
    ["left"] = {
      x = -28,
      y = -32
    },
    ["right"] = {
      x = -32,
      y = -32
    }
  }

  if self.direction == "right" then
    self.currentAnim.flippedH = true
  elseif self.direction == "left" then
    self.currentAnim.flippedH = false
  end

  love.graphics.setColor(255, 255, 255)
  self.currentAnim:draw(self.images[self.state], self.x + drawOffset[self.direction].x, self.y + drawOffset[self.direction].y, 0, sx, sy, ox, oy)
  
  -- Debugging
  -- self:drawOutline()

  -- love.graphics.setColor(255, 0, 0)
  -- love.graphics.circle("line", self.x, self.y, 200)
end