Animation = class("Animation")

function Animation:__init(img, frame_w, frame_h, frame_cols, frame_rows, durations, onloop, sx, sy, ox, oy)
  self.img    = love.graphics.newImage(img)
  self.frames = anim8.newGrid(frame_w, frame_h, self.img:getWidth(), self.img:getHeight())
  self.anim   = anim8.newAnimation(self.img, self.frames(frame_cols, frame_rows), durations, onloop)
end