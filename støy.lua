
--- STØY
--
-- 
-- 
-- 
-- 
-- 
-- v4.0 imminent gloom

engine.name = "st_y"
local g = grid.connect()

local     delay = include("lib/delay")
local       tab = require("tabutil")
local MusicUtil = require("musicutil")

-- setup
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local save_state = false

local key_1_held = false
local key_2_held = false
local key_3_held = false

local ui_dirty = false

local grid_keys = {{},{},{},{},{},{},{},{}}

local synth_params = {"hard", "soft", "drift", "cut", "res", "fm", "am", "gain"}
local eq_params = {"2.8k", "1.5k", "777", "411", "218", "115", "61", "29"}
local eq_numbers = {"2800", "1500", "777", "411", "218", "115", "61", "29"}

state = {
   hz = 0,
   hard = 0,
   soft = 0,
   drift = 0,
   cut = 0,
   res = 0,
   fm = 0,
   am = 0,
   gain = 0,
   splash = 0.4,
   blend = 0,
   band1 = 0,
   band2 = 0,
   band3 = 0,
   band4 = 0,
   band5 = 0,
   band6 = 0,
   band7 = 0,
   band8 = 0,
   delay_level = 0,
   delay_send = 0,
   delay_rate = 0,
   delay_feedback = 0,
   synth = true,
   list = synth_params, 
   current = "støy",
   previous = "hard",
   message = "støy",
   previous_message = "hard",
}


-- functions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function buffer(buff, val, z)
   if z == 1 then                   -- add all held buttons to a table in order
      table.insert(buff, val)
   else                             -- remove each button as it is released
      for i, v in pairs(buff) do
         if v == val then
            table.remove(buff, i)
            break
         end
      end
   end
end

local function set_state(id, val, message)
   id = tostring(id)
   message = message or id
   state[id] = val
   if tab.contains(synth_params, id) and state.current ~= state.previous then
      state.previous = state.current
      state.previous_message = state.message
   end
   state.current = id
   state.message = message
   ui_dirty = true
end

-- clocks
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function ui_event()
   while true do
      if ui_dirty then
         redraw()
         redraw_grid()
         ui_dirty = false
      end
      clock.sleep(1/60)
   end
end

local function splash_event()
   clock.sleep(1)
   state.current = state.previous
   ui_dirty = true
end

-- init
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function init()
   
   -- params
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   params:add_separator("støy")
   
   params:add_group("meta", 3)
   params:hide("meta")
      params:add_number("splash", "splash", 0, 10, 4)
      params:set_action("splash",
         function(x)
            set_state("splash", x/10, "støy")
         end
      )
      params:add_number("eq_params", "eq params", 1, 8, 1, "", true)
      params:set_action("eq_params",
         function(x)
            state.current = eq_params[x]
            state.message = state.current
            ui_dirty = true
         end
      )
      params:add_number("synth_params", "synth params", 1, 8, 1, "", true)
      params:set_action("synth_params",
         function(x)
            state.current = synth_params[x]
            state.message = state.current
            ui_dirty = true
         end
      )
      
   params:add_group("sound", 10)
      params:add_number("hz", "hz", 1, 120, 60)
      params:set_action("hz", 
         function(x)
            engine.hz(MusicUtil.note_num_to_freq (x))
            set_state("hz", x/120)
         end
      )
      params:add_control("hard", "hard", controlspec.new(0.5, 24, "exp", 0, 1.5))
      params:set_action("hard", 
         function(x)
            engine.hard(x)
            set_state("hard", params:get_raw("hard"))
         end
      )
      params:add_control("soft", "soft", controlspec.new(0.001, 0.251, "exp", 0, 0.0))
      params:set_action("soft", 
         function(x)
            engine.soft(x - 0.001)
            set_state("soft", params:get_raw("soft"))
         end
      )
      params:add_control("drift", "drift", controlspec.new(1, 4, "lin", 0, 1.4))
      params:set_action("drift", 
         function(x)
            engine.drift(x) 
            set_state("drift", params:get_raw("drift"))
         end
      )
      params:add_control("cut", "cut", controlspec.FREQ)
      params:set_action("cut", 
         function(x)
            engine.cut(x)
            set_state("cut", params:get_raw("cut"))
         end
      )
      params:add_control("res", "res", controlspec.new(0, 5, "lin", 0, 2.0))
      params:set_action("res", 
         function(x)
            engine.res(x)
            set_state("res", params:get_raw("res"))
         end
      )
      params:add_control("fm", "fm", controlspec.new(0, 1, "lin", 0, 0.1))
      params:set_action("fm", 
         function(x)
            engine.fm(x)
            set_state("fm", params:get_raw("fm"))
         end
      )
      params:add_control("am", "am", controlspec.new(0.001, 1, "exp", 0, 0.1))
      params:set_action("am", 
         function(x)
            engine.am(x - 0.001)
            set_state("am", params:get_raw("am"))
         end
      )
      params:add_control("gain", "gain", controlspec.new(0, 1, "lin", 0, 0.5))
      params:set_action("gain", 
         function(x)
            engine.gain(x)
            set_state("gain", params:get_raw("gain"))
         end
      )
      params:add_control("level", "level", controlspec.new(0, 1, "lin", 0, 1))
      params:set_action("level",
         function(x)
            engine.level(x)
            state.message = "null"
         end
      )

   params:add_group("delay", 4)
      params:add_control("delay_send", "send", controlspec.new(0, 1, "lin", 0, 0))
      params:set_action("delay_send", 
         function(x)
            audio.level_eng_cut(x)
            audio.level_adc_cut(x)
            set_state("delay_send", params:get_raw("delay_send"), "del")
         end
      )
      params:add_control("delay_rate", "rate", controlspec.new(0.1, 20, "exp", 0, 10))
      params:set_action("delay_rate", 
         function(x)
            softcut.rate(1, x)
            set_state("delay_rate", params:get_raw("delay_rate"), "rate")
         end
      )
      params:add_control("delay_feedback", "feedback", controlspec.new(0, 1.0, "lin", 0, 0.85))
      params:set_action("delay_feedback", 
         function(x)
            softcut.pre_level(1, x)
            set_state("delay_feedback", params:get_raw("delay_feedback"), "fb")
         end
      )
      params:add_control("delay_level", "level", controlspec.new(0, 1, "lin", 0, 1.0))
      params:set_action("delay_level", function(x) softcut.level(1, x) end)

   params:add_group("resonant equalizer", 9)
      params:add_control("blend", "dry/wet", controlspec.new(-1, 1, "lin", 0.01, -1.0))
      params:set_action("blend", 
         function(x)
            engine.blend(x)
            set_state("blend", params:get_raw("blend"))
         end
      )
      for n = 1, 8 do
         local id = eq_params[9 - n]
         local cmd = "ring" .. n
         params:add_control(id, "ring: " .. eq_params[n] .. " hz" , controlspec.new(0.01, 8, "exp", 0.01, 0.01))
         params:set_action(id,
            function(x)
               engine[cmd](x)
               state[id] = params:get_raw(id)
               if state.current ~= state.previous then state.previous = state.current end
               state.current = eq_params[9 - n]
               state.message = state.current
               ui_action = true
            end
         )
      end

   params:add_group("freq", 8)
   params:hide("freq")
      for n = 1, 8 do
         local id = "freq" .. n
         params:add_control(id, id, controlspec.new(20, 10000, "lin", .1, eq_numbers[9 - n], "hz"))
         params:set_action(id, function(x) engine[id](x) end)
      end


   params:add_group("amp", 8)
   params:hide("amp")
      for n = 1, 8 do
         local id = "amp" .. n
         params:add_control(id, id, controlspec.new(0, 1, "lin", 0.01, 15))
         params:set_action(id, function(x) engine[id](x) end)
      end
   
   params:bang()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   if save_state then params:read(norns.state.data .. "state.pset") end
   
   clk_ui = clock.run(ui_event)
   clk_splash = clock.run(splash_event)
   state.message = "støy"
end

-- grid: interaction
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function g.key(x, y, z)
   buffer(grid_keys[y], x, z)
   
   state.current = state.list[y]
   -- state.message = state.current

   if #grid_keys[y] == 1 then
      if grid_keys[y][1] == 1 then
         val = 0
      else
         val = grid_keys[y][1] / g.cols
      end
   end

   if #grid_keys[y] > 1 then
      if grid_keys[y][#grid_keys[y]] == 1 then
         val = 0
      else
         val = grid_keys[y][#grid_keys[y]] / g.cols
      end
   end
   
   params:set_raw(state.current, val)
   if z == 1 then ui_dirty = true end
end

-- grid: levels
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local br_scanlines  =  1 
local br_current    = 15
local br_current_bg =  6
local br_bars       =  4

-- grid: drawing
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function g_scanlines()
   for y = 1, 8 do
      if math.random(0, 1) == 1 then
         for x = 1, g.cols do
            g:led(x, y, br_scanlines)
         end
      end
   end
end

function g_bars()
   for y = 1, 8 do
      local length = math.floor(state[(state.list[y])] * g.cols, 1)
      for x = 1, g.cols do
         if state.current == state.list[y] then
            if x <= length then
               g:led(x, y, br_current)
            else
               g:led(x, y, br_current_bg)
            end
         else
            if x <= length then 
               g:led(x, y, br_bars)
            end
         end
      end
   end
end

function redraw_grid()
   g:all(0)
   g_scanlines()
   g_bars()
   g:refresh()
end

-- norns: keys
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function key(n, z)
   if n == 1 and z == 1 then k1_held = true else k1_held = false end
   if n == 2 and z == 1 then k2_held = true else k2_held = false end
   if n == 3 and z == 1 then k3_held = true else k3_held = false end
   
   if n == 1 and z == 1 then
      state.synth = false
      state.list = eq_params
      ui_dirty = true
   else
      state.synth = true
      state.list = synth_params 
      ui_dirty = true
   end

   if state.synth then
      if n == 2 and z == 1 then
         params:set("delay_send", 1)
      else
         params:set("delay_send", 0)
      end
      
      if n == 3 and z == 1 then
         params:set("level", 0)
      else
         params:set("level", 1)
      end
   else
      if n == 2 and z == 1 then
      
      else

      end
      
      if n == 3 and z == 1 then
      
      else

      end
   end
end

-- norns: encoders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function enc(n, d)
   if state.synth then
      if n == 1 then
         params:delta("hz", d)
      end
      
      if n == 2 then
         d = util.clamp(d, -1, 1)
         params:delta("synth_params", d)
      end
      
      if n == 3 then
         params:delta(state.current, d)
      end
   else
      if n == 1 then
         params:delta("blend", d)
      end
      
      if n == 2 then
         params:delta("delay_rate", d)
      end
      
      if n == 3 then
         params:delta("delay_feedback", d)
      end
   end
end

-- norns: drawing
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function bargraph()
   local y = math.floor(state[state.current] * 64)
   screen.rect(0, 64, 128, -y)
   screen.level(1)
   screen.fill()
end

function scanlines()
   for y = 0, 64 do
      screen.level(math.random(0,1) * 15)
      screen.move(0, y)
      screen.line(128, y)
      screen.stroke()
   end
end

function text()
   screen.level(1)
   screen.font_face(11)
   screen.font_size(60)
   screen.move(3, 48)
   screen.font_face(11)
   screen.font_size(60)
   screen.text(state.message)
end

function redraw()
   screen.aa(0)
   screen.clear()
   screen.blend_mode(4)
   bargraph()
   scanlines()
   text()
   screen.update()
end

-- cleanup
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cleanup()
   if save_state then params:write(norns.state.data .. "state.pset") end
end
