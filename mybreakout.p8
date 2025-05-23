pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- initialize variables
function _init()
	cls()
	ball_x=24
	ball_y=55
	ball_dx=1
	ball_dy=1
	ball_r=2
	ball_dr=0.5

	pad_x=52
	pad_y=120
	pad_dx=0
	pad_w=24
	pad_h=3
	pad_c=7
	
	mode="start"
end

function _update60()
	if mode=="game" then	
		update_game()	
	elseif mode=="start" then	
		update_start()
	elseif mode=="gameover" then	
		update_gameover()
	end
end


function update_start()
	if btn(5) then 
		start_game() 
	end
end

function start_game()
	mode="game"
	ball_r=2
	ball_dr=0.5

	-- paddle
	pad_x=52
	pad_y=120
	pad_dx=0
	pad_w=24
	pad_h=3
	pad_c=7
	
	-- bricks
	brick_x=5
	brick_y=20
	brick_w=24
	brick_h=3

	-- hud
	lives=3
	points=0
	serve_ball()
end

function serve_ball()
	ball_x=24
	ball_y=55
	ball_dx=1
	ball_dy=1
end

function game_over()
	mode = "gameover"
end

function update_gameover()
	if btn(5) then 
		start_game() 
	end
end

function update_game()
	local b_press = false
	local nextx, nexty
	
	if btn(0) then
		--left
		pad_dx = -2.5
		b_press = true
		--pad_x -= 5
	end
	if btn(1) then
		--right
		pad_dx = 2.5
		b_press = true
		--pad_x += 5
	end
	
	if not(b_press) then
		pad_dx = pad_dx / 1.35
	end
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)

	nextx = ball_x + ball_dx
	nexty = ball_y + ball_dy
	 
	if nextx > 124 or nextx < 3 then
		nextx = mid(0,nextx,127) --cool method to catch next middle
		ball_dx = -ball_dx
	 sfx(0)
	end
	if nexty < 10 then
		nexty = mid(0,nexty,127)
		ball_dy = -ball_dy
		sfx(0)
	end

	
	-- check if ball hit pad
	if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
		-- deal with collision
		-- find out which direction to deflect
		if deflx_ballbox(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
			ball_dx = -ball_dx
		else
			ball_dy = -ball_dy
		end
		sfx(1)
		points += 1
	end
	
	ball_x = nextx
	ball_y = nexty
		
	if nexty > 127 then
		sfx(2)
		lives -= 1
		if lives < 0 then
			game_over()
		else
			serve_ball()
		end
	end
end

function _draw()
	if mode=="game" then	
		draw_game()	
	elseif mode=="start" then	
		draw_start()
	elseif mode=="gameover" then	
		draw_gameover()
	end
end

function draw_start()
	cls()
	print("pico hero breakout", 30, 30, 7)
	print("press ❎ to start", 32, 80, 11)
end

function draw_gameover()
--	cls()
	rectfill(0,60,128,76,0)
	print("game over",46,62,7)
	print("press ❎ to restart", 26, 68, 6)
end

function draw_game()
	cls(1)
	circfill(ball_x,ball_y,ball_r,10)
 rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)	

	-- draw bricks
	rectfill(brick_x,brick_y,brick_x+brick_w,brick_y+brick_h,1)		

	rectfill(0,0,128,6,0)
	print("lives: "..lives,1,1,9)
	print("score: "..points,40,1,9)
end

function ball_box(bx,by,box_x,box_y,box_w,box_h)
	-- checks for collision of ball with square	
	if by-ball_r > box_y + box_h then return false end
	if by+ball_r < box_y then return false end
 if bx-ball_r > box_x + box_w then	return false	end
	if bx+ball_r < box_x then	return false	end
	return true
end

function deflx_ballbox(bx,by,bdx,bdy,tx,ty,tw,th)
 -- calculate wether to deflect the ball
 -- horizontally or vertically when it hits a box
 if bdx == 0 then
  -- moving vertically
  return false
 elseif bdy == 0 then
  -- moving horizontally
  return true
 else
  -- moving diagonally
  -- calculate slope
  local slp = bdy / bdx
  local cx, cy
  -- check variants
  if slp > 0 and bdx > 0 then
   -- moving down right
   debug1="q1"
   cx = tx-bx
   cy = ty-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return true
   else
    return false
   end
  elseif slp < 0 and bdx > 0 then
   debug1="q2"
   -- moving up right
   cx = tx-bx
   cy = ty+th-by
   if cx<=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  elseif slp > 0 and bdx < 0 then
   debug1="q3"
   -- moving left up
   cx = tx+tw-bx
   cy = ty+th-by
   if cx>=0 then
    return false
   elseif cy/cx > slp then
    return false
   else
    return true
   end
  else
   -- moving left down
   debug1="q4"
   cx = tx+tw-bx
   cy = ty-by
   if cx>=0 then
    return false
   elseif cy/cx < slp then
    return false
   else
    return true
   end
  end
 end
 return false
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000018350183401833018320183101831023200212001f2001b20019200182001720005200042001f50020500225002350017500195001a5001c5001d5001450015500165001650013500145001450014500
000100002435024340243302432024310243100c50000000115000000011500000001150000000115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001e4201c4201a420184201642013420104200d420094200642003420004200140021000000002100000000000000000000000000000000000000000000000000000000000000000000000000000000000
