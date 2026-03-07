//2つの記法
"Hello World!".postln;
postln("Hello World!");

//関数
~func = {"Hello World!".postln};
~func.value;
//関数を定義して呼び出す
{"Hello World!".postln}.value;

//音の出る関数
~func = {SinOsc.ar(440, 0, 0.7)!2};
~func.play;
//音の出る関数を定義して再生
{SinOsc.ar(440, 0, 0.7)!2}.play;
//引数にキーワード (分かりやすい)
{SinOsc.ar(freq: 440, phase: 0, mul: 0.7)!2}.play;

//変数
(
  {
    var freq, mul;
    freq = 440;
    mul = 0.5;
    SinOsc.ar(freq:freq, mul:mul)!2
  }.play
)

//デチューン
(
  {
    var freq, mul;
    freq = [440, 442];
    mul = 0.5;
    SinOsc.ar(freq:freq, mul:mul);
  }.play
)

//別の信号で周波数を変化させる+デチューン
(
  {
    var freq, mul;
    freq = SinOsc.kr([2.0, 2.05]).range(220, 440);
    mul = 0.5;
    SinOsc.ar(freq:freq, mul:mul);
  }.play
)

//Synthで再生
(
  SynthDef(\mySin, {
    var freq, mul, sig;
    freq = 440;
    mul = 0.5;
    sig = SinOsc.ar([freq, freq*1.005], mul:mul);
    Out.ar(0, sig);
  }).add;
)
Synth(\mySin);

//楽器SynthDefと引数
(
  SynthDef(\mySin, {
    arg out=0, freq=440, mul=0.5;
    var sig;
    sig = SinOsc.ar(freq:[freq, freq*1.005], mul:mul);
    Out.ar(out, sig);
  }).add;
)
Synth(\mySin, [freq: 660, mul: 0.3]);
Synth(\mySin, [freq: 440, mul: 0.3]);
Synth(\mySin, [freq: 330, mul: 0.3]);
