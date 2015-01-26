Position = class("Position")

function Position:__init(x, y)
  self.x = x
  self.y = y
  self.xPrev = x
  self.yPrev = y
end

function Position:set(x, y)
  local dx = x - self.x
  local dy = y - self.y
  self.x = x
  self.y = y
  self.xPrev = self.xPrev + dx
  self.yPrev = self.yPrev + dy
end

function Position:setX(x)
  local dx = x - self.x
  self.x = x
  self.xPrev = self.xPrev + dx
end

function Position:setY(y)
  local dy = y - self.y
  self.y = y
  self.yPrev = self.yPrev + dy
end