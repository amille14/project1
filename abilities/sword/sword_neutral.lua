------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordNeutral = class("SwordNeutral", Ability)
function SwordNeutral:initialize(user, endSignal, anims)
  Ability.initialize(self, user, endSignal, animation)

  self.colliders = {
    Collider:new("Ability", user.x + user.w, user.y + 8, 40, user.h)
  }
end



------------------------------------
-- UPDATE
------------------------------------
function  SwordNeutral:update(dt)
  local collider = self.colliders[0]

  if self.state == "charged" or self.state == "uncharged" then
    if self.currentAnim[self.state].position == 3 then
      collider:add()
    elseif self.currentAnim[self.state].position == 5 then
      collider:remove()
    end
  end

  if user.direction == "right" then
    collider.x = user.x + user.w
  else
    collider.x = user.x - this.w
  end
  collider.y = user.y + 8
  collider:update(dt)
  self:handleCollisions()
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
  local collider = self.colliders[0]

    local x, y, cols, len = world:check(collider, collider.x, collider.y, collisionFilter)
    collider.x = x
    collider.y = y

    if len > 0 then
      for i, col in ipairs(cols) do

        -- Enemy Collisions
        if col.other:typeOf("Enemy") and not collider.collidedWith[col.other] then
          collider.collidedWith[col.other] = true
          user.vx = 0
          local power = self.chargeTime / 1000 * 16 + 12
          if     user.direction == "right" then col.other:knockback(user, power, -power/4)
          elseif user.direction == "left" then col.other:knockback(user, -power, -power/4) end
        end
      end
    end 
  end
end