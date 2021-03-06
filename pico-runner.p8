pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico-runner
-- by blair

-- TODO simplify enemy generation?
-- TODO simplify enemy movement?
-- TODO more/better enemies?
-- TODO limit number of enemies?

cartdata("pico_runner")
cartdata_hi_score = 0
cartdata_hi_time = 1
cartdata_hi_defeated = 2

function get_or_initialize_cartdata(cartdata_index)
  v = dget(cartdata_index)
  if nil == v then
    v = 0
    dset(cartdata_index, v)
  end
  return v
end
hi_score = get_or_initialize_cartdata(cartdata_hi_score)
hi_time = get_or_initialize_cartdata(cartdata_hi_time)
hi_defeated = get_or_initialize_cartdata(cartdata_hi_defeated)

in_progress = 0
gave_over = 1
restart = 2

collided_with = nil
enemy_generated_last_turn = false

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
  enemy_id = 0 -- TODO a hack-ish uuid alternative
end

function _draw()
	if state == in_progress then
	  cls()

    generate_enemies()

		spr(player.sprite, player.x, player.y)
		for enemy in all(enemies) do
      if "blue" == enemy.name and flr(time_played) % 2 == 0 then
        spr(enemy.sprite + 1, enemy.x, enemy.y) -- invsible!
      else
        spr(enemy.sprite, enemy.x, enemy.y)
      end
		end

	  print('score: ' .. score .. ' (' .. hi_score .. ')', 0, 0, 6 )
	  print(' time: ' .. flr(time_played) .. ' (' .. hi_time .. ')', 0, 8, 6 )
	  print(' defeated: ' .. enemies_defeated .. ' (' .. hi_defeated .. ')', 0, 16, 6 )
	  print('speed: ' .. speed .. ', enemies: ' .. #enemies, 0, 120, 6)

	  speed += 0.0002 -- slowly speed things up
	elseif state == game_over then
    print("\135 game over \135", 0, 56, 6)
    print("your final score was: " .. score, 0, 64, 6)
    last_y = 64
    if score > hi_score then
      hi_score = score
      dset(cartdata_hi_score, hi_score)
      last_y += 8
      print("\135 new high score: " .. hi_score .. " \135", 0, 72, 6)
    end
    if time_played > hi_time then
      hi_time = flr(time_played)
      dset(cartdata_hi_time, hi_time)
      last_y += 8
      print("\135 new high time: " .. hi_time .. " \135", 0, 80, 6)
    end
    if enemies_defeated > hi_defeated then
      hi_defeated = enemies_defeated
      dset(cartdata_hi_defeated, hi_defeated)
      last_y += 8
      print("\135 new high defeated: " .. hi_defeated .. " \135", 0, 88, 6)
    end

    print("press x to try again", 0, 100, 6)
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
  if enemy_generated_last_turn then
    enemy_generated_last_turn = false
    return enemy
  end

  -- ugly but it works (enough)
  if     ( flr(rnd(3200)) - score ) == 0 then
    enemy = generate_enemy_blue()
  elseif ( flr(rnd(1600)) - score ) == 0 then
    enemy = generate_enemy_green()
  elseif ( flr(rnd(800)) - score ) == 0 then
    enemy = generate_enemy_yellow()
  elseif ( flr(rnd(400)) - score ) == 0 then
    enemy = generate_enemy_orange()
  elseif ( flr(rnd(200)) - score ) == 0 then
    enemy = generate_enemy_red()
  elseif ( flr(rnd(100)) - score ) == 0 then
    enemy = generate_enemy_rock()
  end

  -- ensure new enemy doesn't collide with anything else
  if enemy and not check_for_collisions(enemy) then
    enemy.id = enemy_id -- uuid (effectively)
		add(enemies, enemy)
		enemy_id += 1 -- :scream_cat:
    enemy_generated_last_turn = true
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

function generate_enemy_orange()
  enemy = {}
  enemy.name = 'orange'
  enemy.sprite = 4
  enemy.x = flr(rnd(120))
  enemy.y = 0
  enemy.speed = 1 -- 100% of speed
  enemy.movable = true
  return enemy
end

function generate_enemy_yellow()
  enemy = {}
  enemy.name = 'yellow'
  enemy.sprite = 5
  enemy.x = flr(rnd(120))
  enemy.y = 0
  enemy.speed = 6/4 -- 150% of speed
  enemy.movable = true
  return enemy
end

function generate_enemy_green()
  enemy = {}
  enemy.name = 'green'
  enemy.sprite = 6
  enemy.x = flr(rnd(120))
  enemy.y = flr(rnd(60)) -- can appear anywhere in upper half of screen
  enemy.speed = 6/4 -- 150% of speed
  enemy.movable = true
  return enemy
end

function generate_enemy_blue()
  enemy = {}
  enemy.name = 'blue'
  enemy.sprite = 7
  enemy.x = flr(rnd(120))
  enemy.y = flr(rnd(90)) -- can appear almost anywhere
  enemy.speed = 6/4 -- 150% of speed
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
  -- don't allow moving up
  if enemy.x > player.x then
    move_unit(enemy, left, speed * enemy.speed)
  end
  if enemy.x < player.x then
    move_unit(enemy, right, speed * enemy.speed)
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
00000000077777700444444008888880099999900aaaaaa00bbbbbb00cccccc00000000000000000000000000000000000000000000000000000000000000000
0000000077777777444444448888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000077777777444444448888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000077777777444444448888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000077777777444444448888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000077777777444444448888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000077777777444444448888888899999999aaaaaaaabbbbbbbbcccccccc0000000000000000000000000000000000000000000000000000000000000000
00000000077777700444444008888880099999900aaaaaa00bbbbbb00cccccc00000000000000000000000000000000000000000000000000000000000000000
