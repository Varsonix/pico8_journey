pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- todo
-- -explosions
-- -hit reactions

function _init()
	cls(0)
	-- create stars for start
	generate_stars()
	game = {mode="start"}
	blink_timer = 0
	t = 0
end

function _update()
	blink_timer += 1
	if game.mode == "game" then
		update_game()
	elseif game.mode == "start" then
		update_start()
	elseif game.mode == "over" then
		update_over()
	end
end

function _draw()
	if game.mode == "game" then
		draw_game()
	elseif game.mode == "start" then
		draw_start()
	elseif game.mode == "over" then
		draw_over()
	end
end

function animate_thrusters()
	ship.boostspr += 1
	if ship.boostspr > 8 then
		ship.boostspr = 4
	end
end

function start_game()
	cls(1)
	-- ship object (player)
	ship = {}
	ship.spr=2
	ship.x=60
	ship.y=100
	ship.muzzle=0
	ship.spdx=0
	ship.spdy=0
	ship.boostspr = 4

	timer = 0
	-- bullets holding bay
	bullets = {}
	
	-- enemies holding bay
	enemies = {}
	
	spawn_enemy()
	
	t=0
		
	-- general game variables
	game = {
		mode = "game",
		score = flr(rnd(128)),
		lives = 4,
		invuln = 0,
		bombs = 3
	}
end
-->8
-- tools

function generate_stars()
	stars = {}
	for i=1,100 do
		local new_star = {}
		new_star.x = flr(rnd(128))
		new_star.y = flr(rnd(128))
		new_star.spd = rnd(1.5) + 0.5
		add(stars, new_star)
	end
end

function star_field()
	for i=1,#stars do
		local my_star = stars[i]
		local star_color = 6
		
		if my_star.spd < 1 then
			star_color = 1
		elseif my_star.spd < 1.5 then
			star_color = 13
		end
		
		pset(my_star.x, my_star.y, star_color)
	end
end

function animate_stars()
	for i=1,#stars do
		local my_star = stars[i]
		my_star.y += my_star.spd
		if my_star.y > 128 then
			my_star.y -= 128
			my_star.x = flr(rnd(128))
		end
	end
end

--[[
there's got to be a better way.
this feels like a super
awkward way to handle a pulsate
]]--
function blink()
	local blink_ani = {
		5,5,5,5,5,5,5,6,6,
		7,7,6,6,5,5
	}
	if blink_timer > #blink_ani then 
		blink_timer = 1
	end
	
	return blink_ani[blink_timer]
end


function collision(a, b)
	-- lots of math
	-- a = enemy / b = ship
	-- practice vars
	local a_left = a.x
	local a_top = a.y
	local a_right = a.x + 7
	local a_bottom = a.y + 7
	
	local b_left = b.x
	local b_top = b.y
	local b_right = b.x + 7
	local b_bottom = b.y + 7
	
	if a_top > b_bottom then return false end
	if b_top > a_bottom then return false end
	if a_left > b_right then return false end
	if b_left > a_right then return false end
	
	return true
end

-- other method (will factor in)
--function rect_rect_collision( r1, r2 )
--  return r1.x < r2.x+r2.w and
--         r1.x+r1.w > r2.x and
--         r1.y < r2.y+r2.h and
--         r1.y+r1.h > r2.y
--end

function spawn_enemy()
	local	enemy = {}
	enemy.x = flr(rnd(120))
	enemy.y = -8
	enemy.spr = 20
	
	add(enemies, enemy)
end
-->8
-- update functions

-- primary game loop
function update_game()
	t += 1
	-- stop when not pressing
	ship.spdx = 0
	ship.spdy = 0
	ship.sp = 2
	
	-- movements
	if btn(➡️) then	
		ship.spdx = 2
		ship.sp = 3
	end
	if btn(⬅️) then	
		ship.spdx = -2	
		ship.sp = 1
	end
	if btn(⬆️) then
		ship.spdy = -2	
	end
	if btn(⬇️) then
		ship.spdy = 2
	end
	
	-- shooting
	if btn(❎) then
		
		if timer <= 0 then
			local new_bullet = {}
			new_bullet.x = ship.x
			new_bullet.y = ship.y
			new_bullet.spd = ship.spd
			new_bullet.spr = 16
			add(bullets, new_bullet)	
			sfx(0)
			ship.muzzle = 5
			timer = 4
		end
	end
	timer -= 1
	
	-- move ship
	-- todo: remember to fix
	-- sprite issue with left/right
	ship.x += ship.spdx
	ship.y += ship.spdy
	
	-- move bullets
 update_bullets(bullets)

	-- move enemies
	update_enemies(enemies)	
	
	-- bullet x enemy collision
	-- check prior to ship x enemy
	for enemy in all(enemies) do
		for bullet in all(bullets) do
			if collision(enemy, bullet) then
				del(enemies, enemy)
				del(bullets, bullet)
				sfx(2)
				spawn_enemy()
				game.score +=1
			end
		end
	end
	
	-- ship x enemy collision
	-- new invuln logic added*
	game.invuln -= 1
	if game.invuln <= 0 then
		for enemy in all(enemies) do
			if collision(enemy, ship) then
				game.lives -= 1
				sfx(1)
				game.invuln = 60
				--del(enemies, enemy)
			end
		end
	else
		game.invuln -= 1
	end
	
	-- animate thruster
	animate_thrusters()
	
	-- animate muzzle flash
	if ship.muzzle > 0 then
		ship.muzzle -= 2
	end
	
	-- clamping for edges (advanced)
	ship.posx = mid(0, ship.posx, 120)
	ship.posy = mid(0, ship.posy, 120)

	-- animate stars
	animate_stars()
	if game.lives <= 0 then
		game.mode = "over"
	end
end

function update_start()
	if btnp(❎) then 
		start_game() 
	end
	animate_stars()
end

function update_over()
	if btnp(❎) then
		game.mode = "start"
	end
end

--[[
project:

i don't think it's possible
but i'd like to see if i can
figure out a way to make a
generic enough function for
updating the movement of an
object as well...

i may need to trim fat
in order to do so though.
we'll see... 

my goal is to be able to just
have the one function

update_objects(ship)
update_objects(bullets)
update_objects(enemies)

that might be asking too much.
but chew on it for a bit.
--]]

function update_bullets(object)
	for bullet in all(object) do
		bullet.y -= 4
		
		if bullet.y < -10 then
			del(object, bullet)
		end
	end
end

function update_enemies(object)
	for my_enemy in all(object) do
		my_enemy.y += 1
		my_enemy.spr += 0.4
		-- animate logic 
		if my_enemy.spr > 24 then
			my_enemy.spr = 20
		end
		-- memory logic
		if my_enemy.y > 128 then
			del(object, my_enemy)
			spawn_enemy()
		end
	end
end


-->8
-- draw functions

-- primary game draw loop
function draw_game()
	cls(0)
	star_field() --generate stars
	
	-- handle blinking invuln
	if game.invuln <= 0 then
		draw_ship(ship)
	else
		-- during invuln
		if sin(t/5) < 0.1 then
			draw_ship(ship) 
		end
	end
	
	
	
	draw_objects(bullets) -- bullets
	draw_objects(enemies) -- enemies
	
	muzzle_flash(ship) -- muzzle logic
	
	-- draw score
	print("score: "..game.score, 40, 3, 12)
	
	-- draw lives for loop
	for i=1,game.lives do
		if game.lives >= i then
			spr(14,i*9-8,2)
		else
			spr(13,i*9-8,2)
		end
	end
	
	-- draw bombs
	for i=1,game.bombs do
		spr(29,127-i*9, 2)
	end
	
end

function draw_start()
	cls(1)
	star_field() --generate stars
	print("star shooter", 40, 50, 12)
	print("press ❎ to start", 30, 80, blink())
end

function draw_over()
	cls(0)
	star_field() --generate stars
	print("game over", 45, 50, 8)
	print("press ❎ to restart", 27, 80, blink())
end

--[[ current project:

think about how to make
this more generic.
i shouldn't need a function
primarily to draw the ship.
i'm only doing this because
argument modulation is required
on the spr() call to handle the
booster.

maybe an additional argument
for modulation? like 
draw_sprite(booster, 8)
draw_sprite(ship, 0) ???

todo: think this through.
use your brain. for once, please.
--]]

function draw_ship(ship)
	spr(ship.spr, ship.x, ship.y)
	spr(ship.boostspr, ship.x, ship.y + 8)
end

function draw_sprite(object)
	spr(object.spr, object.x, object.y)
end

function draw_objects(object)
	for item in all(object) do
		draw_sprite(item)
	end
end

-- trying to make generic
function muzzle_flash(object)
	if object.muzzle > 0 then
		circfill(object.x + 3,object.y-2,object.muzzle+1,7)
		circfill(object.x + 4,object.y-2,object.muzzle+1,7)
	end
end
__gfx__
00000000000550000005500000055000000000000000000000000000000000000000000000000000000000000000000000000000088008800880088000000000
0000000000599500005995000059950000077000000770000007700000c77c000007700000000000000000000000000000000000800880088888888800000000
0070070000599500005995000059950000c77c000007700000c77c000cccccc000c77c0000000000000000000000000000000000800000088888888800000000
0007700005999a5005a99a5005a9995000cccc00000cc00000cccc0000cccc0000cccc0000000000000000000000000000000000800000088888888800000000
00077000057c99505a97c9a505997c50000cc000000cc000000cc00000000000000cc00000000000000000000000000000000000080000800888888000000000
0070070005119950599119950599115000000000000cc00000000000000000000000000000000000000000000000000000000000008008000088880000000000
00000000052295500592295005592250000000000000000000000000000000000000000000000000000000000000000000000000000880000008800000000000
00000000005885000058850000588500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000033003300330033003300330033003300000000000000000000000000000000000000000000550000000000000000000
0099990000000000000000000000000033b33b3333b33b3333b33b3333b33b330000000000000000000000000000000000000000005dd5000000000000000000
09aaaa900000000000000000000000003bbbbbb33bbbbbb33bbbbbb33bbbbbb3000000000000000000000000000000000000000005d66d500000000000000000
09a77a900000000000000000000000003b7717b33b7717b33b7717b33b7717b300000000000000000000000000000000000000005d66d6d50000000000000000
09a77a900000000000000000000000000b7117b00b7117b00b7117b00b7117b000000000000000000000000000000000000000005d66d6d50000000000000000
09aaaa900000000000000000000000000037730000377300003773000037730000000000000000000000000000000000000000005d66d6d50000000000000000
009999000000000000000000000000000303303003033030030330300303303000000000000000000000000000000000000000005d66d6d50000000000000000
0000000000000000000000000000000003000030300000030300003003300330000000000000000000000000000000000000000000aaaa000000000000000000
08088080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03033030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333bb333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00300300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000305502c54027530225201d510195101751019700147000c7000b7001700014000100000e0000b00007000050000000000000000000000000000000000000000000000000000000000000000000000000
00010000256102b6102f6102d6102961024610216101e6101b6101a61018610146100f6100c6100961006610066101d6001d6001c6001c6001d6001e6001f6002060020600226002360027600296002c6002e600
00010000387300962032530226300f620085200862007620056100461001610006200040000400006000062000400016000040000630004000260000400006300060000400006201b60000400004000360000400
