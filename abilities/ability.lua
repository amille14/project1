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
  self.chargeTime = 0
  self.maxChargeTime = 1000 -- in milliseconds

  signal.register(endSignal, function(anim)
    anim:pauseAtEnd()
    self.state = "ended"
    signal.emit("player-ability-ended")
  end)
end



------------------------------------
-- UPDATE
------------------------------------
function Ability:update(dt)
  if self.state == "charging" then
    self.chargeTime = self.chargeTime + dt * 1000
    if self.chargeTime >= self.maxChargeTime then self:release() end
  end

  self.currentAnim:update(dt)
end



------------------------------------
-- OTHER METHODS
------------------------------------
function Ability:execute()
  self.state = "charging"
  self.currentAnim = self.anims["charging"]
end

function Ability:release()
  if self.state == "charging" and self.chargeTime > 100 then
    self.currentAnim = self.anims["charged"]
    self.state = "charged" 
  else
    self.currentAnim = self.anims["uncharged"]
    self.state = "uncharged"
  end
end

function Ability:reset()
  self.state = "idle"
  self.chargeTime = 0
  self.currentAnim = "charging"
  for k,v in pairs(self.anims) do
    v:gotoFrame(1)
    v:resume()
  end
  for k,v in pairs(self.colliders) do
    v:remove()
  end
end