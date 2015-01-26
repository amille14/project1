PhysicsBody = class("PhysicsBody")

function PhysicsBody:__init(options)
  self.mass         = options.mass or math.huge -- Infinite mass if undefined
  self.friction     = options.friction or 0.1
  self.frictionAir  = options.frictionAir or 0.01
  self.gravity      = options.gravity or 50
  self.restitution  = options.restitution or -0.5  -- "Bounciness", should be a number between 0 and -1

  self.inverseMass  = 1 / mass
  self.gravityForce = self.gravity * self.mass
  self.fx = 0
  self.fy = self.gravityForce
end

-- function PhysicsBody:applyForce(fx, fy)
--   self.fx = self.fx + fx
--   self.fy = self.fy + fy
-- end

-- -- Knocks back body at a certain angle. Angle is in degrees.
-- function PhysicsBody:knockback(force, angle)
--   local fx = round( force * math.cos(math.rad(angle)), 8)
--   local fy = round(-force * math.sin(math.rad(angle)), 8)
--   self:applyForce(fx, fy)
-- end
