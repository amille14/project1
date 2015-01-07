------------------------------------
-- INITIALIZE BAT
------------------------------------
Bat = class("Bat", Enemy)
Bat:include(Health)
Bat:include(Hitstun)
function Bat:initialize(x, y)
  Enemy.initialize(self, x, y, 32, 32, 20, 0.4, 140, 9.81 * 8, -0.5)

  self.state = "flying"
  self.currentDamage = 999

  -- Spritesheets & Animations
  -----------------------------------------------
  local img = {
    ["flying"] = love.graphics.newImage("images/bat/flying.png")
  }
  local frames = {
    ["flying"] = anim8.newGrid(48, 48, img["flying"]:getWidth(), img["flying"]:getHeight())
  }
  self.animations = {
    ["flying"] = anim8.newAnimation(img["flying"], frames["flying"]('1-4', 1), {0.1, 0.08, 0.06, 0.08})
  }
end

function Bat:typeOf(type)
  return type == "Bat" or Enemy.typeOf(self, type)
end



------------------------------------
-- COLLISIONS
------------------------------------
local collisionFilter = function(other)
  if other:typeOf("Player") or other:typeOf("Block") then
    return "slide"
  end
end

function Bat:handleCollisions()
  local x, y, cols, len = world:move(self, self.x, self.y, collisionFilter)
  self.x, self.y = x, y

  if len > 0 then
    for i, col in ipairs(cols) do

      -- Block Collision
      if col.other:typeOf("Block") then
        if col.normal.y == -1 then
          if self.hitstunned then
            self.vy = self.vy * self.restitution
          else
            self.grounded = true
            self.vy = 0
          end
        elseif col.normal.y == 1 then
          self.vy = self.vy * self.restitution
        elseif col.normal.x ~= 0 then
          self.vx = self.vx * self.restitution
        end

      -- Player Collision
      elseif col.other:typeOf("Player") and not col.other.hitstunned then
        local power = 20
        col.other:hitstun(power * 10 * (col.other.currentDamage / 100 + 1))
        col.other:takeDamage(power / 2)
        if col.normal.y ~= 1 then col.other:knockback(power, 90 - 60 * dir[self.direction]) end
      end
    end
  end
end



------------------------------------
-- UPDATE
------------------------------------
function Bat:update(dt)
  -- Movement (Follow Player)
  -- if not self.hitstunned and distance(self.x, self.y, player.x, player.y) < 300 then
  --   if self.x > player.x then self.direction = "left"
  --   else self.direction = "right" end
  --   if self.y > player.y then self:applyImpulse(dir[self.direction] * 0.3, -0.3)
  --   else self:applyImpulse(dir[self.direction] * 0.3, 0.3) end
  -- end

  Enemy.update(self, dt)
end



------------------------------------
-- DRAW
------------------------------------
function Bat:draw()
  local sx, sy, ox, oy = 2, 2, 0, 0
  local drawOffset = {
    ["left"] = {
      x = -28,
      y = -32
    },
    ["right"] = {
      x = -32,
      y = -32
    }
  }

  self.currentAnim.flippedH = self.direction == "right"

  if self.hitstunned then
    love.graphics.setColor(255, 0, 0)
  else
    love.graphics.setColor(255, 255, 255)
  end
  self.currentAnim:draw(self.x + drawOffset[self.direction].x, self.y + drawOffset[self.direction].y, 0, sx, sy, ox, oy)
  self:drawHearts()

  -- Draw Debugging
  ------------------------------------
  if debug.__debugMode then
    self:drawOutline()

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("line", self.x, self.y, 300)
  end
end