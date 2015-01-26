Velocity = class("Velocity")

function Velocity:__init(vx, vy)
  self.vx = vx
  self.vy = vy
end

-- function Velocity:set(vx, vy)
--   self.xPrev = self.x - vx
--   self.yPrev = self.y - vy
--   self.vx = vx
--   self.vy = vy
-- end

-- function Velocity:setX(vx)
--   self.xPrev = self.x - vx
--   self.vx = vx
-- end

-- function Velocity:setY(vy)
--   self.yPrev = self.y - vy
--   self.vy = vy
-- end