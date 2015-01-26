KeyPressed = class("KeyPressed")

function KeyPressed:__init(key, isRepeat)
  self.key = key
  self.isRepeat = isRepeat
end