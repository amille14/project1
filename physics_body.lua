PhysicsBody = class("PhysicsBody")
PhysicsBody:include(Corners)

function PhysicsBody:initialize(w, h, x, y, mass, friction, airDrag, gravity, restitution)
  -- Width & height
  self.w = w
  self.h = h

  -- Position, velocity & acceleration
  self.x = x or 0
  self.y = y or 0
  self.vx = 0
  self.vy = 0
  self.ax = 0
  self.ay = 0

  -- Other values
  self.mass = mass or 1
  self.friction = friction or 0
  self.airDrag = airDrag or 0
  self.gravity = gravity or 9.81 * 32
  self.restitution = restitution or 0  -- "Bounciness", should be a number between 0 and -1
  self.grounded = false
end

function PhysicsBody:updatePhysics(dt)
  local fx, fy = 0, 0

  -- Weight force
  fy = self.mass * self.gravity

  -- Friction force
  if self.grounded then
    self.vx = self.vx * (1 - math.min(self.friction * self.mass * dt, 1))

  -- Air drag force
  else
    self.vx = self.vx * (1 - math.min(self.airDrag * self.mass * dt, 1))
    self.vy = self.vy * (1 - math.min(self.airDrag * self.mass * dt, 1))
  end

  -- Calculate position, velocity, and acceleration along the X axis
  local px = self.vx * dt + (0.5 * self.ax * dt * dt)
  self.x = self.x + px * 64  -- 1 meter = 64 pixels
  local axNew = fx / self.mass
  local axAvg = 0.5 * (axNew + self.ax)
  self.vx = self.vx + axAvg * dt
  self.ax = axAvg
  if math.abs(self.ax) < 0.001 then self.ax = 0 end

  -- Calculate position, velocity, and acceleration along the Y axis
  local py = self.vy * dt + (0.5 * self.ay * dt * dt)
  self.y = self.y + py * 64  -- 1 meter = 64 pixels
  local ayNew = fy / self.mass
  local ayAvg = 0.5 * (ayNew + self.ay)
  self.vy = self.vy + ayAvg * dt
  self.ay = ayAvg
  if math.abs(self.ay) < 0.001 then self.ax = 0 end
end


-- Apply forces
-------------------------------------
function PhysicsBody:applyForce(fx, fy)
  self.ax = self.ax + fx / self.mass
  self.ay = self.ay + fy / self.mass
end

function PhysicsBody:applyImpulse(ix, iy)
  self.vx = self.vx + ix
  self.vy = self.vy + iy
end