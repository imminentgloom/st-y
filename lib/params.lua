function params_init()
	params:add_separator('støy')
	
	params:add_group('sound', 10)

		params:add_control('hz', 'hz', controlspec.new(0, 125, "lin", 1, 60))
		params:set_action('hz', function(x) engine.hz(MusicUtil.note_num_to_freq (x))end)

		params:add_control('hard', 'hard', controlspec.new(0.5, 24, 'exp', 0, 1.5))
		params:set_action('hard', function(x) engine.hard(x) end)

		params:add_control('soft', 'soft', controlspec.new(0.001, 0.251, 'exp', 0, 0.0))
		params:set_action('soft', function(x) engine.soft(x - 0.001) end)

		params:add_control('drift', 'drift', controlspec.new(1, 4, 'lin', 0, 1.4))
		params:set_action('drift', function(x) engine.drift(x) end)

		params:add_control('cut', 'cut', controlspec.FREQ)
		params:set_action('cut', function(x) engine.cut(x) end)

		params:add_control('res', 'res', controlspec.new(0, 5, 'lin', 0, 2.0))
		params:set_action('res', function(x) engine.res(x) end)

		params:add_control('fm', 'fm', controlspec.new(0, 1, 'lin', 0, 0.1))
		params:set_action('fm', function(x) engine.fm(x) end)

		params:add_control('am', 'am', controlspec.new(0.001, 1, 'exp', 0, 0.1))
		params:set_action('am', function(x) engine.am(x - 0.001) end)

		params:add_control('gain', 'gain', controlspec.new(0, 1, 'lin', 0, 0.5))
		params:set_action('gain', function(x) engine.gain(x) end)

		params:add_control('level', 'level', controlspec.new(0, 1, 'lin', 0, 1))
		params:set_action('level', function(x) engine.level(x) end)


	params:add_group('delay', 4)

		params:add_control('delay_send', 'send', controlspec.new(0, 1, 'lin', 0, 0))
		params:set_action('delay_send', function(x) audio.level_eng_cut(x) end)

		params:add_control('delay_level', 'level', controlspec.new(0, 1, 'lin', 0, 1.0))
		params:set_action('delay_level', function(x) softcut.level(1, x) end)

		params:add_control('delay_rate', 'rate', controlspec.new(0.1, 20, 'exp', 0, 10))
		params:set_action('delay_rate', function(x) softcut.rate(1, x) end)

		params:add_control('delay_feedback', 'feedback', controlspec.new(0, 1.0, 'lin', 0, 0.85))
		params:set_action('delay_feedback', function(x) softcut.pre_level(1, x) end)


	params:add_group('resonant equalizer', 9)

		params:add_control('blend', 'dry/wet', controlspec.new(-1, 1, 'lin', 0.01, -1.0))
		params:set_action('blend', function(x) engine.blend(x) end)

		params:add_control('29', 'ring: 29 hz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('29', function(x) engine.ring1(x) end)

		params:add_control('61', 'ring: 61 hz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('61', function(x) engine.ring2(x) end)

		params:add_control('115', 'ring: 115 hz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('115', function(x) engine.ring3(x) end)

		params:add_control('218', 'ring: 218 hz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('218', function(x) engine.ring4(x) end)

		params:add_control('411', 'ring: 411 hz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('411', function(x) engine.ring5(x) end)

		params:add_control('777', 'ring: 777 hz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('777', function(x) engine.ring6(x) end)

		params:add_control('1.5k', 'ring: 1.5 khz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
		params:set_action('1.5k', function(x) engine.ring7(x) end)

		params:add_control('2.8k', 'ring: 2.8 khz', controlspec.new(0.01, 8, 'exp', 0.01, .05))
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
end