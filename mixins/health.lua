Health = {}

function Health:resetHealth(hearts, currentDamage, currentHeart)
  self.heartCount = hearts or 1
  self.currentHeart = 0
  self.currentDamage = currentDamage or 0
  self.vulnerable = false
end

function Health:takeDamage(dmg)
  self.currentDamage = self.currentDamage + dmg
  if self.currentDamage >= 100 then self.vulnerable = true
  else self.vulnerable = false end
  if self.currentDamage > 999 then self.currentDamage = 999 end
  signal.emit("character-damaged", self, dmg)
end

function Health:healDamage(dmg)
  self.currentDamage = self.currentDamage - dmg
  if self.currentDamage < 100 then self.vulnerable = false
  else self.vulnerable = true end
  if self.currentDamage < 0 then self.currentDamage = 0 end
  signal.emit("character-healed", self, dmg)
end

function Health:healHearts(hearts)
  self.heartCount = self.heartCount + hearts
  signal.emit("character-hearts-restored", self, hearts)
end

function Health:drawHearts()
  love.graphics.print(math.floor(self.currentDamage).."%", self.x, self.y - 16)
end