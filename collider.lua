------------------------------------
-- INITIAILZE COLLIDER
------------------------------------
Collider = class("Collider")
Collider:include(Corners)
function Collider:initialize(name, type, x, y, w, h, update)
  self.name = name
  self.type = type
  self.x = x
  self.y = y
  self.w = w
  self.h = h

  self.updateFunction = update or function(dt) end

  self.collidedWith = {}
end

function Collider:typeOf(type)
  return type == "Collider" or type == self.type
end



------------------------------------
-- UPDATE
------------------------------------
function Collider:update(dt)
  self.updateFunction(dt)
  if world:hasItem(self) then world:update(self, self.x, self.y, self.w, self.h) end
end



------------------------------------
-- ADD & REMOVE
------------------------------------
function Collider:add()
  if not world:hasItem(self) then
    world:add(self, self.x, self.y, self.w, self.h)
  end
end

function Collider:remove()
  if world:hasItem(self) then
    world:remove(self)
  end
  self.collidedWith = {}
end