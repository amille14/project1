Movable = class("Movable")

function Movable:__init(x, y)
  local parent = GameObject(x, y)
  print(serialize.block(parent))
  self = Entity()
  self:setParent(parent)
  self:add(Velocity(0, 0))
  print(serialize.block(self:getComponents()))
end