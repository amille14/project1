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
  -- self.airDrag = 5
  self.speed = speed or 100
  self.airSpeed = self.speed * (1 / self.mass) * 8
  -- self.maxSpeed = self.speed / 6
  self.maxAirSpeed = self.airSpeed
  self.gravity = gravity or 9.81 * 8
  self.restitution = restitution or -1  -- "Bounciness", should be a number between 0 and -1


  local p = 3 --1.293       -- air density
  local C = 1.5             -- drag coefficient
  local A = (w/64) * (h/64) -- area
  self.airDrag = 0.5 * p * C * A
  print(self.airDrag)
end



------------------------------------
-- UPDATE
------------------------------------
function PhysicsBody:updatePhysics(dt)

  -- Friction force
  if self.grounded then
    -- if self.vx > self.maxSpeed then self.vx = self.maxSpeed end
    -- if self.vx < -self.maxSpeed then self.vx = -self.maxSpeed end
    self.vx = self.vx * (1 - math.min(self.friction * self.mass * dt, 1))
  end

  -- Air drag force
  -- else
    local Rx = self.airDrag * self.vx * self.vx
    local Ry = self.airDrag * self.vy * self.vy

    if self:typeOf("Player") then
      print("Rx: "..(Rx/self.mass)*dt)
      print("Ry: "..(Ry/self.mass)*dt)
      print("---------")
    end

    -- self.vx = self.vx + (Rx / self.mass)*dt
    -- self.vy = self.vy + (Ry / self.mass)*dt

    self.vx = self.vx * (1 - math.min((Rx/self.mass)*dt, 1))
    self.vy = self.vy * (1 - math.min((Ry/self.mass)*dt, 1))

    -- if self.vx > 0 then self.vx = self.vx - (Rx * dt) / self.mass
    -- else self.vx = self.vx + (Rx * dt) / self.mass end
    -- if self.vy > 0 then self.vy = self.vy - (Ry * dt) / self.mass
    -- else self.vy = self.vy + (Ry * dt) / self.mass end

    -- self.vx = self.vx - (Rx * dt) / self.mass
    -- self.vy = self.vy + (Ry * dt) / self.mass

    -- if self.vx >  self.maxAirSpeed then self.vx =  self.maxAirSpeed end
    -- if self.vx < -self.maxAirSpeed then self.vx = -self.maxAirSpeed end
    -- if self.vy >  self.maxAirSpeed then self.vy =  self.maxAirSpeed end
    -- if self.vy < -self.maxAirSpeed then self.vy = -self.maxAirSpeed end
    -- self.vx = self.vx * (1 - math.min(self.airDrag * dt, 1))
    -- self.vy = self.vy * (1 - math.min(self.airDrag * dt, 1))
  -- end

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

function PhysicsBody:knockback(power, angle, ignoreDamage)
  local multiplier = 40.0 / self.mass
  if not ignoreDamage then multiplier = multiplier * ((self.currentDamage / 100.0) + 1) end
  local fx = power * math.cos(math.rad(angle)) * multiplier
  local fy = -power * math.sin(math.rad(angle)) * multiplier
  if self:typeOf("Enemy") then
    print("Power: "..power)
    print("Multi: "..multiplier)
    print(fx, fy)
    print("---------------")
  end
  self:applyImpulse(fx, fy)
end
