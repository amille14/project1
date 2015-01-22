------------------------------------
-- INITIALIZE ENEMY
------------------------------------
Enemy = class("Enemy", PhysicsBody)
Enemy:include(Health)
Enemy:include(Hitstun)
function Enemy:initialize(x, y, w, h, mass, friction, speed, gravity, restitution)
  PhysicsBody.initialize(self, x, y, w, h, mass, friction, speed, gravity, restitution)
  world:add(self, self.x, self.y, self.w, self.h)
  self:initializeHealth()
  self:initializeHitstun()

  self.state = "idle"
  self.direction = "right"
end

function Enemy:typeOf(type)
  return type == "Enemy"
end



------------------------------------
-- OTHER METHODS
------------------------------------
function Enemy:launch(power, angle)
  self:takeDamage(power)
  self:hitstun(power * (self.currentDamage / 100 + 1))
  self:knockback(power, angle)
end



------------------------------------
-- UPDATE
------------------------------------
function Enemy:update(dt)


  -- Update Hitstun
  ------------------------------------
  if self.hitstunned then self:updateHitstun(dt) end


  -- Update Physics
  ------------------------------------
  self:updatePhysics(dt)
  self.grounded = false
  self:handleCollisions()


  -- Update Animation
  ------------------------------------
  self.currentAnim = self.animations[self.state]
  self.currentAnim:update(dt)
end