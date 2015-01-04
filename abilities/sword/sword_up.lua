------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordUp = class("SwordUp", Ability)
function SwordUp:initialize(user, endSignal, anims)
  Ability.initialize(self, user, endSignal, anims)

  self.basePower = 10
  self.chargePower = 10

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
      if self.user.direction == "right" then collider.x = self.user.x + self.user.w - 16
      else collider.x = self.user.x - collider.w + 16 end
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
      if self.user.direction == "right" then collider.x = self.user.x - collider.w + 16
      else collider.x = self.user.x + self.user.w - 16 end
    
    -- Frame 6
    elseif self.currentAnim.position == 6 then
      collider.w = 48
      collider.h = 32
      collider.y = self.user.y + 16
      if self.user.direction == "right" then collider.x = self.user.x - collider.w + 16
      else collider.x = self.user.x + self.user.w - 16 end

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
          if     self.currentAnim.position == 3 then col.other:launch(self:power(), 90 - 30 * dir[self.user.direction])
          elseif self.currentAnim.position == 4 then col.other:launch(self:power(), 90)
          elseif self.currentAnim.position == 5 then col.other:launch(self:power(), 90 + 30 * dir[self.user.direction])
          elseif self.currentAnim.position == 6 then col.other:launch(self:power(), 90 - 45 * dir[self.user.direction]) end
        end
      end
    end
  end
end