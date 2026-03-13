(
  SynthDef("simple-sine", {
    arg note = 60, amp = 1, pan = 0, out_bus = 0;
    var freq = note.midicps;
    var snd = SinOsc.ar(freq) * EnvGen.kr(Env.perc(), doneAction: Done.freeSelf);
    Out.ar(out_bus, Pan2.ar(snd * amp, pan));
}).writeDefFile;
)

(
SynthDef("mySynth",
  {
    arg note = 60, amp = 1, pan = 0, out = 0, gate = 1, 
    attack = 0.01, release = 1.0, detune = 1.005, cutoff = 1200, cutfreq = 1.0;
    var freq, sig, cutsig, env;
    freq = note.midicps;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.perc(attack, release), gate, doneAction: 2);
    sig = sig * env * amp;
    cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
    sig = MoogFF.ar(sig, cutsig, mul: 2.0);
    sig = GVerb.ar(sig, 100, 1.0);
    Out.ar(out, sig);
}).writeDefFile;
)

