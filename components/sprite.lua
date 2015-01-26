Sprite = class("Sprite")

function Sprite:__init(img, sx, sy, ox, oy)
  self.img = love.graphics.newImage(img)
  self.w = self.img:getWidth()
  self.h = self.img:getHeight()
  self.sx = sx
  self.sy = sy
  self.ox = ox
  self.oy = oy
end