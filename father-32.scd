// Father-32 version 1.0.
//
// Moog Mother-32 Synth Emulation
//
// Description:
// The Mother-32 is a semi-modular analog synthesizer.
// Each function has been designed as a module,
// and useful parts of each module are “pre-wired”
// on the internal circuit board for making sound.
//
//
// Website: https://www.moogmusic.com/products/mother-32
//
// This is an emulation from what the website is describing
// and from what I remember from my own synth back in the day.
// This version do not include the patchbbay or ext. input options
// available on the hardware. This emulation replicates the pre-wired
// section of the synth with the same knob and switch functions.
//
// If you like it go buy it.
//
// This is definetly not a sponsored emulation.
//
// 26/04/2020
// Bangkok, Thailand
// K.E.


(SynthDef(\father32, {

	arg out, amp = 0.3, freq = 440, pan=0,
	atk= 0.5, rel= 1, pulsewidht=0.5, lfofreq=100, mixAmount=(-1.0), vcoModAmount = (-1.0),
	cutoff=800, res=0.0, gate=1, doneaction=2,
	vcoWave=0, vcoModSource=0, vcoModDestType=0, vcfModSource= 0,
	lfoWave=0, vcfMode=0, envType=0, vcaType=0, vcfModAmount = (-1.0);
	var env, sig, cutoffmod, synth, vcoMod, lfo, vcoModDest, mix, vca, filter, freqmod, pulsewidhtmod;

	doneaction = Select.kr(envType,[2, 2, 0]);

	lfo = Select.kr(lfoWave, [Saw.kr(lfofreq).range(0.1, 1), Pulse.kr(lfofreq).range(0.1, 1)]);

	env = Select.kr(envType, [
		EnvGen.kr(Env.perc(atk, rel), doneAction: doneaction),
		EnvGen.kr(Env.asr(atk, 0.8, rel), gate, doneAction: doneaction),
		1
	]);

	vcoMod= Select.kr(vcoModSource, [env, lfo]);
	freqmod=Select.kr(vcoModDestType,[freq, freq*vcoMod]);
	pulsewidhtmod=Select.kr(vcoModDestType,[pulsewidht*vcoMod, pulsewidht]);
	freq = XFade2.kr(freq, freqmod, vcoModAmount);
	pulsewidht = XFade2.kr (pulsewidht, pulsewidhtmod, vcoModAmount);
	synth = Select.ar(vcoWave, [Saw.ar(freq), Pulse.ar(freq, pulsewidht)]);
	mix = XFade2.ar(synth, WhiteNoise.ar, mixAmount);
	cutoffmod = Select.kr(vcfModSource, [cutoff*env, cutoff*lfo]);
	cutoff= XFade2.kr(cutoff, cutoffmod, vcfModAmount);
	filter = Select.ar(vcfMode,[MoogVCF.ar(mix, cutoff, res), HPF.ar(mix, cutoff)]);
	vca = filter*amp;
	vca = Splay.ar(vca);
	Out.ar(out, vca*env);

}).add;)

(~father32 = Synth.new(\father32, [
	\instrument, \mother32,
	\midinote, 62,
	\atk, 0.1,  // Attack
	\rel, 0.8, // Release
	\envType, 0, // 0 is sustain off, 1 is sustain on and 2 is VCA Mode on
	\vcoWave, 1, // VCO selection, 0 is saw wave, 1 is pulse wave
	\pulsewidht, 0.1, // Pulse width control for pulse wave
	\vcoModSource, 0, // Modulation source of the VCO, 0 is envelope, 1 is LFO
	\vcoModDestType, 0, // Destination of VCO modulation, 0 is pulse widht, 1 is frequency modulation
	\vcoModAmount, -1, // Amount of VCO modulation. -1.0 is minumum, 1.0 is max
	\lfoWave, 0, // LFO selection, 0 is saw wave, 1 is pulse wave
	\lforate, 200, // LFO's frequency rate
	\mixAmount, -1, // Mix between VCO and noise, -1.0 is full VCO and 1 is full noise
	\cutoff, 1900, // Filter cutoff frequency
	\res, 0.4,
	\vcfMode, 0, // Type of filter, 0 is LPF, 1 is HPF
	\vcfModSource, 1, // Modulation source of the VCF, 0 is envelope, 1 is LFO
	\vcfModAmount, -1, // Modulation amount of VCF, -1 is minumum, 1.0 is maximum
	\amp, 0.3 // Volume
]);)


(Pdef(\father32,

	Pbind(
		\instrument, \father32,
		\dur, Prand([1/2, 1/4, 0], inf),
		\midinote, Pseq([
			[40,52,57,59,62],
			[40,55,57,59,64],
			[40,52,57,59,62],
			[33,45,57,59,64],
		],inf),
		\atk, 0.1,  // Attack
		\rel, 0.8, // Release
		\envType, 0, // 0 is sustain off, 1 is sustain on and 2 is VCA Mode on
		\vcoWave, 1, // VCO selection, 0 is saw wave, 1 is pulse wave
		\pulsewidht, 0.1, // Pulse width control for pulse wave
		\vcoModSource, 0, // Modulation source of the VCO, 0 is envelope, 1 is LFO
		\vcoModDestType, 0, // Destination of VCO modulation, 0 is pulse widht, 1 is frequency modulation
		\vcoModAmount, -1, // Amount of VCO modulation. -1.0 is minumum, 1.0 is max
		\lfoWave, 1, // LFO selection, 0 is saw wave, 1 is pulse wave
		\lforate, 200, // LFO's frequency rate
		\mixAmount, -1, // Mix between VCO and noise, -1.0 is full VCO and 1 is full noise
		\cutoff, 1000, // Filter cutoff frequency
		\res, 0.4,
		\vcfMode, 0, // Type of filter, 0 is LPF, 1 is HPF
		\vcfModSource, 0, // Modulation source of the VCF, 0 is envelope, 1 is LFO
		\vcfModAmount, -1, // Modulation amount of VCF, -1 is minumum, 1.0 is maximum
		\amp, 0.3 // Volume

)).play;)
