------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordSide = class("SwordNeutral", Ability)
function SwordSide:initialize(user, endSignal, anims)
  Ability.initialize(self, user, endSignal, anims)

  self.basePower = 10 
  self.chargePower = 10

  self.colliders = {
    Collider:new("Ability", user.x + user.w - 16, user.y + 16, 58, 32)
  }
end



------------------------------------
-- OTHER METHODS
------------------------------------
function SwordSide:release()
  if self.state == "charging" then
    Ability.release(self)
    self.user:setVelocityX(0)
    local force = 30000
    -- if not self.user.grounded then force = force * (1 / self.user.mass) * 16 end
    self.user:applyForce(dir[self.user.direction] * force, 0)
  end
end



------------------------------------
-- UPDATE
------------------------------------
function SwordSide:update(dt)
  Ability.update(self, dt)

  local collider = self.colliders[1]
  if self.state == "charged" or self.state == "uncharged" then
    if self.currentAnim.position == 2 then
      collider:add()
    elseif self.currentAnim.position == 4 then
      collider:remove()
    end
  end

  if self.user.direction == "right" then collider.x = self.user.x + self.user.w - 16
  else collider.x = self.user.x - collider.w + 16 end
  collider.y = self.user.y + 16
  collider:update(dt)
  self:handleCollisions()
  
  if self.animationEnded then self:finish() end
end



------------------------------------
-- COLLISIONS
------------------------------------
local collisionFilter = function(other)
  if other:typeOf("Enemy") then
    return "cross"
  end
end

function SwordSide:handleCollisions()
  local collider = self.colliders[1]
  if world:hasItem(collider) then
    local x, y, cols, len = world:check(collider, collider.x, collider.y, collisionFilter)
    collider.x = x
    collider.y = y

    if len > 0 then
      for i, col in ipairs(cols) do

        -- Enemy Collisions
        if col.other:typeOf("Enemy") and not collider.collidedWith[col.other] then
          collider.collidedWith[col.other] = true
          self.user:setVelocityX(0)
          col.other:launch(self:power(), 90 - 90 * dir[self.user.direction])
        end
      end
    end
  end
end