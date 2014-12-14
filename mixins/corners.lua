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

function Corners:drawOutline(r, g, b)
  love.graphics.setColor(r or 61, g or 243, b or 77)
  love.graphics.polygon("line", self:topLeft().x, self:topLeft().y, self:topRight().x, self:topRight().y, self:bottomRight().x, self:bottomRight().y, self:bottomLeft().x, self:bottomLeft().y)
end

function drawOutline(body)
  love.graphics.setColor(255, 0, 0)
  love.graphics.polygon("line", body.x, body.y, body.x + body.w, body.y, body.x + body.w, body.y + body.h, body.x, body.y + body.h)
end