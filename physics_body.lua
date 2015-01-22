------------------------------------
-- INITIALIZE PHYSICS BODY
------------------------------------
PhysicsBody = class("PhysicsBody")
PhysicsBody:include(Corners)
function PhysicsBody:initialize(x, y, w, h, mass, friction, frictionAir, gravity, restitution)
  self.w = w
  self.h = h
  self.x = x or 0
  self.y = y or 0
  self.vx = 0
  self.vy = 0
  self.xPrev = self.x
  self.yPrev = self.y

  self.mass = mass or 1
  self.inverseMass = 1 / mass
  self.friction = friction or 0.1
  self.frictionAir = frictionAir or 0.01
  -- self.speed = speed or 100
  -- self.airSpeed = self.speed * (1 / self.mass) * 4
  self.gravity = gravity or 50
  self.gravityForce = self.gravity * self.mass
  self.restitution = restitution or -0.5  -- "Bounciness", should be a number between 0 and -1
  self.fx = 0
  self.fy = self.gravityForce
  -- local p = 1.293                      -- air density
  -- local C = airDragCoefficient or 24   -- drag coefficient
  -- local A = (w/64) * (h/64)            -- area
  -- self.airDrag = 0.5 * p * C * A
end



------------------------------------
-- UPDATE
------------------------------------
function PhysicsBody:updatePhysics(dt)
  local dtSquared = dt * dt
  local friction = 1
  if self.grounded then friction = 1 - self.friction end
  local frictionAir = 1 - self.frictionAir
  local vxPrev = self.x - self.xPrev
  local vyPrev = self.y - self.yPrev

  self.vx = (vxPrev * frictionAir * friction) + (self.fx / self.mass) * dtSquared * 64
  self.vy = (vyPrev * frictionAir) + (self.fy / self.mass) * dtSquared * 64
  self.xPrev = self.x
  self.yPrev = self.y
  self.x = self.x + self.vx
  self.y = self.y + self.vy
  self.fx = 0
  self.fy = self.gravityForce

  -- -- Gravity force
  -- self.vy = self.vy + self.gravity * dt

  -- -- Friction force
  -- if self.grounded then
  --   self.vx = self.vx * (1 - math.min(self.friction * self.mass * dt, 1))
  -- end

  -- -- Air drag force
  -- local Rx = self.airDrag * self.vx * self.vx
  -- local Ry = self.airDrag * self.vy * self.vy
  -- local rvx = (Rx/self.mass) * dt   -- Change in x velocity as a result of air drag force
  -- local rvy = (Ry/self.mass) * dt   -- Change in y velocity as a result of air drag force

  -- if rvx > math.abs(self.vx) * 0.4 then rvx = math.abs(self.vx) * 0.4 end
  -- local s = sign(self.vx)
  -- if s ~= 0 then
  --   self.vx = self.vx - (s * rvx)
  --   if sign(self.vx) ~= s then self.vx = 0 end
  -- end

  -- if rvy > math.abs(self.vy) * 0.4 then rvy = math.abs(self.vy) * 0.4 end
  -- local s = sign(self.vy)
  -- if s ~= 0 then
  --   self.vy = self.vy - (s * rvy)
  --   if sign(self.vy) ~= s then self.vy = 0 end
  -- end

  -- -- X Position
  -- local px = self.vx * dt
  -- self.x = self.x + px * 64  -- because 1 meter = 64 pixels
  -- if math.abs(self.vx) < 0.001 then self.vx = 0 end

  -- -- Y Position & Velocity
  -- local py = self.vy * dt + (0.5 * self.gravity * dt * dt)
  -- self.y = self.y + py * 64  -- because 1 meter = 64 pixels
  -- if math.abs(self.vy) < 0.001 then self.vy = 0 end
end



------------------------------------
-- OTHER METHODS
------------------------------------
function PhysicsBody:setPosition(x, y)
  local dx = x - self.x
  local dy = y - self.y

  self.x = x
  self.y = y
  self.xPrev = self.xPrev + dx
  self.yPrev = self.yPrev + dy
end

function PhysicsBody:setVelocity(vx, vy)
  self.xPrev = self.x - vx
  self.yPrev = self.y - vy
  self.vx = vx
  self.vy = vy
end

function PhysicsBody:setVelocityX(vx)
  self.xPrev = self.x - vx
  self.vx = vx
end

function PhysicsBody:setVelocityY(vy)
  self.yPrev = self.y - vy
  self.vy = vy
end

function PhysicsBody:applyForce(fx, fy)
  self.fx = self.fx + fx
  self.fy = self.fy + fy
end

function PhysicsBody:applyImpulse(vx, vy)
  self:setVelocity(self.vx + vx, self.vy + vy)
end

function PhysicsBody:knockback(force, angle, ignoreDamage)
  local multiplier = 1
  if not ignoreDamage then multiplier = (self.currentDamage / 100.0 * 0.4) + 1 end
  local fx = round(force * math.cos(math.rad(angle)) * multiplier, 8)
  local fy = round(-force * math.sin(math.rad(angle)) * multiplier, 8)
  self:applyForce(fx, fy)
end



-- function PhysicsBody:applyImpulse(ix, iy)
--   self.vx = self.vx + ix
--   self.vy = self.vy + iy
-- end

-- function PhysicsBody:knockback(power, angle, ignoreDamage)
--   local multiplier = 20.0 / self.mass
--   if not ignoreDamage then multiplier = multiplier * ((self.currentDamage / 100.0 * 0.4) + 1) end
--   local fx = round(power * math.cos(math.rad(angle)) * multiplier, 8)
--   local fy = round(-power * math.sin(math.rad(angle)) * multiplier, 8)
--   if self:typeOf("Enemy") then
--     print("Power: "..power)
--     print("Multi: "..multiplier)
--     print(fx, fy)
--     print("---------------")
--   end
--   self:applyImpulse(fx, fy)
-- end
