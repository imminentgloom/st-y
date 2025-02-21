--
--
--
--  "støy" is noise
--
--
--
-- ...
-- v3.0 / imminent gloom 
--
-- K1: shift
-- K2: delay send
-- K2 + shift: latch delay send
-- K3: mute (before eq/del)
-- 
-- E1: hz
-- E2: choose
-- E3: affect
--
-- E1 + shift: EQ dry/wet
-- E2 + shift: delay rate
-- E3 + shift: feedback
--
-- grid + shift: EQ band decay

-- setup
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

engine.name = "st_y"

g = grid.connect()

    delay = include("lib/delay")
     prms = include("lib/params")
MusicUtil = require("musicutil")

local save_on_exit = true

local word = "støy"
local prev_word = "hard"

local k1_held = false
local k2_held = false
local k3_held = false

local p_list = {"hard", "soft", "drift", "cut", "res", "fm", "am", "gain"}
local f_list = {"2.8k", "1.5k", "777", "411", "218", "115", "61", "29"}
local p_pos = 1

local p_val = 0
local g_val = 0

local y_buff = {{},{},{},{},{},{},{},{}}

-- init
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function init()

   delay:init()
   prms:init()

   if save_on_exit then
      params:read(norns.state.data .. "state.pset")
   end

   params:bang()

   p_val = params:get_raw("hard")
   g_val = p_val
   
   redraw()
   redraw_grid()
end

-- functions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local function g_buffer(buff, val, z)
   if z == 1 then
      -- add all held buttons to a table in order
      table.insert(buff, val)
   else
      -- remove each button as it is released
      for i, v in pairs(buff) do
         if v == val then
            table.remove(buff, i)
            break
         end
      end
   end
end

-- grid: buttons
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

g.key = function(x, y, z)
   g_buffer(y_buff[y], x, z)

   if not k1_held then
      if #y_buff[y] == 1 then -- choose row and set the val to the first button hit
         p_pos = y
         word = p_list[p_pos]
         prev_word = word
         if y_buff[y][1] == 1 then
            g_val = 0
         else
            g_val = y_buff[y][1] / g.cols
         end
      end
      
      if #y_buff[y] > 1 then -- set the val to the second, third etc. release returns to prev val
         p_pos = y
         word = p_list[p_pos]
         prev_word = word
         if y_buff[y][#y_buff[y]] == 1 then
            g_val = 0
         else
            g_val = y_buff[y][#y_buff[y]] / g.cols
         end
      end
      
      params:set_raw(word, g_val)
      p_val = params:get_raw(word)

   end

   if k1_held then
      if #y_buff[y] == 1 then -- choose row and set the val to the first button hit
         f_pos = y
         word = f_list[f_pos]
         if y_buff[y][1] == 1 then
            f_val = 0.01
         else
            f_val = y_buff[y][1] / g.cols
         end
      end
      
      if #y_buff[y] > 1 then -- set the val to the second, third etc. release returns to prev val
         f_pos = y
         word = f_list[f_pos]
         if y_buff[y][#y_buff[y]] == 1 then
            f_val = 0.01
         else
            f_val = y_buff[y][#y_buff[y]] / g.cols
         end
      end

      params:set_raw(word, f_val)
      p_val = params:get_raw(word)
   end
  
   redraw()
   redraw_grid()
end

-- grid: "color" palette
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local g_scanlines  =  1
local g_params     =  4
local g_current_bg =  6
local g_current    = 15

-- grid: lights
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function row_current(row) -- light up the current row, display val rounded to nearest 16th
   if not k1_held then	
      for n = 1, g.cols do
         g:led(n, row, g_current_bg)
      end
      for n = 1, math.floor(g_val * g.cols, 1) do
         g:led(n, row, g_current)
      end
   end
end

function row_all() -- light up all rows with val rounded to nearest 16th
   if not k1_held then
      for row = 1, 8 do
         for n = 1, math.floor(params:get_raw(p_list[row]) * g.cols, 1) do
            g:led(n, row, g_params)
         end
      end
   end

   if k1_held then
      for row = 1, 8 do
         for n = 1, math.floor(params:get_raw(f_list[row]) * g.cols, 1) do
            g:led(n, row, g_current)
         end
      end
   end
end

function scanlines_grid() -- draw noisy lines across the grid
   for row = 1, 8 do
      active = math.random(0, 1) * g_scanlines
      for n = 1, g.cols do
         g:led(n, row, active)
      end
   end
end

function redraw_grid()
   g:all(0)
   scanlines_grid()
   row_all()
   row_current(p_pos)
   g:refresh()
end

-- norns: interaction
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function key(n,z)

   if n == 1 and z == 1 then
      k1_held = true
      word = "alt"
      p_val = 0
   elseif n == 1 and z == 0 then
      k1_held = false
      word = prev_word
      p_val = params:get_raw(word)
   end

   if n == 2 and z == 1 then
      k2_held = true
      if not k1_held then
         params:set("delay_send", 1)
      end
      if k1_held then
         local val = (params:get("delay_send") + 1) % 2
         params:set("delay_send", val)
      end			
      word = "del"
      p_val = 0
   elseif n == 2 and z == 0 then
      k2_held = false
      if not k1_held then
         params:set("delay_send", 0)
      end
      word = prev_word
      p_val = params:get_raw(word)
   end	

   if n == 3 and z == 1 then
      k3_held = true
      params:set("level", 0)
      word = "null"
      p_val = 0
   elseif n == 3 and z == 0 then
      k3_held = false
      params:set("level", 1)
      word = prev_word
      p_val = params:get_raw(word)
   end

   if k2_held and k3_held then
      word = "dull"
   end
   
   redraw()
   redraw_grid()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function enc(n, d)
   
   if n == 1 and not k1_held then
      params:delta("hz", d)
      word = "hz"
      prev_word = word
      p_val = params:get_raw("hz")
   elseif n == 1 and k1_held then
      params:delta("blend", d)
      word = "ping"
      p_val = params:get_raw("blend")
   end

   if n == 2 and not k1_held then
      d = util.clamp(d, -1, 1)
      p_pos = (((p_pos - 1) + d) % #p_list) + 1
      word = p_list[p_pos]
      prev_word = word
      p_val = params:get_raw(word)
      g_val = p_val
   elseif n == 2 and k1_held then
      params:delta("delay_rate", d)
      word = "rate"
      p_val = params:get_raw("delay_rate")
   end
   
   if n == 3 and not k1_held then
      params:delta(p_list[p_pos], d)
      word = p_list[p_pos]
      prev_word = word
      p_val = params:get_raw(word)
      g_val = p_val
   elseif n == 3 and k1_held then
      params:delta("delay_feedback", d)
      word = "fb"
      p_val = params:get_raw("delay_feedback")
   end

   redraw()
   redraw_grid()
end

-- norns: screen
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function bargraph() -- val as bargraph
   y = math.floor(p_val * 64)
   screen.rect(0, 64, 128, -y)
   screen.level(1)
   screen.fill()
end

function scanlines() -- draw noisy lines across the screen
   for n = 0, 64 do
      screen.level(math.random(0,1) * 15)
      screen.move(0, n)
      screen.line(128, n)
      screen.stroke()
   end
end

function scribe() -- write a word on the screen
   screen.level(1)
   screen.font_face(11)
   screen.font_size(60)
   screen.move(3, 48)
   screen.font_face(11)
   screen.font_size(60)
   screen.text(word)
end

function redraw()
   screen.aa(0)
   screen.clear()
   screen.blend_mode(4)
   bargraph()
   scanlines()
   scribe()
   screen.update()
end

-- tidy up before we go
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cleanup()
   if save_on_exit then
      params:write(norns.state.data .. "state.pset")
   end
end
