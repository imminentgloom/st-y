
// CroneEngine_støy
// three oscillators: one is filtered, a second modulates the filter, a third modulates the gain
// three oscillators: mix and modulate themselves creating harder edges, shallower angles are softer
// a resonant eq at the end

Engine_st_y : CroneEngine {
	var <synth;
	var params;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		SynthDef(\st_y, {
			arg	out, hz, hard, soft, drift, cut, res, fm, gain, am, level, blend,
					freq1, freq2, freq3, freq4, freq5, freq6, freq7, freq8,
					amp1, amp2, amp3, amp4, amp5, amp6, amp7, amp8,
					ring1, ring2, ring3, ring4, ring5, ring6, ring7, ring8;

			var	fb,
					osc1, osc2, osc3, mix,
					cutoff, filter, dry,
					freqs, amps, rings, wet, fade;

			fb = Sanitize.ar(LeakDC.ar(Clip.ar(LocalIn.ar(1), -1, 1))) * hard;

			osc1 = VarSaw.ar(freq: (fb * hz + hz), width: soft);
			osc2 = VarSaw.ar(freq: (fb * hz + hz) * (drift * 2), width: soft);
			osc3 = VarSaw.ar(freq: (fb * hz + hz) * (drift * 3), width: soft);
			mix = Mix.ar([osc1, osc2, osc3]);
			LocalOut.ar(mix);

			filter = MoogFF.ar(in: osc1, freq: fm * (osc2 * cut) + cut, gain: res);
			dry = ((filter * gain) + (am * osc3)).tanh * level;

			freqs = [freq1, freq2, freq3, freq4, freq5, freq6, freq7, freq8];
			amps = [amp1, amp2, amp3, amp4, amp5, amp6, amp7, amp8];
			rings = [ring1, ring2, ring3, ring4, ring5, ring6, ring7, ring8];
			wet = DynKlank.ar(`[freqs, amps, rings], dry);

			fade = XFade2.ar(dry * 0.25, wet * 0.0125, pan: blend);
			Out.ar(out, Pan2.ar(fade)).tanh;
		}).add;

		context.server.sync;

		synth = Synth.new(\st_y, [context.out_b], context.xg);

		// Commands

		this.addCommand("hz", "f", { arg msg;
			synth.set(\hz, msg[1]);
		});

		this.addCommand("hard", "f", { arg msg;
			synth.set(\hard, msg[1]);
		});

		this.addCommand("soft", "f", { arg msg;
			synth.set(\soft, msg[1]);
		});

		this.addCommand("drift", "f", { arg msg;
			synth.set(\drift, msg[1]);
		});

		this.addCommand("cut", "f", { arg msg;
			synth.set(\cut, msg[1]);
		});

		this.addCommand("res", "f", { arg msg;
			synth.set(\res, msg[1]);
		});

		this.addCommand("fm", "f", { arg msg;
			synth.set(\fm, msg[1]);
		});

		this.addCommand("am", "f", { arg msg;
			synth.set(\am, msg[1]);
		});

		this.addCommand("gain", "f", { arg msg;
			synth.set(\gain, msg[1]);
		});

		this.addCommand("blend", "f", { arg msg;
			synth.set(\blend, msg[1]);
		});

		this.addCommand("level", "f", { arg msg;
			synth.set(\level, msg[1]);
		});

		this.addCommand("freq1", "f", { arg msg;
			synth.set(\freq1, msg[1]);
		});

		this.addCommand("freq2", "f", { arg msg;
			synth.set(\freq2, msg[1]);
		});

		this.addCommand("freq3", "f", { arg msg;
			synth.set(\freq3, msg[1]);
		});

		this.addCommand("freq4", "f", { arg msg;
			synth.set(\freq4, msg[1]);
		});

		this.addCommand("freq5", "f", { arg msg;
			synth.set(\freq5, msg[1]);
		});

		this.addCommand("freq6", "f", { arg msg;
			synth.set(\freq6, msg[1]);
		});

		this.addCommand("freq7", "f", { arg msg;
			synth.set(\freq7, msg[1]);
		});

		this.addCommand("freq8", "f", { arg msg;
			synth.set(\freq8, msg[1]);
		});

		this.addCommand("amp1", "f", { arg msg;
			synth.set(\amp1, msg[1]);
		});

		this.addCommand("amp2", "f", { arg msg;
			synth.set(\amp2, msg[1]);
		});

		this.addCommand("amp3", "f", { arg msg;
			synth.set(\amp3, msg[1]);
		});

		this.addCommand("amp4", "f", { arg msg;
			synth.set(\amp4, msg[1]);
		});

		this.addCommand("amp5", "f", { arg msg;
			synth.set(\amp5, msg[1]);
		});

		this.addCommand("amp6", "f", { arg msg;
			synth.set(\amp6, msg[1]);
		});

		this.addCommand("amp7", "f", { arg msg;
			synth.set(\amp7, msg[1]);
		});

		this.addCommand("amp8", "f", { arg msg;
			synth.set(\amp8, msg[1]);
		});

		this.addCommand("ring1", "f", { arg msg;
			synth.set(\ring1, msg[1]);
		});

		this.addCommand("ring2", "f", { arg msg;
			synth.set(\ring2, msg[1]);
		});

		this.addCommand("ring3", "f", { arg msg;
			synth.set(\ring3, msg[1]);
		});

		this.addCommand("ring4", "f", { arg msg;
			synth.set(\ring4, msg[1]);
		});

		this.addCommand("ring5", "f", { arg msg;
			synth.set(\ring5, msg[1]);
		});

		this.addCommand("ring6", "f", { arg msg;
			synth.set(\ring6, msg[1]);
		});

		this.addCommand("ring7", "f", { arg msg;
			synth.set(\ring7, msg[1]);
		});

		this.addCommand("ring8", "f", { arg msg;
			synth.set(\ring8, msg[1]);
		});
	}

	free {
		synth.free;
	}
}
