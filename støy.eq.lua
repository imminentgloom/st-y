--
--
--
--  'støy' is noise
--
--
--
-- ...
-- v2.0 / imminent gloom 
--
-- e1 hz
-- e2 choose
-- e3 affect
--
-- k1+e1 res eq dry/wet
-- k1+row decay time 
--
-- k1+e2 delay rate
-- k1+e3 feedback
-- k2 delay send
-- k3 mute, pre delay/eq
--

-- load engine

engine.name = 'ulydreseq' -- u- is the prefix of displeasure, lyd is sound, reseq because it adds a resonant equalizer


-- connect to grid

g = grid.connect()


-- get ready

function init()
	
	-- do we persist?
	
	persistence = true  -- start with default sound when false, start where you left off if true
	
	
	-- first screen, first word 
	-- big text, use small words
	
	word = 'støy'		-- words command change
	remember = 'hard'	-- sometimes we use word that have less meaning - remember the real word
	
	screen.aa(0)
	screen.blend_mode(4)
	screen.font_face(11)
	screen.font_size(60)
	
	
	-- grid: brightness levels (0-15)
	
	g_scanlines = 2		-- scanlines
	g_current = 12		-- current row, active segment
	g_background = 6	-- current row, background
	g_params = 3		-- all rows, current draws on top
	
	
	-- start with no keys held
	
	k1_held = false
	k2_held = false
	k3_held = false
	
	
	 -- the first scratches

	engine.hz(230)
	engine.hard(1.5)
	engine.soft(0.001)
 	engine.drift(1.4)
	engine.cut(600)
	engine.res(2.0)
	engine.fm(0.1)
	engine.am(0.01)
	engine.gain(0.5)
	engine.level(1)
	engine.blend(-1)
	
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
	softcut.rate(1, 10)
	softcut.rate_slew_time(1, 0.25)
	softcut.loop_start(1, 1)
	softcut.loop_end(1, 1.5)
	softcut.loop(1, 1)
	softcut.fade_time(1, 0.1)
	softcut.rec(1, 1)
	softcut.rec_level(1, 1)
	softcut.pre_level(1, 0.85)
	softcut.position(1, 1)
	softcut.enable(1, 1)
	
	softcut.filter_dry(1, 0.125)
	softcut.filter_fc(1, 900)
	softcut.filter_lp(1, 0.0)
	softcut.filter_bp(1, 1.0)
	softcut.filter_rq(1, 16.0)


	-- define parameters for synth and delay
	-- note: 'id', 'name', controlspec.new(min, max, warp, step, default, units, quantum, warp) 
	
	params:add_separator('støy')
	
	params:add_group('sound', 10)
	
	params:add_control('hz', 'hz', controlspec.FREQ)
	params:set_action('hz', function(x) engine.hz(x) end)
	
	params:add_control('hard', 'hard', controlspec.new(0.5, 24, 'exp', 0, 1.5, ''))
	params:set_action('hard', function(x) engine.hard(x) end)
	
	params:add_control('soft', 'soft', controlspec.new(0.001, 0.251, 'exp', 0, 0.0, ''))
	params:set_action('soft', function(x) engine.soft(x - 0.001) end)
	
	params:add_control('drift', 'drift', controlspec.new(1, 4, 'lin', 0, 1.4, ''))
	params:set_action('drift', function(x) engine.drift(x) end)
	
	params:add_control('cut', 'cut', controlspec.FREQ)
	params:set_action('cut', function(x) engine.cut(x) end)
	
	params:add_control('res', 'res', controlspec.new(0, 5, 'lin', 0, 2.0, ''))
	params:set_action('res', function(x) engine.res(x) end)
	
	params:add_control('fm', 'fm', controlspec.new(0, 1, 'lin', 0, 0.1, ''))
	params:set_action('fm', function(x) engine.fm(x) end)
	
	params:add_control('am', 'am', controlspec.new(0.001, 1, 'exp', 0, 0.1, ''))
	params:set_action('am', function(x) engine.am(x - 0.001) end)
	
	params:add_control('gain', 'gain', controlspec.new(0, 1, 'lin', 0, 0.5, ''))
	params:set_action('gain', function(x) engine.gain(x) end)
	
	params:add_control('level', 'level', controlspec.new(0, 1, 'lin', 0, 1, ''))
	params:set_action('level', function(x) engine.level(x) end)
	
	params:add_group('delay', 4)
	
	params:add_control('delay_send', 'send', controlspec.new(0, 1, 'lin', 0, 0, ''))
	params:set_action('delay_send', function(x) audio.level_eng_cut(x) end)
	
	params:add_control('delay_level', 'level', controlspec.new(0, 1, 'lin', 0, 1.0, ''))
	params:set_action('delay_level', function(x) softcut.level(1, x) end)
	
	params:add_control('delay_rate', 'rate', controlspec.new(0.1, 20, 'exp', 0, 10, ''))
	params:set_action('delay_rate', function(x) softcut.rate(1, x) end)
	
	params:add_control('delay_feedback', 'feedback', controlspec.new(0, 1.0, 'lin', 0, 0.85, ''))
	params:set_action('delay_feedback', function(x) softcut.pre_level(1, x) end)
	
	params:add_group('resonant equalizer', 9)

	params:add_control('blend', 'dry/wet', controlspec.new(-1, 1, 'lin', 0.01, -1.0, ''))
	params:set_action('blend', function(x) engine.blend(x) end)

	params:add_control('29', 'ring: 29 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('29', function(x) engine.ring1(x) end)
	
	params:add_control('61', 'ring: 61 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('61', function(x) engine.ring2(x) end)
	
	params:add_control('115', 'ring: 115 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('115', function(x) engine.ring3(x) end)
	
	params:add_control('218', 'ring: 218 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('218', function(x) engine.ring4(x) end)
	
	params:add_control('411', 'ring: 411 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('411', function(x) engine.ring5(x) end)
	
	params:add_control('777', 'ring: 777 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('777', function(x) engine.ring6(x) end)
	
	params:add_control('1.5k', 'ring: 1500 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('1.5k', function(x) engine.ring7(x) end)
	
	params:add_control('2.8k', 'ring: 2800 hz', controlspec.new(0.01, 5, 'lin', 0.01, .05))
	params:set_action('2.8k', function(x) engine.ring8(x) end)

	params:add_group('freq', 8)
	params:hide('freq') -- comment this away to edit band frequency from params menu

	params:add_control('freq1', 'freq1', controlspec.new(20, 10000, 'lin', .1, 29, 'hz'))
	params:set_action('freq1', function(x) engine.freq1(x) end)
	
	params:add_control('freq2', 'freq2', controlspec.new(20, 10000, 'lin', .1, 61, 'hz'))
	params:set_action('freq2', function(x) engine.freq2(x) end)
	
	params:add_control('freq3', 'freq3', controlspec.new(20, 10000, 'lin', .1, 115, 'hz'))
	params:set_action('freq3', function(x) engine.freq3(x) end)
	
	params:add_control('freq4', 'freq4', controlspec.new(20, 10000, 'lin', .1, 218, 'hz'))
	params:set_action('freq4', function(x) engine.freq4(x) end)
	
	params:add_control('freq5', 'freq5', controlspec.new(20, 10000, 'lin', .1, 411, 'hz'))
	params:set_action('freq5', function(x) engine.freq5(x) end)
	
	params:add_control('freq6', 'freq6', controlspec.new(20, 10000, 'lin', .1, 777, 'hz'))
	params:set_action('freq6', function(x) engine.freq6(x) end)
	
	params:add_control('freq7', 'freq7', controlspec.new(20, 10000, 'lin', .1, 1500, 'hz'))
	params:set_action('freq7', function(x) engine.freq7(x) end)
	
	params:add_control('freq8', 'freq8', controlspec.new(20, 10000, 'lin', .1, 2800, 'hz'))
	params:set_action('freq8', function(x) engine.freq8(x) end)

	params:add_group('amp', 8)
	params:hide('amp') -- comment this away to edit band amplitude from params menu
	
	params:add_control('amp1', 'amp1', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp1', function(x) engine.amp1(x) end)
	
	params:add_control('amp2', 'amp2', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp2', function(x) engine.amp2(x) end)
	
	params:add_control('amp3', 'amp3', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp3', function(x) engine.amp3(x) end)
	
	params:add_control('amp4', 'amp4', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp4', function(x) engine.amp4(x) end)
	
	params:add_control('amp5', 'amp5', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp5', function(x) engine.amp5(x) end)
	
	params:add_control('amp6', 'amp6', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp6', function(x) engine.amp6(x) end)
	
	params:add_control('amp7', 'amp7', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp7', function(x) engine.amp7(x) end)
	
	params:add_control('amp8', 'amp8', controlspec.new(0, 1, "lin", 0.01, .15))
	params:set_action('amp8', function(x) engine.amp8(x) end)
	
	params:bang()
	
	-- make a list of params to use with interface
	
	p_list = {'hard', 'soft', 'drift', 'cut', 'res', 'fm', 'am', 'gain'}
	-- f_list = {'29', '61', '115', '218', '411', '777', '1.5k', '2.8k'} -- low on top
	f_list = {'2.8k', '1.5k', '777', '411', '218', '115', '61', '29'} -- low on bottom
	
	p_pos_zero = 0					-- steps through numbers, starting at zero 
	p_pos = 1						-- examines a word from the list
	
	p_val = params:get_raw('hard')	-- the value we draw on screen
	g_val = params:get_raw('hard')	-- the value we draw on the grid
	-- there is also a f_val, but it does not need to initialize, it shows the state of the eq

	-- load last parms if we choose to persist
  
  	if persistence == true then
  		params:read('/home/we/dust/data/støy/state.pset')
  		params:bang()
  	end


  	-- when something moves, everything changes
	
  	redraw_all()
end


-- drawing functions: interface

-- show the magnitued of a value as a bargraph

function bargraph()
	y = math.floor(p_val * 64)
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

function scribe()
	screen.level(1)
	screen.move(3, 48)
	screen.text(word)
end


-- draw the above on the screen

function redraw()
	screen.clear()
 	screen.blend_mode(4)
	bargraph()
	scanlines()
	scribe()
	screen.update()
end


-- drawing functions: grid

-- brightly light up the current row
-- display its value rounded to nearest 16th

function row_current(row)
	if k1_held == false then	
		for n = 1, 16 do
			g:led(n, row, g_background)
		end
		for n = 1, math.floor(g_val * 16, 1) do
			g:led(n, row, g_current)
		end
	end
end


-- dimly light up all rows with values rounded to nearest 16th (no background)

function row_all()
	if k1_held == false then
		for row = 1, 8 do
			for n = 1, math.floor(params:get_raw(p_list[row]) * 16, 1) do
				g:led(n, row, g_params)
			end
		end
	elseif k1_held == true then
		for row = 1, 8 do
			for n = 1, math.floor(params:get_raw(f_list[row]) * 16, 1) do
				g:led(n, row, g_current)
			end
		end
	end
end


-- draw noisy lines across the grid

function scanlines_grid()
	for row = 1, 8 do
		active = math.random(0, 1) * g_scanlines
		for n = 1, 16 do
			g:led(n, row, active)
		end
	end
end


-- draw the above on the grid

function redraw_grid()
	g:all(0)
	scanlines_grid()
	row_all()
	row_current(p_pos)
	g:refresh()
end


-- draw everything, everywhere

function redraw_all()
	redraw()
	redraw_grid()
end


-- two audio functions triggered to be triggered by the keys

-- set level to 0 to mute
	
function level(x)
	params:set('level', x)
end


-- turn up send to feed the delay

function send(x)
	params:set('delay_send', x)
end


-- norns keys (number and state)
-- the keys are supporting actors in this script, the action happens in enc()

-- words have less meaning here

-- note if key is held
-- then, do a thing
-- note if key is released
-- then, stop doing the thing

function key(n,z)

	-- set up k1 as an alt-key
	
	if n == 1 and z == 1 then
		k1_held = true
		word = 'alt'
		p_val = 0
	elseif n == 1 and z == 0 then
		k1_held = false
		word = remember
		p_val = params:get_raw(word)
	end


	-- send audio to delay if k2 is held
	
	if n == 2 and z == 1 then
		k2_held = true
		send(1.0)
		word = 'del'
		p_val = 0
	elseif n == 2 and z == 0 then
		k2_held = false
		send(0.0)
		word = remember
		p_val = params:get_raw(word)
	end	


	-- mute audio (but not delay) if k3 is held

	if n == 3 and z == 1 then
		k3_held = true
		level(0.0)
		word = 'null'
		p_val = 0
	elseif n == 3 and z == 0 then
		k3_held = false
		level(1.0)
		word = remember
		p_val = params:get_raw(word)
	end


	-- a word for when k2 and k3 are held simultaneously
	
	if k2_held == true and k3_held == true then
		word = 'dull'
	end
	
	
	-- when something moves, everything changes
	
	redraw_all()
end


-- norns encoders (number and change/delta)

function enc(n, d)
	
	-- there is a basic pattern
	-- something moves, a thing changes, a word is called and its meaning uttered
	
	-- e1 sets frequency, fine tune if k1 is held, it has no other function
	
	if n == 1 and k1_held == false then
		params:delta('hz', d)
		word = 'hz'
		remember = word
		p_val = params:get_raw('hz')
	elseif n == 1 and k1_held == true then
		params:delta('blend', d)
		word = 'ping'
		p_val = params:get_raw('blend')
	end


	-- e2 sets the parameter changed by e3 (alt: sets delay rate)
	
	if n == 2 and k1_held == false then
		p_pos_zero = (p_pos_zero + d) % #p_list	-- modulo starting at 0
		p_pos = p_pos_zero + 1	    	-- index list starting at 1
		word = p_list[p_pos]
		remember = word
		p_val = params:get_raw(word)
		g_val = p_val 					-- hold a subset of possible p_val-s that the grid understands ie. words from the list
	elseif n == 2 and k1_held == true then
		params:delta('delay_rate', d)
		word = 'rate'
		p_val = params:get_raw('delay_rate')
	end
	
	
	-- e3 changes the paramter set by e2 (alt: sets delay feedback)
	
	if n == 3 and k1_held == false then
	  params:delta(p_list[p_pos], d)
		word = p_list[p_pos]
		remember = word
		p_val = params:get_raw(word)
		g_val = p_val
	elseif n == 3 and k1_held == true then
		params:delta('delay_feedback', d)
		word = 'fb'
		p_val = params:get_raw('delay_feedback')
	end


	-- when something moves, everything changes

	redraw_all()
end


-- grid (x possiton, y possition, state)

g.key = function(x, y, z)
	if z == 1 then                                                			-- only act when keys are pressed
		if k1_held == false then
			p_pos_zero = y - 1
			p_pos = y												    	-- press any button in a row to select a word
			word = p_list[p_pos]
			remember = word
			if x / 16 == 0.0625 then g_val = 0 else g_val = x / 16 end		-- x possition sets the value, plays better if first button is 0
			params:set_raw(word, g_val)
			p_val = params:get_raw(word)
		elseif k1_held == true then
			f_pos = y
			word = f_list[f_pos]
			if x / 16 == 0.0625 then f_val = 0.01 else f_val = x / 16 end	-- x possition sets the value, plays better if first button is 0
			params:set_raw(word, f_val)
			p_val = params:get_raw(word)
	  	end
  end


	-- when something moves, everything changes

	redraw_all()
end


-- if there is a mess to clean up

function cleanup()

	-- if we choose to persist save params

	if persistence == true then
		params:write('/home/we/dust/data/støy/state.pset')
	end
end
