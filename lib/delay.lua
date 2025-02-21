delay = {}

function delay:init()
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
end

return delay
