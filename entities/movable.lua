Movable = class("Movable", GameObject)

function Movable:__init(x, y)
  print(serialize.block(self))
end