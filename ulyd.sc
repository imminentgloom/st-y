// CroneEngine_ulyd
// three oscillators: one is filtered, a second modulates the filter, a third modulates the gain
// three oscillators: mix and modulate themselves creating harder edges, shallower angles are softer

// Inherit methods from CroneEngine
Engine_ulyd : CroneEngine {
	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	alloc {

		synth = {

			arg	out, hz, hard, soft, drift, cut, res, fm, gain, am, mute;

			var fb, osc1, osc2, osc3, mix, filter, amp;

			fb = LeakDC.ar(Clip.ar(LocalIn.ar(1), -1, 1)) * hard;

			osc1 = VarSaw.ar(freq: (fb * hz + hz), width: soft);
			osc2 = VarSaw.ar(freq: (fb * hz + hz) * (drift * 2), width: soft);
			osc3 = VarSaw.ar(freq: (fb * hz + hz) * (drift * 3), width: soft);

			mix = Mix.ar([osc1, osc2, osc3]);
			LocalOut.ar(mix);

			filter = MoogFF.ar(in: osc1, freq: fm * (osc2 * cut) + cut, gain: res);
			amp = ((filter * gain) + (am * osc3)).tanh;

			Out.ar(out, Pan2.ar(amp*0.125)*mute);

		}.play(args: [\out, context.out_b], target: context.xg);

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
		
		this.addCommand("mute", "f", { arg msg;
			synth.set(\mute, msg[1]);
		});

	}

	// define a function that is called when the synth is shut down
	free {
		synth.free;
	}
}