------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordNeutral = class("SwordNeutral", Ability)
function SwordNeutral:initialize(user, endSignal, anims)
  Ability.initialize(self, user, endSignal, anims)

  self.colliders = {
    Collider:new("Ability", user.x + user.w - 16, user.y + 8, 52, user.h)
  }
end



------------------------------------
-- UPDATE
------------------------------------
function SwordNeutral:update(dt)
  local collider = self.colliders[1]

  if self.state == "charged" or self.state == "uncharged" then
    if self.currentAnim.position == 2 then
      collider:add()
    elseif self.currentAnim.position == 6 then
      collider:remove()
    end
  end

  if self.user.direction == "right" then
    collider.x = self.user.x + self.user.w - 16
  else
    collider.x = self.user.x - collider.w + 16
  end
  collider.y = self.user.y + 8
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

function SwordNeutral:handleCollisions()
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
          self.user.vx = 0
          local power = 18
          if self.state == "charged" then power = self.chargeTime / 1000 * 16 + power end
          if     self.user.direction == "right" then col.other:knockback(self.user, power, -power/4)
          elseif self.user.direction == "left" then col.other:knockback(self.user, -power, -power/4) end
        end
      end
    end
  end
end