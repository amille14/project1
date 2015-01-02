------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordUp = class("SwordUp", Ability)
function SwordUp:initialize(user, endSignal, anims)
  Ability.initialize(self, user, endSignal, anims)

  self.colliders = {
    Collider:new("Ability", user.x + user.w - 16, user.y - 8, 52, 32)
  }
end



------------------------------------
-- UPDATE
------------------------------------
function SwordUp:update(dt)
  Ability.update(self, dt)

  local collider = self.colliders[1]
  if self.state == "charged" or self.state == "uncharged" then

    -- Frame 3
    if self.currentAnim.position == 3 then
      collider.w = 52
      collider.h = 32
      collider.y = self.user.y - 8
      if self.user.direction == "right" then
        collider.x = self.user.x + self.user.w - 16
      else
        collider.x = self.user.x - collider.w + 16
      end
      collider:add()

    -- Frame 4
    elseif self.currentAnim.position == 4 then
      collider.w = 72 
      collider.h = 64
      collider.y = self.user.y - 48
      collider.x = self.user.x - 16

    -- Frame 5
    elseif self.currentAnim.position == 5 then
      collider.w = 48
      collider.h = self.user.h + 32
      collider.y = self.user.y - 48
      if self.user.direction == "right" then
        collider.x = self.user.x - collider.w + 16
      else
        collider.x = self.user.x + self.user.w - 16
      end
    
    -- Frame 6
    elseif self.currentAnim.position == 6 then
      collider.w = 48
      collider.h = 32
      collider.y = self.user.y + 16
      if self.user.direction == "right" then
        collider.x = self.user.x - collider.w + 16
      else
        collider.x = self.user.x + self.user.w - 16
      end

    -- Frame 7
    elseif self.currentAnim.position == 7 then
      collider:remove()
    end
  end
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

function SwordUp:handleCollisions()
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
          -- self.user.vy = 0
          local power = 18
          if self.state == "charged" then power = self.chargeTime / 1000 * 16 + power end
          local fy = -power
          local fx = 0
          if self.currentAnim.position == 3 then fx = -power/4
          elseif self.currentAnim.position == 4 then fx = 0
          elseif self.currentAnim.position == 5 then fx = power/4
          elseif self.currentAnim.position == 6 then
            fx = -power
            fy = -power/4
          end
          if self.user.direction == "left" then fx = -fx end
          
          col.other:knockback(self.user, fx, fy)
          col.other:takeDamage(power)
        end
      end
    end
  end
end