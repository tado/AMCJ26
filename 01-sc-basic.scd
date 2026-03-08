// SuperColliderはじめの一方

Server.killAll; // サーバーをリセット
s.boot; // サーバーを起動

// まず完成イメージから
// ステップバイステップでこれを作っていきます
(
SynthDef("mySynth",
  {
    arg out = 0, gate = 1, freq = 440, detune = 1.005, 
        cutoff = 1200, cutfreq = 1.0, amp = 0.8;
    var sig, cutsig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
    sig = MoogFF.ar(sig, cutsig, mul: 2.0);
    sig = GVerb.ar(sig, 100, 1.0);
    Out.ar(out, sig);
}).add;
)

a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0);

---
/*
 * 1. 文法の基本
 */

// 文字列オブジェクト.メソッド
"Hello world".postln;
// 別の方法
postln("Hello world");

---

// メソッドの連結
"Hello world".reverse.postln;
postln(reverse("Hello world"));

---

// 変数の宣言と代入 ※まとめて実行
(
var str;
str = "Hello world";
str.postln;
)

---

// 環境変数 ※1行ずつの実行も可能
~str = "Hello world";
~str.postln;

// 1文字の変数は環境変数になる
a = "Hello world";
a.postln;

---

// 関数の定義
(
  ~func = {
    var msg1, msg2;
    msg1 = "Hello";
    msg2 = "world";
    (msg1 + msg2).postln;
  }
)
// 関数の実行
~func.value;

---

// 関数へ引数を渡す
(
  ~func = {
    arg msg1, msg2;
    var bindMsg;
    bindMsg = msg1 + msg2;
    bindMsg.postln;
  }
)
// 引数を指定して関数を評価
~func.value("Hello", "World");
~func.value("こんにちは", "世界");

---

/*
 * 2. 音響を生成
 */

// サーバーの起動
s.boot;

// サーバーの停止
Server.killAll;

---

// 最初の音: サイン波
(
  ~func = {
    SinOsc.ar();
  }
)
~func.play;

// 1行にまとめる
{SinOsc.ar()}.play;

---

// ステレオで
{SinOsc.ar().dup(2)}.play;

---

// 周波数を指定 SinOsc.ar(freq, phase, mul, add)
{SinOsc.ar(110).dup(2)}.play;

---

// 音量を指定
{SinOsc.ar(110, 0, 0.5).dup(2)}.play;

---

// キーワードで指定
{SinOsc.ar(freq: 110, mul: 0.5).dup(2)}.play;

---

// 周波数と音量を変数で指定
(
~func = {
    var freq = 110, amp = 0.5;
    SinOsc.ar(freq, 0, amp).dup(2);
  }
)
~func.play;

---

/*
 * 3. 楽器(SynthDef)の作成
 */

// .playは簡易的な方法、より厳密にSynthDefを定義
// 音量と周波数を引数で指定できるようにする
(
  SynthDef("mySynth", {
    arg out = 0, freq = 440, amp = 0.8;
    var sig;
    sig = SinOsc.ar(freq) * amp;
    Out.ar(out, sig.dup(2));
  }).add;
)

---

// SynthDefを演奏
a = Synth("mySynth");
a.set(\freq, 330, \amp, 0.5);
a.set(\freq, 440, \amp, 0.5);
a.free;
b = Synth("mySynth", [freq: 880, amp: 0.4]);
b.free;

---

// Sin波からSaw波に変更
(
  SynthDef("mySynth", {
    arg out = 0, freq = 440, amp = 0.8;
    var sig;
    sig = Saw.ar(freq) * amp;
    Out.ar(out, sig.dup(2));
  }).add;
)
a = Synth("mySynth", [freq: 110]);
a.free;

---

// 周波数を微妙にずらして重ねてみる
// 深みのあるサウンドに
(
  SynthDef("mySynth", {
    arg out = 0, freq = 110, detune = 1.005, amp = 0.8;
    var sig;
    sig = Saw.ar([freq / detune, freq * detune], amp);
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [freq: 110, detune: 1.005]);
a.free;

---

// さらに複数のSaw波を重ねてみる
(
  SynthDef("mySynth", {
    arg out = 0, freq = 110, detune = 1.005, amp = 0.8;
    var sig;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0 * amp;
    Out.ar(out, sig);
  }).add;
) 
a = Synth("mySynth", [freq: 110, detune: 1.005]);
a.free;

---

// エンベロープを追加してみる
(
  SynthDef("mySynth", {
    arg out = 0, gate = 1, freq = 110, detune = 1.005, amp = 0.8;
    var sig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0); // 音を止める

---

// フィルターを追加してみる
// MoogFF：Moogフィルターを適用するUGen
(
  SynthDef("mySynth", {
    arg out = 0, gate = 1, freq = 110, detune = 1.005, 
        cutoff = 2000, amp = 0.8;
    var sig, cutsig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    sig = MoogFF.ar(sig, cutoff, mul: 2.0);
    Out.ar(out, sig);
}).add;
)
a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0);

---

// フィルターの周波数をゆらがせる
(
  SynthDef("mySynth", {
    arg out = 0, gate = 1, freq = 110, detune = 1.005, 
        cutoff = 1200, cutfreq = 1.0, amp = 0.8;
    var sig, cutsig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
    sig = MoogFF.ar(sig, cutsig, mul: 2.0);
    Out.ar(out, sig);
}).add;
)
a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0);

---

// リバーブを追加してみる
// GVerb：リバーブを適用するUGen
(
SynthDef("mySynth",
  {
    arg out = 0, gate = 1, freq = 440, detune = 1.005, 
        cutoff = 1200, cutfreq = 1.0, amp = 0.8;
    var sig, cutsig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]) 
      , Saw.ar([freq / detune, freq * detune] / detune)
      , Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
    sig = MoogFF.ar(sig, cutsig, mul: 2.0);
    sig = GVerb.ar(sig, 100, 1.0);
    Out.ar(out, sig);
}).add;
)
a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0);

// これで完成です！

---

/*
 * 4. パターンで演奏してみる
 */

(
TempoClock.default.tempo = 80/60;
p = Pbind(
    \instrument, "mySynth",
    \scale,      Scale.indian(\pythagorean),
    \degree,     Prand([0, 1, 2, 3, 4], inf),
    \octave,     Prand([2, 3, 3, 4, 5], inf),
    \detune,     Pwhite(1.0, 1.005),
    \cutoff,     Pwhite(100, 4000),
    \amp,        Pwhite(0.15, 0.5),
    \dur,        Prand([1/4, 1/2, 1/2, 1], inf),
    \legato,     Pwhite(0.5, 1.0)
).play;
)
p.stop;

---

// 複数のパターンを同時に演奏
(
TempoClock.default.tempo = 80/60;
~p1 = Pbind(
    \instrument, "mySynth",
    \scale,      Scale.indian(\pythagorean),
    \degree,     Prand([0, 1, 2, 3, 4], inf),
    \octave,     Prand([2, 3, 3, 4, 5], inf),
    \detune,     Pwhite(1.0, 1.005),
    \cutoff,     Pwhite(100, 4000),
    \amp,        Pwhite(0.15, 0.5),
    \dur,        Prand([1/4, 1/2, 1/2, 1], inf),
    \legato,     Pwhite(0.5, 1.0)
).play;

~p2 = Pbind(
    \instrument, "mySynth",
    \scale,      Scale.indian(\pythagorean),
    \degree,     Prand([0, 1, 2, 3, 4], inf),
    \octave,     Prand([4, 5, 5, 6], inf),
    \detune,     Pwhite(1.0, 1.005),
    \cutoff,     Pwhite(100, 4000),
    \amp,        Pwhite(0.15, 0.5),
    \dur,        Prand([1/4, 1/4, 1/2], inf),
    \legato,     Pwhite(0.5, 1.0)
).play;
)

~p1.stop; ~p2.stop;

// これで基本のおさらいは終わりです！