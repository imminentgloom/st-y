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


engine.name = "ulyd" -- is also noise

function init()
	
	
	--define parameteres
	--controlspec.new(min, max, warp, step, default, units, quantum, warp)

	params:add_separator("synth")
	
	params:add_control("hz", "hz", controlspec.FREQ)
	params:set_action("hz", engine.hz)
	
	params:add_control("hard", "hard", controlspec.new(0.5, 24, "exp", 0, 1.5, ""))
	params:set_action("hard", engine.hard)
	
	params:add_control("soft", "soft", controlspec.new(0.001, 0.5, "exp", 0.01, 0.001, ""))
	params:set_action("soft", engine.soft)
	
	params:add_control("drift", "drift", controlspec.new(1, 4, "lin", 0.01, 1.4, ""))
	params:set_action("drift", engine.drift)
	
	params:add_control("cut", "cut", controlspec.FREQ)
	params:set_action("cut", engine.cut)
	
	params:add_control("res", "res", controlspec.new(0, 5, "lin", 0, 2.0, ""))
	params:set_action("res", engine.res)
	
	params:add_control("fm", "fm", controlspec.new(0, 1, "lin", 0, 0.1, ""))
	params:set_action("fm", engine.fm)
	
	params:add_control("am", "am", controlspec.new(0, 0.5, "db", 0, 0.010, ""))
	params:set_action("am", engine.am)
	
	params:add_control("gain", "gain", controlspec.new(0, 1, "lin", 0.01, 0.5, ""))
	params:set_action("gain", engine.gain)
	
	params:add_control("mute", "mute", controlspec.new(0, 1, "lin", 1, 1, ""))
	params:set_action("mute", engine.mute)
	
	-- make list of parameters

	p_list = {'hard', 'soft', 'drift', 'cut', 'res', 'fm', 'am', 'gain'}
	p_zero = 0
	p_pos = 1
	g_pos = 1
	p_val = params:get_raw('hard')
	g_val = params:get_raw('hard')
	
	 -- define starting sound

	engine.hz(230)
	engine.hard(1.5)
	engine.soft(0.001)
 	engine.drift(1.4)
	engine.cut(600)
	engine.res(2.0)
	engine.fm(0.1)
	engine.am(0.01)
	engine.gain(0.5)
	engine.mute(1)
	
	-- softcut setup for delay, from "awake"
	
	params:add_separator("delay")
	
 	params:add{id="delay_level", name="delay level", type="control", 
    controlspec=controlspec.new(0,1,'lin',0,0.5,""),
    action=function(x) softcut.level(1,x) end}
  
  	params:add{id="delay_rate", name="delay rate", type="control", 
    controlspec=controlspec.new(0.1,20,'exp',0,0.1,""),
    action=function(x) softcut.rate(1,x) end}
  
  	params:add{id="delay_feedback", name="delay feedback", type="control", 
    controlspec=controlspec.new(0,1.0,'lin',0,0.75,""),
    action=function(x) softcut.pre_level(1,x) end}
  
  	params:add{id="delay_pan", name="delay pan", type="control", 
    controlspec=controlspec.new(-1,1.0,'lin',0,0,""),
    action=function(x) softcut.pan(1,x) end}
	
	audio.level_cut(1.0)
	audio.level_adc_cut(1)
	audio.level_eng_cut(0)
  	softcut.level(1,1.0)
  	softcut.level_slew_time(1,0.25)
	softcut.level_input_cut(1, 1, 1.0)
	softcut.level_input_cut(2, 1, 1.0)
	softcut.pan(1, 0.0)

  	softcut.play(1, 1)
	softcut.rate(1, 1)
  	softcut.rate_slew_time(1,0.25)
	softcut.loop_start(1, 1)
	softcut.loop_end(1, 1.5)
	softcut.loop(1, 1)
	softcut.fade_time(1, 0.1)
	softcut.rec(1, 1)
	softcut.rec_level(1, 1)
	softcut.pre_level(1, 0.75)
	softcut.position(1, 1)
	softcut.enable(1, 1)

	softcut.filter_dry(1, 0.125);
	softcut.filter_fc(1, 1200);
	softcut.filter_lp(1, 0);
	softcut.filter_bp(1, 1.0);
	softcut.filter_rq(1, 2.0);

	-- interface setup
	
	screen.aa(0)
	screen.font_face(11)
	screen.font_size(60)
	word = 'støy'
	remember = 'hard'
	held1 = false
	held2 = false
	held3 = false
	br_lines = 2
	br_row = 12
	br_row_bg = 6
	br_rows = 3
	
	-- draw the first things
	
	redraw_all()
end

function redraw_all()
  redraw()
	redraw_grid()
end

-- additional audio things

function level(x)
  params:set('level', x)
end

function send(x)
  audio.level_eng_cut(x)
end

-- norns interaction

function key(n,z)
  -- key actions: n = number, z = state
  if n == 1 and z == 1 then
    held1 = true
    word = 'alt'
  elseif n == 1 and z == 0 then
    held1 = false
    word = remember
    p_val = params:get_raw(p_list[p_pos])
  end
  
  if n == 2 and z == 1 then
    word = 'del'
    held2 = true
    send(1)
  elseif n == 2 and z == 0 then
    held2 = false
    word = remember
    send(0)
    
  end
  
  if n == 3 and z == 1 then
    word = 'null'
    held3 = true
    mute(0)
  elseif n == 3 and z == 0 then
    held3 = false
    word = remember
    mute(1)
  end
  
  if held2 == true and held3 == false then
    word = 'del'
  elseif held2 == false and held3 == true then
    word = 'null'
  elseif held2 == true and held3 == true then
    word = 'dull'
  end
  
  redraw_all()
end

function enc(n,d)
  -- encoder actions: n = number, d = delta
  -- only sets frequency
  if n == 1 then
    params:delta('hz', d)
    word = 'hz' -- what we print on the screen
    remember = word
    p_val = params:get_raw('hz') -- then the amount to draw
  end
  -- sets what we edit with e3
  if n == 2 and held1 == false then
    p_zero = (p_zero + d) % 8
    p_pos = p_zero + 1
    word = p_list[p_pos]
    remember = word
    p_val = params:get_raw(p_list[p_pos])
    g_val = params:get_raw(p_list[p_pos])
  elseif n == 2 and held1 == true then
    params:delta('delay_rate', d)
    word = 'rate'
    p_val = params:get_raw('delay_rate')
  end
  -- edits values choosen by e2
  if n == 3 and held1 == false then
    params:delta(p_list[p_pos], d)
    word = p_list[p_pos]
    remember = word
    p_val = params:get_raw(p_list[p_pos])
    g_val = params:get_raw(p_list[p_pos])
  elseif n == 3 and held1 == true then
    params:delta('delay_feedback',d)
    word = 'fb'
    p_val = params:get_raw('delay_feedback')
  end

  redraw_all()
end

-- draw interface

function block()
  -- draw a bargraph with a height proportional to the value of the control
  y = math.floor(p_val * 64)
  screen.rect(0, 64, 128, -y)
  screen.level(1)
  screen.fill()
end

function text()
  -- write the name of the current control
  screen.level(1)
  screen.move(3,48)
  screen.text(word)
end

function scanlines()
  for n = 0, 64 do
    screen.level(math.random(0,1) * 15)
    screen.move(0, n)
    screen.line(128, n)
    screen.stroke()
  end
end

function redraw()
  -- screen redraw
  screen.clear()
  screen.blend_mode(4)
  block()
  scanlines()
  text()
  screen.update()
end

-- grid interface

function row(row, str)
  for n = 1, 16 do
    g:led(n, row, br_row_bg)
  end
  for n = 1, math.floor(g_val * 16, 1) do
    g:led(n, row, str)
  end
end

function rows()
  for row = 1, 8 do
    for n = 1, math.floor(params:get_raw(p_list[row]) * 16, 1) do
      g:led(n, row, br_rows)
    end
  end
end

function scanlines_grid()
  for row = 1, 8 do
    active = math.random(0,1) * br_lines
    for n = 1, 16 do
      g:led(n, row, active)
    end  
  end
end

function redraw_grid()
  g:all(0)
  scanlines_grid(br_lines)
  rows()
  row(p_pos, br_row)
  g:refresh()
end

-- grid interaction

g = grid.connect()

g.key = function(x,y,z)
  
  if z == 1 and held1 == false then
    p_pos = y
    g_pos = y
    word = p_list[p_pos]
    remember = word
    if x/16 == 0.0625 then
      gridval = 0
    else
      gridval = x/16
    end
    params:set_raw(word, gridval)
    g_val = params:get_raw(word)
  elseif z == 1 and held1 == true then
    
  end
  
  redraw_all()
end

function cleanup()
  -- deinitialization
end