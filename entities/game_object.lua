GameObject = class("GameObject", Entity)

function GameObject:__init(x, y)
  self = Entity()
  self:add(Position(x, y))
end