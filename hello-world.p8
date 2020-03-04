pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- Hello, World
-- by blair christensen.

s = "Hello, World!"
x = 64 - #s * 2
y = 61
draw_count = 0

function _init()
  -- nothing (yet)
end

function _update()
  -- nothing (yet)
end

function _draw()
  x = move(x, 0, 127 - #s)
  y = move(y, 0, 127)
  cls()

  print(s, x, y, rnd(16))

  if draw_count == 0 then
    extcmd "rec" -- start video
  end
  if draw_count == 150 then -- ~5 seconds
    extcmd "screen"         -- save screenshot
    extcmd "video"          -- save video
    extcmd "pause"
  end

  draw_count += 1
end

function move(start, min, max)
  d = flr(rnd(3)) - 1 -- -1, 0, or 1

  if      start - d < min then
    return min
  elseif  start + d > max then
    return max
  end

  return start + d
end

