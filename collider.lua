Collider = class("Collider")
Collider:include(Corners)

function Collider:initialize(name, x, y, w, h, type, update)
  self.name = name
  self.x = x
  self.y = y
  self.w = w
  self.h = h

  self.update = update or function(dt) end
end

function Collider:update(dt)
  self.update(dt)
end

function Collider:typeOf(type)
  return type == "Collider" or type == self.type
end

function Collider:add()
  world:add(self, self.x, self.y, self.w, self.h)
end

function Collider:remove()
  world:remove(self)
end