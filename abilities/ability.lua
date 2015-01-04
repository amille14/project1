------------------------------------
-- INITIALIZE ABILITY
------------------------------------
Ability = class("Ability")
function Ability:initialize(user, endSignal, anims)
  self.user = user
  self.anims = anims
  self.currentAnim = self.anims["charging"]
  self.colliders = {}

  self.state = "idle"
  self.animationEnded = false
  self.chargeTime = 0
  self.maxChargeTime = 1000 -- in milliseconds
  self.canMove = false
  self.chargable = true
  self.basePower = 1
  self.chargePower = 0

  signal.register(endSignal, function(anim)
    anim:pauseAtEnd()
    self.animationEnded = true
  end)
end



------------------------------------
-- UPDATE
------------------------------------
function Ability:update(dt)
  if self.chargable and self.state == "charging" then
    self.chargeTime = self.chargeTime + dt * 1000
    if self.chargeTime >= self.maxChargeTime then self:release() end
  end

  -- NOTE: The user's update method is responsible for updating the ability's animation.
end



------------------------------------
-- OTHER METHODS
------------------------------------
function Ability:execute()
  if self.chargable then 
    self.state = "charging"
    self.currentAnim = self.anims["charging"]
  else self:release() end
end

function Ability:release()
  if self.chargable and self.state == "charging" and self.chargeTime > 100 then
    self.currentAnim = self.anims["charged"]
    self.state = "charged" 
  else
    self.currentAnim = self.anims["uncharged"]
    self.state = "uncharged"
  end
end

function Ability:finish()
  signal.emit("player-ability-ended")
end

function Ability:reset()
  self.state = "idle"
  self.chargeTime = 0
  self.currentAnim = "charging"
  self.animationEnded = false
  for k,v in pairs(self.anims) do
    v:gotoFrame(1)
    v:resume()
  end
  for k,v in pairs(self.colliders) do
    v:remove()
  end
end

function Ability:power()
  local power = self.basePower
  if self.chargable and self.state == "charged" then power = self.chargeTime / 1000 * self.chargePower + self.basePower end
  return power
end