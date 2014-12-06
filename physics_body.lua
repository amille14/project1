require "util/class"

physicsBody = createClass()

function PhysicsBody:new(o, w, h, x, y, mass, friction, airDrag, gravity, restitution, grounded)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

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

  -- Other imporant values
  self.mass = mass or 1
  self.friction = friction or 0
  self.airDrag = airDrag or 0
  self.gravity = gravity or 9.81
  self.restitution = restitution or 0  -- "Bounciness", should be a number between 0 and -1
  self.grounded = grounded or true

  return o
end

function PhysicsBody:updatePhysics(dt)
  local fx, fy = 0, 0

  -- Weight force
  fy = self.mass * self.gravity

  -- Friction force
  if grounded then
    if fx > 0 then
      fx = fx - self.friction * self.mass
    else
      fx = fx + self.friction * self.mass
    end

  -- Air drag force
  else
    if fx > 0 then
      fx = fx - 0.5 * self.airDrag * self.h * self.vx * self.vx
    else
      fx = fx + 0.5 * self.airDrag * self.h * self.vx * self.vx
    end

    if fy > 0 then
      fy = fy - 0.5 * self.airDrag * self.w * self.vy * self.vy
    else
      fy = fy + 0.5 * self.airDrag * self.w * self.vy * self.vy
    end
  end

  -- Position and velocity along the X axis
  local px = self.vx * dt + (0.5 * self.ax * dt * dt)
  self.x = self.x + px * 32  -- 1 meter = 32 pixels
  local axNew = fx / self.mass
  local axAvg = 0.5 * (axNew + self.ax)
  self.vx = self.vx + axAvg * dt

  -- Position and velocity along the Y axis
  local py = self.vy * dt + (0.5 * self.ay * dt * dt)
  self.y = self.y + py * 32  -- 1 meter = 32 pixels
  local ayNew = fy / self.mass
  local ayAvg = 0.5 * (ayNew + self.ay)
  self.vy = self.vy + ayAvg * dt
    
end