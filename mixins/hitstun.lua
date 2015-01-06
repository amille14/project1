Hitstun = {}

function Hitstun:initializeHitstun()
  self.hitstunned = false
  self.hitstunTime = 0
  self.hitstunLength = 0
  self.maxHitstunTime = 2000 -- in milliseconds
  self.normalSpeed = self.speed
  self.hitstunSpeed = self.speed / 10
end

function Hitstun:resetHitstun()
  self.hitstunned = false
  self.hitstunTime = 0
  self.speed = self.normalSpeed
end

function Hitstun:hitstun(length)
  self.hitstunned = true
  self.hitstunTime = 0
  self.speed = self.hitstunSpeed
  if length < self.maxHitstunTime then self.hitstunLength = length
  else self.hitstunLength = self.maxHitstunTime end
  signal.emit("character-hitstunned", self, self.hitstunLength)
end

function Hitstun:updateHitstun(dt)
  self.hitstunTime = self.hitstunTime + dt * 1000
  if self.hitstunTime >= self.hitstunLength then self:resetHitstun() end
end