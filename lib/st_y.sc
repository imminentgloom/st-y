// CroneEngine_st_y
// three oscillators: one is filtered, a second modulates the filter, a third modulates the gain
// three oscillators: mix and modulate themselves creating harder edges, shallower angles are softer
// a resonant eq at the end

// Inherit methods from CroneEngine
Engine_st_y : CroneEngine {
	var params;
	var <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {

		SynthDef(\st_y, {

			var fb;
			var freq, spread, width, osc1, osc2, osc3, mix;
			var cutoff, filter, dry;
			var freqs, amps, rings, wet;
			var output;

			fb = Sanitize.ar(LeakDC.ar(Clip.ar(LocalIn.ar(1), -1, 1))) * \hard.kr;

			freq = \hz.kr;
			spread = \drift.kr;
			width = \soft.kr;
			osc1 = VarSaw.ar(freq: (fb * freq + freq), width: width);
			osc2 = VarSaw.ar(freq: (fb * freq + freq) * (spread * 2), width: width);
			osc3 = VarSaw.ar(freq: (fb * freq + freq) * (spread * 3), width: width);
			mix = Mix.ar([osc1, osc2, osc3]);
			LocalOut.ar(mix);

			cutoff = \cut.kr;
			filter = MoogFF.ar(in: osc1, freq: \fm.kr * (osc2 * cutoff) + cutoff, gain: \res.kr);
			dry = ((filter * \gain.kr) + (\am.kr * osc3)).tanh * \level.kr;

			freqs = [\freq1, \freq2, \freq3, \freq4, \freq5, \freq6, \freq7, \freq8];
			amps = [\amp1, \amp2, \amp3, \amp4, \amp5, \amp6, \amp7, \amp8];
			rings = [\ring1, \ring2, \ring3, \ring4, \ring5, \ring6, \ring7, \ring8];
			wet = DynKlank.ar([freqs, amps, rings], dry);

			output = XFade2.ar(dry * 0.25, wet * 0.0125, pan: \blend.kr);
			output = Pan2.ar(output).tanh;
			Out.ar(\out, output);

		}).add;

		context.server.sync;

		synth = Synth.new(\st_y, [\out, context.out_b], context.xg);

		params = Dictionary.newFrom([
			\hz, 230,
			\hard, 1.5,
			\soft, 0.0,
			\drift, 1.4,
			\cut, 600,
			\res, 2.0,
			\fm, 0.1,
			\am, 0.1,
			\gain, 0.5,
			\blend, -1,
			\level, 1.0,
			\freq1, 29,
			\freq2, 61,
			\freq3, 115,
			\freq4, 218,
			\freq5, 411,
			\freq6, 777,
			\freq7, 1500,
			\freq8, 2800,
			\amp1, 0.15,
			\amp2, 0.15,
			\amp3, 0.15,
			\amp4, 0.15,
			\amp5, 0.15,
			\amp6, 0.15,
			\amp7, 0.15,
			\amp8, 0.15,
			\ring1, 0.05,
			\ring2, 0.05,
			\ring3, 0.05,
			\ring4, 0.05,
			\ring5, 0.05,
			\ring6, 0.05,
			\ring7, 0.05,
			\ring8, 0.05;
		]);

		params.keysDo({ arg key;
			this.addCommand(key, "f", { arg msg;
				params[key] = msg[1];
			});
		});
	}

	// define a function that is called when the synth is shut down
	free {
		synth.free;
	}
}
