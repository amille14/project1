require "physics_body"

Bat = class("Bat", PhysicsBody)

function Bat:initialize(world, x, y)
  PhysicsBody.initialize(self, 32, 32, x, y, 10, 0.4, 4.5, 0, 0)

  self.state = "flying"
  self.direction = "left"

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

function Bat:typeOf()
  return "Enemy"
end

function Bat:handleCollisions()
end

function Bat:update(dt)
  -- Follow Player
  -- flux.to(self, 0.5, {x = player.x, y = player.y}):ease("linear")

  if distance(self.x, self.y, player.x, player.y) < 200 then
    if self.x > player.x then self:applyImpulse(-0.5, 0)
    else self:applyImpulse(0.5, 0) end

    if self.y > player.y then self:applyImpulse(0, -0.5)
    else self:applyImpulse(0, 0.5) end
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
  local sx, sy, ox, oy = 1, 1, 0, 0
  local drawOffset = {
    x = -8,
    y = -8
  }

  if self.direction == "right" then
    self.currentAnim.flippedH = true
  elseif self.direction == "left" then
    self.currentAnim.flippedH = false
  end

  love.graphics.setColor(255, 255, 255)
  self.currentAnim:draw(self.images[self.state], self.x + drawOffset.x, self.y + drawOffset.y, 0, sx, sy, ox, oy)
  -- self:drawOutline()

  love.graphics.setColor(255, 0, 0)
  love.graphics.circle("line", self.x, self.y, 200)
end