------------------------------------
-- INITIALIZE PHYSICS BODY
------------------------------------
PhysicsBody = class("PhysicsBody")
PhysicsBody:include(Corners)
function PhysicsBody:initialize(x, y, w, h, mass, friction, airDrag, speed, gravity, restitution)
  self.w = w
  self.h = h
  self.x = x or 0
  self.y = y or 0
  self.vx = 0
  self.vy = 0

  self.mass = mass or 1
  self.friction = friction or 0
  self.airDrag = airDrag or 0
  self.speed = speed or 100
  self.airSpeed = self.speed * (1 / self.mass) * 8
  self.gravity = gravity or 9.81 * 8
  self.restitution = restitution or -1  -- "Bounciness", should be a number between 0 and -1
end



------------------------------------
-- UPDATE
------------------------------------
function PhysicsBody:updatePhysics(dt)

  -- Friction force
  if self.grounded then
    self.vx = self.vx * (1 - math.min(self.friction * self.mass * dt, 1))
    if self.vx > self.speed then self.vx = self.speed end
    if self.vx < -self.speed then self.vx = -self.speed end

  -- Air drag force
  else
    self.vx = self.vx * (1 - math.min(self.airDrag * dt, 1))
    self.vy = self.vy * (1 - math.min(self.airDrag * dt, 1))

    if self.vx > self.airSpeed then self.vx = self.airSpeed end
    if self.vx < -self.airSpeed then self.vx = -self.airSpeed end
    if self.vy > self.airSpeed then self.vy = self.airSpeed end
    if self.vy < -self.airSpeed then self.vy = -self.airSpeed end
  end

  -- X Position
  local px = self.vx * dt
  self.x = self.x + px * 64  -- because 1 meter = 64 pixels
  if math.abs(self.vx) < 0.001 then self.vx = 0 end

  -- Y Position & Velocity
  local py = self.vy * dt + (0.5 * self.gravity * dt * dt)
  self.y = self.y + py * 64  -- because 1 meter = 64 pixels
  self.vy = self.vy + self.gravity * dt
  if math.abs(self.vy) < 0.001 then self.vy = 0 end
end



------------------------------------
-- OTHER METHODS
------------------------------------
function PhysicsBody:applyImpulse(ix, iy)
  self.vx = self.vx + ix
  self.vy = self.vy + iy
end

function PhysicsBody:knockback(other, fx, fy)
  local multiplier = (other.mass / self.mass) * -self.restitution
  self:applyImpulse(multiplier * fx, multiplier * fy)
end


-- function PhysicsBody:collideWithBodyX(body, normal)
--   local va = vector(self.vx, self.vy)
--   local vb = vector(body.vx, body.vy)
--   local vrx = va.x - vb.x
--   local nx  = normal.x
--   local i  = (1 + self.restitution) * nx * (vrx * nx) / (1/self.mass + 1/body.mass)
--   va.x = va.x - (i * 1/self.mass)
--   vb.x = vb.x + (i * 1/body.mass)

--   -- self:applyImpulse(va.x, 0)
--   body:applyImpulse(vb.x, 0)

--   return va, vb
-- end


-- function PhysicsBody:collideWithBodyY(body, normal)
--   local va = vector(self.vx, self.vy)
--   local vb = vector(body.vx, body.vy)
--   local vry = va.y - vb.y
--   local ny  = normal.y
--   local i  = (1 + self.restitution) * ny * (vry * ny) / (1/self.mass + 1/body.mass)
--   va.y = va.y - (i * 1/self.mass)
--   vb.y = vb.y + (i * 1/body.mass)

--   -- self:applyImpulse(0, va.y)
--   body:applyImpulse(0, vb.y)

--   return va, vb
-- end

-- function PhysicsBody:collideWithBody(body, normal)
--   local va = vector(self.vx, self.vy)
--   local vb = vector(body.vx, body.vy)
--   local vr = va - vb
--   local n  = vector(normal.x, normal.y)
--   local i  = (1 + self.restitution) * n * (vr * n) / (1/self.mass + 1/body.mass)
--   va = va - (i * 1/self.mass)
--   Vb = vb + (i * 1/body.mass)

--   self:applyImpulse(va.x, va.y)
--   body:applyImpulse(vb.x, vb.y)

--   print("Velocity: ", self.vx, self.vy)
--   print(va.x, va.y)
--   print(vb.x, vb.y)
--   print("-------------------")

--   return va, vb
-- end