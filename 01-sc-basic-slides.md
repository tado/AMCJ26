---
marp: true
paginate: true
---
<style>
:root {
  font-family: 'Noto Sans JP';
  color: #444;
}
:root ol {
  list-style-type: decimal;
}
:root h1, h2, h3, h4, h5, h6{
  font-family: 'Noto Sans JP Black';
  color: #2277cc;
}
pre, code {
  font-family: 'JetBrains Mono Slashed', 'Noto Sans JP';
  line-height: 1.3;
}
th, td {
  font-size: 0.8em;
}
</style>

##### AMCJワークショップ<br>共鳴するコード、SuperColliderで創る音の世界 - 実践とその先へ

# 01.<br>準備体操: SuperColliderのおさらい<br>- Sin波からはじめるサウンドプログラミング

2026年3月14日
田所淳

---

# 01: SuperColliderの基本

---

## 完成イメージ

<style scoped>pre { font-size: 0.6em; }</style>

```java
SynthDef("mySynth", {
  arg out = 0, gate = 1, freq = 440, detune = 1.005,
      cutoff = 1200, cutfreq = 1.0, amp = 0.2;
  var sig, cutsig, env;
  sig = Mix.ar([
    Saw.ar([freq / detune, freq * detune]),
    Saw.ar([freq / detune, freq * detune] / detune),
    Saw.ar([freq / detune, freq * detune] / detune / 2.0)
  ]) / 3.0;
  env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
  sig = sig * env * amp;
  cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
  sig = MoogFF.ar(sig, cutsig, mul: 2.0);
  sig = GVerb.ar(sig, 100, 1.0);
  Out.ar(out, sig);
}).add;
```

ステップバイステップでこれを作っていきます

---

## このセクションの内容

1. 文法の基本
2. 音響を生成
3. 楽器（SynthDef）の作成
4. パターンで演奏

---

# 1. 文法の基本

---

## オブジェクトとメッセージ

```java
// オブジェクト.メッセージ(メソッド)
// 文字列オブジェクトにpostlnメッセージを送出
"Hello world".postln;

// 別の書き方（関数形式）
postln("Hello world");

// メッセージの連鎖
"Hello world".reverse.postln;
```

SuperColliderでは**すべてがオブジェクト**。
`オブジェクト.メッセージ` で操作を連鎖できる。

---

## オブジェクトとメッセージ

数値 (Int, Float) もメッセージを受けとることができるオブジェクト
C++などとは異なる

```java
100.sqrt.postln;  // 100の平方根を計算して表示
10.pow(3).postln; // 10の3乗を計算して表示
3.14.round.postln; // 3.14を四捨五入して表示
4.sqrt.log2.round(0.1).postln; // メッセージ連鎖
```

---

## 変数 — var と環境変数

<style scoped>pre { font-size: 0.75em; }</style>

```java
// ローカル変数: まとめて実行 (Ctrl+Enter)
(
var str;
str = "Hello world";
str.postln;
)

// 環境変数: 1行ずつ実行も可能
~str = "Hello world";
~str.postln;

// 1文字の変数は環境変数として使える
a = "Hello world";
a.postln;
```

`~変数名` はどこからでもアクセスできる**環境変数**
1文字の変数は暗黙のうちに環境変数になる

---

## 関数の定義と実行

```java
// 関数を定義して環境変数に代入
(
  ~func = {
    var msg1, msg2;
    msg1 = "Hello";
    msg2 = "world";
    (msg1 + msg2).postln;
  }
)

// 関数を評価
~func.value;
```

`{ ... }` が**関数オブジェクト（Function）**。`.value` で評価する。

---

## 関数への引数

```java
// 引数を持つ関数
(
  ~func = {
    arg msg1, msg2;
    var bindMsg;
    bindMsg = msg1 + msg2;
    bindMsg.postln;
  }
)

// 引数を指定して実行
~func.value("Hello", "World");
~func.value("こんにちは", "世界");
```

`arg` キーワードで**引数**を定義する。

---

# 2. 音響を生成

---

## サーバーの起動と停止

```java
// SuperColliderオーディオサーバーを起動
s.boot;

// すべてのサーバーを停止
Server.killAll;
```

`s` はデフォルトの**オーディオサーバー（scsynth）**。
音を出す前に必ず起動が必要。

---

## 最初の音 — SinOsc

```java
// サイン波を再生する関数を定義
~sine = {SinOsc.ar()};
// 関数を実行して音を鳴らす
~sine.play;

// 1行で書くこともできる
{SinOsc.ar()}.play;

// ステレオで再生
{SinOsc.ar().dup(2)}.play;
```

- `SinOsc.ar()` — サイン波を生成するUGen
- `.dup(2)` — 同じ信号を2チャンネルに複製（ステレオ）
- `Cmd+.` で音を止める

---

## 周波数と音量の指定

```java
// 周波数を指定 SinOsc.ar(freq, phase, mul, add)
{SinOsc.ar(110).dup(2)}.play;

// 音量(mul)を指定
{SinOsc.ar(110, 0, 0.8).dup(2)}.play;

// キーワード引数で指定
{SinOsc.ar(freq:110, mul:0.8).dup(2)}.play;
```

引数はキーワード形式（`名前:値`）でも指定できる。

---

## 変数を使って整理する

```java
(
~sig = {
    var freq = 440, amp = 0.8;
    SinOsc.ar(freq, 0, amp).dup(2);
  }
)
~sig.play;
~sig.release(2);
```

``~sig`` にサイン波を生成する関数を代入して整理。`~sig.play` で再生
``.release(2)`` で2秒かけてフェードアウトして停止

---

## 変数に引数を渡す

```java
// 1. まずはデフォルトで鳴らす（変数~sigに Synth オブジェクトを代入）
~sig = {arg freq = 440, amp = 0.1; SinOsc.ar(freq, 0, amp)}.play;

// 2. 後からメッセージを送って値を書き換える
~sig.set("freq", 660);
~sig.set("freq", 220, "amp", 0.5);

// 3. 音を止める
~sig.release(2); // 2秒かけてフェードアウト
```
`arg` で引数を定義し、`.set` で値を変更できる

---

# 3. 楽器（SynthDef）の作成

---

## SynthDefの基本

```java
// .playより厳密な方法 — SynthDefを定義
(
  SynthDef("mySynth", {
    arg out = 0, freq = 440, amp = 0.8;
    var sig;
    sig = SinOsc.ar(freq) * amp;
    Out.ar(out, sig.dup(2));
  }).add;
)
```

- `SynthDef("名前", { ... })` — 楽器の設計図を定義
- `arg` — 外部から変更できるパラメータ
- `Out.ar(out, sig)` — オーディオ出力

---

## SynthDefを演奏する

```java
// Synthを生成（音が鳴り始める）
a = Synth("mySynth");

// パラメータをリアルタイムで変更
a.set(freq: 330, amp: 0.5);
a.set(freq: 110, amp: 0.5);

// 音を停止して解放
a.free;

// 引数を指定して生成
b = Synth("mySynth", [freq: 880, amp: 0.8]);
b.free;
```

---

## SinOsc → Saw波に変更

```java
(
  SynthDef("mySynth", {
    arg out = 0, freq = 440, amp = 0.8;
    var sig;
    sig = Saw.ar(freq) * amp;  // SinOsc → Saw
    Out.ar(out, sig.dup(2));
  }).add;
)
a = Synth("mySynth", [freq: 110]);
a.free;
```

`Saw.ar()` — のこぎり波UGen。倍音が豊富でより存在感のある音。

---

## デチューンで厚みを出す

```java
(
  SynthDef("mySynth", {
    arg out = 0, freq = 440, detune = 1.005, amp = 0.8;
    var sig;
    sig = Saw.ar([freq / detune, freq * detune], amp);
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [freq: 110, detune: 1.005, amp: 0.8]);
a.free;
```

周波数をわずかにずらして2つ重ねることで**厚みのあるサウンド**に。

---

## Mix.arで複数の波を重ねる

<style scoped>pre { font-size: 0.7em; }</style>

```java
(
  SynthDef("mySynth", {
    arg out = 0, freq = 440, detune = 1.005, amp = 0.8;
    var sig;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]),
      Saw.ar([freq / detune, freq * detune] / detune),
      Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0 * amp;
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [freq: 110, detune: 1.005, amp: 0.8]);
a.free;
```

`Mix.ar([...])` — 複数の信号を**ミックス**する。`/ 3.0` で音量を調整。

---

## エンベロープを追加

<style scoped>pre { font-size: 0.7em; }</style>

```java
(
  SynthDef("mySynth", {
    arg out = 0, gate = 1, freq = 440, detune = 1.005, amp = 0.8;
    var sig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]),
      Saw.ar([freq / detune, freq * detune] / detune),
      Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0);  // gate=0で音が止まる
```

`Env.adsr()` — Attack, Decay, Sustain, Releaseエンベロープ。

---

## フィルターを追加

<style scoped>pre { font-size: 0.6em; }</style>

```java
(
  SynthDef("mySynth", {
    arg out = 0, gate = 1, freq = 440, detune = 1.005,
        cutoff = 2000, amp = 0.8;
    var sig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]),
      Saw.ar([freq / detune, freq * detune] / detune),
      Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    sig = MoogFF.ar(sig, cutoff, mul: 2.0);
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [\freq, 110]);
a.set(\gate, 0);
```

`MoogFF` — Moogスタイルのローパスフィルター。

---

## フィルターの周波数を揺らす

<style scoped>pre { font-size: 0.6em; }</style>

```java
(
  SynthDef("mySynth", {
    arg out = 0, gate = 1, freq = 440, detune = 1.005,
        cutoff = 1200, cutfreq = 1.0, amp = 0.8;
    var sig, cutsig, env;
    sig = Mix.ar([
      Saw.ar([freq / detune, freq * detune]),
      Saw.ar([freq / detune, freq * detune] / detune),
      Saw.ar([freq / detune, freq * detune] / detune / 2.0)
    ]) / 3.0;
    env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
    sig = sig * env * amp;
    cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
    sig = MoogFF.ar(sig, cutsig, mul: 2.0);
    Out.ar(out, sig);
  }).add;
)
a = Synth("mySynth", [\freq, 110]);  a.set(\gate, 0);
```

`LFNoise2.kr` — ランダムな低周波ノイズでフィルター周波数を変化させる。

---

## リバーブを追加して完成！

<style scoped>pre { font-size: 0.5em; }</style>

```java
(
SynthDef("mySynth", {
  arg out = 0, gate = 1, freq = 440, detune = 1.005,
      cutoff = 1200, cutfreq = 1.0, amp = 0.8;
  var sig, cutsig, env;
  sig = Mix.ar([
    Saw.ar([freq / detune, freq * detune]),
    Saw.ar([freq / detune, freq * detune] / detune),
    Saw.ar([freq / detune, freq * detune] / detune / 2.0)
  ]) / 3.0;
  env = EnvGen.kr(Env.adsr(), gate, doneAction: 2);
  sig = sig * env * amp;
  cutsig = LFNoise2.kr([cutfreq, cutfreq * 1.5]).range(cutoff * 0.25, cutoff * 1.5);
  sig = MoogFF.ar(sig, cutsig, mul: 2.0);
  sig = GVerb.ar(sig, 100, 1.0);  // リバーブ追加
  Out.ar(out, sig);
}).add;
)
a = Synth("mySynth", [\freq, 110]);  a.set(\gate, 0);
```

`GVerb` — ホール系リバーブ。空間の広がりが加わって完成！

---

# 4. パターンで演奏する

---

## Pbindで自動演奏

<style scoped>pre { font-size: 0.7em; }</style>

```java
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
```

`Pbind` — SynthDefをパターンで自動演奏。`Prand` / `Pwhite` でランダム変化。

---

## 複数のパターンを同時に演奏

<style scoped>pre { font-size: 0.4em; }</style>

```java
(
TempoClock.default.tempo = 80/60;
~p1 = Pbind(
    \instrument, "mySynth",
    \scale,   Scale.indian(\pythagorean),
    \degree,  Prand([0, 1, 2, 3, 4], inf),
    \octave,  Prand([2, 3, 3, 4, 5], inf),
    \detune,  Pwhite(1.0, 1.005),
    \cutoff,  Pwhite(100, 4000),
    \amp,     Pwhite(0.15, 0.5),
    \dur,     Prand([1/4, 1/2, 1/2, 1], inf),
    \legato,  Pwhite(0.5, 1.0)
).play;
~p2 = Pbind(
    \instrument, "mySynth",
    \scale,   Scale.indian(\pythagorean),
    \degree,  Prand([0, 1, 2, 3, 4], inf),
    \octave,  Prand([4, 5, 5, 6], inf),
    \detune,  Pwhite(1.0, 1.005),
    \cutoff,  Pwhite(100, 4000),
    \amp,     Pwhite(0.15, 0.5),
    \dur,     Prand([1/4, 1/4, 1/2], inf),
    \legato,  Pwhite(0.5, 1.0)
).play;
)
~p1.stop; ~p2.stop;
```

複数の `Pbind` を環境変数に代入し、個別に停止できる。

---

## まとめ

<div style="font-size: 0.82em">

| セクション | 内容 |
|---|---|
| 文法の基本 | オブジェクト・メソッド・変数・関数 |
| 音響を生成 | SinOsc / Saw / .play / .dup(2) |
| SynthDef | 引数・Mix・EnvGen・MoogFF・GVerb |
| パターン | Pbind / Prand / Pwhite / Scale |

</div>

**SynthDefの構成要素:**
- `Saw` — 波形 → `Mix` — 重ねる → `EnvGen` — 音量形状
- `MoogFF` — フィルター → `GVerb` — 空間

**次のセッション:** SuperCollider + VSCodeでVibe Coding！
