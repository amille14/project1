------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordDown = class("SwordDown", Ability)
function SwordDown:initialize(user, endSignal, anims)
  Ability.initialize(self, user, endSignal, anims)

  self.canMove = true
  self.chargable = false
  self.basePower = 14

  self.colliders = {
    Collider:new("Ability", self.user.x + 4, self.user.y + self.user.h - 16, 24, 36)
  }

  if self.user.grounded then self:finish() end
end



------------------------------------
-- OTHER METHODS
------------------------------------
function SwordDown:execute()
  Ability.execute(self)
  self.user:applyImpulse(0, 10)
end



------------------------------------
-- UPDATE
------------------------------------
function SwordDown:update(dt)
  local collider = self.colliders[1]
  if self.currentAnim.position == 2 then collider:add() end
  collider.x = self.user.x + 4
  collider.y = self.user.y + self.user.h - 16
  collider:update(dt)
  self:handleCollisions()

  if self.user.grounded then self:finish() end
end



------------------------------------
-- COLLISIONS
------------------------------------
local collisionFilter = function(other)
  if other:typeOf("Enemy") then
    return "cross"
  end
end

function SwordDown:handleCollisions()
  local collider = self.colliders[1]
  if world:hasItem(collider) then
    local x, y, cols, len = world:move(collider, collider.x, collider.y, collisionFilter)
    collider.x = x
    collider.y = y

    if len > 0 then
      for i, col in ipairs(cols) do
        if col.normal.x == 0 and col.normal.y == -1 then

          -- Enemy Collisions
          if col.other:typeOf("Enemy") then
            self.user.vy = 0
            self.user:applyImpulse(0, -25)
            col.other:launch(self:power(), 270)
          end
        end
      end
    end  
  end
end