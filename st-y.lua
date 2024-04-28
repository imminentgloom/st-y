--
--
--
--  "støy" is noise
-- 
--
--
-- ...
-- v1.0 / imminentgloom 
--
-- e1 hz
-- e2 choose
-- e3 affect
--
-- k1+e2 delay rate
-- k1+e3 feedback
-- k2 delay send
-- k3 mute


-- load engine

engine.name = "ulyd" -- u- is the prefix of displeasure, lyd is sound


-- connect to grid

g = grid.connect()


-- get ready

function init()
	
	-- first screen, first word 
	-- big text, use small words
	
	word = "støy" -- words command change
	remember = "hard" -- sometimes we use word that have less meaning - remember the real word
	
	screen.aa(0)
	screen.font_face(11)
	screen.font_size(60)

	screen.blend_mode(4)
	
	
	-- grid: brightness levels (0-15)
	
	g_br_r_scanlines = 2	-- scanlines
	g_br_r_current = 12		-- current row, active segment
	g_br_r_background = 6	-- current row, background
	b_br_r_all = 3			-- all rows, current draws on top
	
	
	-- start with no keys held
	
	k1_held = false
	k2_held = false
	k3_held = false
	
	
	-- set up delay in softcut
	
	audio.level_cut(1.0)
	audio.level_adc_cut(0.0)
	audio.level_eng_cut(0.0)
	softcut.level(1, 1.0)
	softcut.level_slew_time(1, 0.25)
	softcut.level_input_cut(1, 1, 1.0)
	softcut.level_input_cut(2, 1, 1.0)
	softcut.pan(1, 0.0)
	
	softcut.play(1, 1)
	softcut.rate(1, 1)
	softcut.rate_slew_time(1, 0.25)
	softcut.loop_start(1, 1)
	softcut.loop_end(1, 1.5)
	softcut.loop(1, 1)
	softcut.fade_time(1, 0.1)
	softcut.rec(1, 1)
	softcut.rec_level(1, 1)
	softcut.pre_level(1, 0.75)
	softcut.position(1, 1)
	softcut.enable(1, 1)
	
	softcut.filter_dry(1, 0.125)
	softcut.filter_fc(1, 1200)
	softcut.filter_lp(1, 0.0)
	softcut.filter_bp(1, 1.0)
	softcut.filter_rq(1, 2.0)


	-- define parameters for synth and delay
	-- note: "id", "name", controlspec.new(min, max, warp, step, default, units, quantum, warp) 
	
	params:add_separator("synth")
	
	params:add_control("hz", "hz", controlspec.FREQ)
	params:set_action("hz", function(x) engine.hz(x) end)
	
	params:add_control("hard", "hard", controlspec.new(0.5, 24, "exp", 0, 1.5, ""))
	params:set_action("hard", function(x) engine.hard(x) end)
	
	params:add_control("soft", "soft", controlspec.new(0.001, 0.5, "exp", 0.01, 0.001, ""))
	params:set_action("soft", function(x) engine.soft(x) end)
	
	params:add_control("drift", "drift", controlspec.new(1, 4, "lin", 0.01, 1.4, ""))
	params:set_action("drift", function(x) engine.drift(x) end)
	
	params:add_control("cut", "cut", controlspec.FREQ)
	params:set_action("cut", function(x) engine.cut(x) end)
	
	params:add_control("res", "res", controlspec.new(0, 5, "lin", 0, 2.0, ""))
	params:set_action("res", function(x) engine.res(x) end)
	
	params:add_control("fm", "fm", controlspec.new(0, 1, "lin", 0, 0.1, ""))
	params:set_action("fm", function(x) engine.fm(x) end)
	
	params:add_control("am", "am", controlspec.new(0, 0.5, "db", 0, 0.010, ""))
	params:set_action("am", function(x) engine.am(x) end)
	
	params:add_control("gain", "gain", controlspec.new(0, 1, "lin", 0.01, 0.5, ""))
	params:set_action("gain", function(x) engine.gain(x) end)
	
	params:add_control("level", "level", controlspec.new(0, 1, "lin", 1, 1, ""))
	params:set_action("leve", function(x) engine.level(x) end)

	params:add_separator("delay")
	
	params:addcontrol("delay_level", "level", controlspec.new(0, 1, 'lin', 0, 0.5, ""))
	params:set_action(function(x) softcut.level(1, x) end)
	
	params:addcontrol("delay_rate", "rate", controlspec.new(0.1, 20, 'exp', 0, 0.1, ""))
	params:set_action(function(x) softcut.rate(1, x) end)
	
	params:addcontrol("dealy_feedback", "feedback", controlspec.new(0, 1.0, 'lin', 0, 0.75, ""))
	params:set_action(function(x) softcut.pre_level(1, x) end)
			
	params:addcontrol("delay_pan", "pan", controlspec.new(-1, 1.0, 'lin', 0, 0, ""))
	params:set_action(function(x) softcut.pan(1, x) end)
	
	-- make a list of params to use with interface
	
	p_list = {"hard", "soft", "drift", "cut", "res", "fm", "am", "gain"}
	
	p_pos_zero = 0					-- steps through numbers, starting at zero 
	p_pos = 1						-- examines a word from the list
	
	p_val = params:get_raw("hard")	-- discovers the meaning of each word
	g_val = p_val					-- the grid knows fewer words and must not be distracted, "hard" is known
	
	-- when something moves, everything changes
	
	redraw_all()
end


-- drawing functions: interface

-- show the magnitued of a value as a bargraph

function bargraph(value)
	y = math.floor(value * 64)
	screen.rect(0, 64, 128, -y)
	screen.level(1)
	screen.fill()
end

-- draw noisy lines across the screen

function scanlines()
	for n = 0, 64 do
		screen.level(math.random(0,1) * 15)
		screen.move(0, n)
		screen.line(128, n)
		screen.stroke()
	end
end

-- write a word on the screen

function write(word)
	screen.level(1)
	screen.move(3, 48)
	screen.text(word)
end

-- draw the above on the screen

function redraw_screen(word, value)
	screen.clear()
	bargraph(value)
	scanlines()
	write(word)
	screen.update()
end


-- drawing functions: grid

-- brightly light up the current row
-- display its value rounded to nearest 16th

function row_current(row)
	for x = 1, 16 do
		g:led(x, row, g_br_r_background)
	end
	for x = 1, math.floor(g_val @ 16, 1) do
		g:led(x, row, g_br_r_current)
	end
end

-- dimly light up all rows with values rounded to nearest 16th (no background)

function row_all()
	for row = 1, 8 do
		for x = 1, math.floor(parmas:get_raw(p_list[row]) * 16, 1) do
			g:led(x, row, g_br_r_all)
		end
	end
end

-- draw noisy lines across the grid

function scanlines_grid()
	for row = 1, 8 do
		active = math.random(0, 1) * g_br_scanlines
		for x = 1, 16 do
			g:led(x, row, active)
		end
	end
end

-- draw the above on the grid

function redraw_grid()
	g:all(0)
	scanlines_grid()
	row_all()
	row_current(g_pos)
	g:refresh()
end


-- draw everything, everywhere

function refresh_all()
	redraw_screen()
	redraw_grid()
end


-- two audio functions triggered to be triggered by the keys

-- set level to 0 to mute
	
function level(x)
	params:set('level', x)
end

-- turn up send to feed the delay

function send(x)
	audio.level_eng_cut(x)
end


-- norns keys (number and state)
-- the keys are supporting actors in this script, the action happens in enc()

-- words have less meaning here

-- note if key is held
-- then, do a thing
-- note if key is released
-- then, stop doing the thing

function keys(n, z)

	-- set up k1 as an alt-key
	
	if n == 1 and z == 1 then
		k1_held = true
		word = "alt"
		p_val = 0
	elseif n == 1 and z == 0 then
		k1_held = false
		word = remember
		p_val = params:get_raw(p_list[word])
	end

	-- send audio to delay if k2 is held
	
	if n == 2 and z == 1 then
		k2_held = true
		send(1.0)
		word = "del"
		p_val = 0
	elseif n == 2 and z == 0 then
		k2_held = false
		send(0.0)
		word = remember
		p_val = params:get_raw(p_list[word])
	end	

	-- mute audio (but not delay) if k3 is held

	if n == 3 and z == 1 then
		k3_held = true
		word = "null"
		p_val = 0
		level(0.0)
	elseif n == 3 and z == 0 then
		k3_held = false
		word = remember
		p_val = params:get_raw(p_list[word])
		level(1.0)
	end
	
	-- a word for when k2 and k3 are held simultaneously
	
	if k2_held == true and k3_held == true then
		word = "dull"
	end
	
	-- when something moves, everything changes
	
	redraw_all()
end


-- norns encoders (number and change/delta)

function enc(n, d)
	
	-- there is a basic pattern
	-- something moves, a thing changes, a word is called and its meaning uttered
	
	-- e1 sets frequency, it has no other function
	
	if n == 1 then
		params:delta("hz", d)
		word = "hz"
		remember = word
		p_val = parmas:get_raw("hz")
	end

	-- e2 sets the parameter changed by e3 (alt: sets delay rate)
	
	if n == 2 and k1_held == false then
		p_zero = (p_zero + d) % #plist	-- modulo starting at 0
		p_pos = p_zero + 1				-- index list starting at 1
		word = p_list[p_pos]
		remember = word
		p_val = params:get_raw(p_list[p_pos])
		g_val = p_val 					-- hold a subset of possible p_val-s that the grid understands ie. words from the list
	elseif n == 2 and k1_held = true then
		params:delta("delay_rate", d)
		word = "rate"
		p_val = praams:get_raw("delay_rate")
	end
	
	-- e3 changes the paramter set by e2 (alt: sets delay feedback)
	
	if n == 3 and k1_held == false then
		params:delta(p_list[p_pos])
		word = p_list[p_pos]
		remember = word
		p_val = params:get_raw(p_list[p_pos])
		g_val = p_val
	elseif n == 3 and k1_held == true then
		params:delta("delay_feedback, d")
		word = "fb"
		p_val = params:get_raw("delay_feedback")
	end


	-- when something moves, everything changes

	redraw_all()
end


-- grid (x possiton, y possition - think of it as row, z is high if pressed)

g.key = function(x, y, z)
	if z == 1 and k1_held == false then
		p_pos = y													-- press any button in a row to select a word
		word = p_list[p_pos]
		remember = word
		if x / 16 == 0.0625 then g_val = 0 else g_val 0 x / 16 end	-- x possition sets the value, plays better if first button is 0
		param:set_raw(word, g_val)
		
	--[[ need to find a way to store states for this to be considered
	
	elseif z == 1 and k1_held == true then
		
		-- read the state of the synth from each row or key (lol @ 128 states)?
	
	elseif z == 1 and k1_held == true and k2_held == true then
		
		-- save states with one combo?
	
	elseif z == 1 and k1_held == true and k3_held == true then
		
		-- clear them with another?
	]]--
	end


	-- when something moves, everything changes

	redraw_all()
end


-- if there is a mess to clean up

function cleanup()

end






