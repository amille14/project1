------------------------------------
-- INITIALIZE ABILITY
------------------------------------
SwordNeutral = class("SwordNeutral", Ability)
function SwordNeutral:initialize(user, anims, signal)
  Ability.initialize(user, animation, signal)
end