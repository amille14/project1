class = require "util/middleclass"
bump = require "util/bump"

Block = class("Block")

function Block:initialize(world, w, h, x, y)
  self.w = w
  self.h = h
  self.x = x
  self.y = y

  self.isGround = true

  self.r = math.floor(math.random(255))
  self.g = math.floor(math.random(255))
  self.b = math.floor(math.random(255))

  -- Add object to bump world
  world:add(self, self.x, self.y, self.w, self.h)
end

function Block:update(dt)
end

function Block:draw()
  love.graphics.setColor(self.r, self.g, self.b)
  love.graphics.polygon("fill", self.x, self.y, self.x + self.w, self.y, self.x + self.w, self.y + self.h, self.x, self.y + self.h)
end