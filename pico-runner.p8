pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico-runner
-- by blair

-- todo save high score + enemies defeated to cart
-- todo remove moving up as an option from moving towards player
-- todo harder enemies over time
-- todo invisible enemies?
-- todo increase enemy freq over time

in_progress = 0
gave_over = 1
restart = 2

collided_with = nil

left=0 right=1 up=2 down=3
valid_moves = {left,right,up,down}


function _init()
  state = in_progress
  speed = 0
  time_played = 0
  enemies_defeated = 0
  score = 0

  player = {}
  player.id = 'player'
  player.sprite = 1
  player.x = flr(rnd(120))
  player.y = flr(rnd(114)+8)
  player.speed = 1

  enemies = {}
  enemy_id = 0 -- FIXME FUCK
end

function _draw()
	if state == in_progress then
	  cls()

		generate_enemies()

		spr(player.sprite, player.x, player.y)
		for enemy in all(enemies) do
			spr(enemy.sprite, enemy.x, enemy.y)
		end

	  print('score: ' .. score, 0, 0, 6 )
	  print(' time: ' .. flr(time_played), 0, 8, 6 )
	  print(' defeated: ' .. enemies_defeated, 0, 16, 6 )
	  -- print('enemies: ' .. #enemies, 0, 112, 6 )
	  print('speed: ' .. speed .. ', enemies: ' .. #enemies, 0, 120, 6)

	  speed += 0.0002 -- TODO ???
	elseif state == game_over then
    print("\135 game over \135", 0, 54, 6)
    print("your final score was: " .. score, 0, 60, 6)
    -- print("player coordinates: x=" .. player.x .. ", y=" .. player.y, 0, 96, 6)
    -- print("enemy coordinates:  x=" .. collided_with.x .. ", y=" .. collided_with.y, 0, 104, 6)

    print("press x to try again", 0, 66, 6)
    if btn(5) then
      state = restart
    end
  elseif state == restart then
    _init()
	end
end

function _update()
	if state == in_progress then
    move_player()
    move_enemies()
    score = flr(time_played) + enemies_defeated
    check_game_over()
    time_played += 1/30 -- TODO not happy about this
 end
end

-- https://www.lexaloffle.com/bbs/?pid=27696#p
function check_for_collisions(object)
  for enemy in all(enemies) do
    if abs(object.x - enemy.x) < 8 and abs(object.y - enemy.y) < 8 and object.id != enemy.id then
      collided_with = enemy
      return true
    end
  end
  return false
end

function check_game_over()
  if check_for_collisions(player) then
		state = game_over
	end
end

-- TODO additional enemies & enemies
function generate_enemies()
  enemy = nil

  -- TODO more/better enemies
  -- TODO use score in rnd calculation?
  -- TODO faster enemies
  -- TODO enemies that can appear anywhere?

  if score > 25 then
	  if flr(rnd(200)) == 0 then
	    enemy = generate_enemy_red()
    end
  end

	if not enemy and flr(rnd(100)) == 0 then
	  enemy = generate_enemy_rock()
	end

  -- ensure new enemy doens't collide with anything else
  if enemy and not check_for_collisions(enemy) then
    enemy.id = enemy_id -- uuid (effectively)
		add(enemies, enemy)
		enemy_id += 1 -- :scream_cat:
	end
end

function generate_enemy_rock()
  enemy = {}
  enemy.name = 'rock'
  enemy.sprite = 2
  enemy.x = flr(rnd(120))
  enemy.y = 0
  enemy.speed = 0
  return enemy
end

function generate_enemy_red()
  enemy = {}
  enemy.name = 'red'
  enemy.sprite = 3
  enemy.x = flr(rnd(120))
  enemy.y = 0
  enemy.speed = 1/2 -- 50% of speed
  enemy.movable = true
  return enemy
end

function move_enemies()
	for enemy in all(enemies) do
	  -- move if movable
	  if enemy.movable then
	    move_towards_player(enemy)
	  end
	  -- then drop
		move_unit(enemy, down, speed)
	end
end

function move_towards_player(enemy)
  if enemy.x > player.x then
    move_unit(enemy, left, speed * enemy.speed)
  end
  if enemy.x < player.x then
    move_unit(enemy, right, speed * enemy.speed)
  end
  if enemy.y > player.y then
    move_unit(enemy, up, speed * enemy.speed)
  end
  if enemy.y < player.y then
    move_unit(enemy, down, speed * enemy.speed)
  end
end

function move_player()
 for i=1,#valid_moves do
  if btn(valid_moves[i]) then
   move_unit(player, valid_moves[i], player.speed)
  end
 end
end

function move_unit(unit, direction, speed)
  if direction == left then
    unit.x -= speed
    if check_for_collisions(unit) then
      unit.x += speed
    end
    if unit.x <= 0 then
      unit.x = 0
    end
  end
  if direction == right then
    unit.x += speed
    if check_for_collisions(unit) then
      unit.x -= speed
    end
    if unit.x >= 120 then
      unit.x = 120
    end
  end
  if direction == up then
    unit.y -= speed
    if check_for_collisions(unit) then
      unit.y += speed
    end
    if unit.y <= 0 then
      unit.y = 0
    end
  end
  if direction == down then
    unit.y += speed
    if check_for_collisions(unit) then
      unit.y -= speed
    end
    if unit.y >= 120 then
      if unit == player then
        unit.y = 120 -- stop player
      else
        del(enemies, unit) -- delete enemy
        enemies_defeated += 1
      end
    end
  end
end

__gfx__
00000000077777700444444008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777774444444488888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777774444444488888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777774444444488888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777774444444488888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777774444444488888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777774444444488888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700444444008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
