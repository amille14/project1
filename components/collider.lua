Collider = class("Collider")

function Collider:__init(x, y, w, h, updateFunction)
  self.x = x
  self.y = y
  self.w = w
  self.h = h

  self.updateFunction = updateFunction or function(dt) end
  self.collidedWith = {}
end

function Collider:add()
  if not world:hasItem(self) then world:add(self, self.x, self.y, self.w, self.h) end
end

function Collider:remove()
  if world:hasItem(self) then world:remove(self) end
  self.collidedWith = {}
end


-- Corners
------------------------------------
function Collider:topLeft()
  return {x = self.x, y = self.y}
end

function Collider:topRight()
  return {x = self.x + self.w, y = self.y}
end

function Collider:bottomLeft()
  return {x = self.x, y = self.y + self.h}
end

function Collider:bottomRight()
  return {x = self.x + self.w, y = self.y + self.h}
end