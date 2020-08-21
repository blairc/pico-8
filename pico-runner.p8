pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico-runner
-- by blair

-- todo update everything to use https://www.lexaloffle.com/bbs/?pid=27696#p for collision detection!

-- todo drop/fall vs move
-- todo speed up over time
-- todo harder enemies over time
-- todo increase enemy freq over time
-- todo save high score + enemies defeated to cart

in_progress = 0
gave_over = 1

is_collision = sqrt(128) -- todo is this right, or at least good enough?
defeated_by = nil

left=0 right=1 up=2 down=3
valid_moves = {left,right,up,down}


function _init()
  state = in_progress
  speed = 0
  score = 0 -- TODO rename
  defeated = 0 -- TODO rename
  
  player = {}
  player.sprite = 1
  player.x = flr(rnd(120))
  player.y = flr(rnd(114)+8)
  player.speed = 1
  
  enemies = {}
  enemy_id = 0 -- FIXME FUCK
end

function _draw()
	-- cls()
	
	if state == in_progress then	
	  cls()
	    
		generate_enemies()
	
		spr(player.sprite, player.x, player.y)
		for enemy in all(enemies) do
			spr(enemy.sprite, enemy.x, enemy.y)
		end
	
	  print('time: ' .. flr(score), 0, 0, 6 )
	  print('defeated: ' .. defeated, 0, 8, 6 )
	  -- print('player: x=' .. player.x .. ',y=' .. player.y, 0, 16, 6)
	  print('enemies: ' .. #enemies, 0, 112, 6 )
	  print('speed: ' .. speed, 0, 120, 6)
	  
	  speed += 0.0001
	elseif state == game_over then
    print("\135 game over \135", 0, 16, 6)
    print("your final score was: " .. flr(score), 0, 24, 6)
    print("player coordinates: x=" .. player.x .. ", y=" .. player.y, 0, 80, 6)
    print("enemy coordinates:  x=" .. defeated_by.x .. ", y=" .. defeated_by.y, 0, 88, 6)
    print("distance: " .. distance(player, defeated_by), 0, 96, 6)
    print("abs.x=" .. abs(player.x - defeated_by.x) .. ', abs.y=' .. abs(player.y - defeated_by.y), 0, 104, 6)

    print("press x to try again")
    if btn(5) then 
      _init() 
    end
	end
end

function _update()
	if state == in_progress then
    move_player()
    move_enemies()
    check_game_over()
    score += 1/30 -- TODO not happy about this
 end
end

-- TODO DRY between check_for_collisions + check_game_over + distance
function check_for_collisions(object)
  if not object.enemy_id then
    return false
  end
  for enemy in all(enemies) do
    if distance(object, enemy) <= is_collision and object.enemy_id != enemy.enemy_id then
      return true
    end
  end
  return false
end

function check_game_over()
	for enemy in all(enemies) do
	-- if abs(x1-x2)<8 and abs(y1-y2)<8 then POW
	  -- https://www.lexaloffle.com/bbs/?pid=27696#p
    if abs(player.x - enemy.x) < 8 and abs(player.y - enemy.y) < 8 then
		-- if distance(player, enemy) <= is_collision then
			state = game_over
			defeated_by = enemy
			break
		end
	end
end

function distance(p0, p1)
	dx = p0.x - p1.x
	dy = p0.y - p1.y
	return sqrt(dx*dx + dy*dy)
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

-- TODO additional enemies & enemies
function generate_enemies()
  enemy = nil
  -- TODO r = flr(rnd(100))
	if flr(rnd(100)) == 0 then
	  enemy = generate_enemy_rock()
	elseif flr(rnd(200)) == 0 then
	  enemy = generate_enemy_red()
  end
  -- ensure no collisions
  if enemy then
    for other in all(enemies) do
  	  if distance(enemy, other) < is_collision then
  		  return
  	  end
    end
    enemy.id = enemy_id -- uuid (effectively)
		add(enemies, enemy)
		enemy_id += 1
	end
end

function move_enemies()
	for enemy in all(enemies) do
	  if enemy.movable then
	    move_towards_player(enemy)
	  end
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

-- TODO should player speed up or just enemies?
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
        defeated += 1
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
