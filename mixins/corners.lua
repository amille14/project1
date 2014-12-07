Corners = {}

function Corners:topLeft()
  return {x = self.x, y = self.y}
end

function Corners:topRight()
  return {x = self.x + self.w, y = self.y}
end

function Corners:bottomLeft()
  return {x = self.x, y = self.y + self.h}
end

function Corners:bottomRight()
  return {x = self.x + self.w, y = self.y + self.h}
end

function Corners:drawOutline()
  love.graphics.setColor(61, 243, 77)
  love.graphics.polygon("line", self:topLeft().x, self:topLeft().y, self:topRight().x, self:topRight().y, self:bottomRight().x, self:bottomRight().y, self:bottomLeft().x, self:bottomLeft().y)
end