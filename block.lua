Block = class("Block")
Block:include(Corners)

function Block:initialize(world, w, h, x, y)
  self.w = w
  self.h = h
  self.x = x
  self.y = y

  self.r = math.floor(love.math.random(255))
  self.g = math.floor(love.math.random(255))
  self.b = math.floor(love.math.random(255))

  -- Add object to bump world
  world:add(self, self.x, self.y, self.w, self.h)
end

function Block:update(dt)
end

function Block:draw()
  love.graphics.setColor(self.r, self.g, self.b)
  love.graphics.polygon("fill", self:topLeft().x, self:topLeft().y, self:topRight().x, self:topRight().y, self:bottomRight().x, self:bottomRight().y, self:bottomLeft().x, self:bottomLeft().y)
end

function Block:type()
  return "Block"
end

function Block:typeOf(t)
  return t == "Block"
end