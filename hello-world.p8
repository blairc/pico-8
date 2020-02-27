pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- Hello, World
-- by blair christensen.

function _init()
  has_screenshot = false
end

function _draw()
  cls()

  s = "Hello, World!"
  x = 64 - #s * 2
  y = 61
  print(s, x, y)

  if not has_screenshot then
    extcmd "screen" -- or F6
    has_screenshot = true
  end
end

