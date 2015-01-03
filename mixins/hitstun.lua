Hitstun = {}

function Hitstun:resetHitstun(maxHitstunTime)
  self.hitstunned = false
  self.hitstunTime = 0
  self.hitstunLength = 500
  self.maxHitstunTime = maxHitstunTime or 1000 -- in milliseconds
end

function Hitstun:hitstun(length)
  self.hitstunned = true
  self.hitstunLength = length
  signal.emit("character-hitstunned", self, length)
end

function Hitstun:updateHitstun(dt)
  self.hitstunTime = self.hitstunTime + dt * 1000
  if self.hitstunTime >= self.hitstunLength then self:resetHitstun(self.maxHitstunTime) end
end