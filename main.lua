-- Libraries
require("lib/require")
require.tree("lib/lovetoys")
serialize = require "serialize"
flux      = require "flux"
camera    = require "lib/hump/camera"
anim8     = require "lib/anim8"
bump      = require "bump"
debug     = require "donut"

-- Utility
require "utility"

-- Game ECS
require.tree("entities")
require.tree("components")
require.tree("systems")
require.tree("events")

-- Enum
dir = {["left"] = -1, ["right"] = 1}

function love.load()
  debug    = Donut.init(5, 5)
  debugger = {fps = debug.add("FPS")}

  love.math.setRandomSeed(os.time())
  love.graphics.setBackgroundColor(81, 113, 155)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setNewFont(16)

  EM     = EventManager()
  engine = Engine()
  world  = bump.newWorld(64)

  movable = Movable(30, 60)
end

function love.update(dt)
  engine:update(dt)
  debug.update(debugger.fps, love.timer.getFPS())
end

function love.draw()
  engine:draw()
  debug.draw()
end

function love.keypressed(key, isrepeat)
  EM:fireEvent(KeyPressed(key, isrepeat))
end

function love.keyreleased(key)
  EM:fireEvent(KeyReleased(key))
end