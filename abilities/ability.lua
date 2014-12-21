------------------------------------
-- INITIALIZE ABILITY
------------------------------------
Ability = class("Ability")
function Ability:initialize(user, endSignal, anims)
  self.user = user
  self.anims = anims
  self.currentAnim = anims[0]
  self.colliders = {}

  signal.register(endSignal, function(anim)
    anim:pauseAtEnd()
    self.animationEnded = true
  end)
end