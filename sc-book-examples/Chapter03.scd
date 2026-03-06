// 第3章

/*
 * list-3_01
 */
s.boot;

/*
 * list-3_02
 */
{ SinOsc.ar() }.play

/*
 * list-3_03
 */
{ SinOsc.ar().dup(2) }.play

/*
 * list-3_04
 */
{ SinOsc.ar() ! 2 }.play

/*
 * list-3_05
 */
{ SinOsc.ar().dup(2) }.plot

/*
 * list-3_06
 */
{ SinOsc.ar().dup(2) }.scope

/*
 * list-3_07
 */
{ SinOsc.ar(440).dup(2) }.scope

/*
 * list-3_08
 */
{ SinOsc.ar(880).dup(2) }.scope

/*
 * list-3_09
 */
{ SinOsc.ar(880, 0.0, 0.5, 0.0).dup(2) }.scope

/*
 * list-3_10
 */
{ SinOsc.ar(220, 0.0, 0.8, 0.0).dup(2) }.scope

{ SinOsc.ar(660, 0.0, 0.2, 0.0).dup(2) }.scope

/*
 * list-3_11
 */
{ SinOsc.ar(440, 0.0, 2.0, 0.0).dup(2) }.scope

/*
 * list-3_12
 */
// 矩形波
// Pulse.ar(周波数, パルス幅, 音量, オフセット)
{ Pulse.ar(880, 0.5, 0.7, 0.0).dup(2) }.scope

// ノコギリ波
// Saw.ar(周波数, 音量, オフセット)
{ Saw.ar(880, 0.7, 0.0).dup(2) }.scope

// パルス波
// Blip.ar(周波数, ハーモニクス数, 音量, オフセット)
{ Blip.ar(880, 200, 0.7, 0.0).dup(2) }.scope

// 三角波
// VarSaw.ar(周波数, 位相, 波形幅, 音量, オフセット)
{ VarSaw.ar(880, 0.0, 0.5, 0.7, 0.0).dup(2) }.scope

/*
 * list-3_13
 */
// 矩形波
// Pulse.ar(周波数, パルス幅, 音量, オフセット)
{ Pulse.ar(880, 0.5, 0.7, 0.0).dup(2) }.freqscope

// ノコギリ波
// Saw.ar(周波数, 音量, オフセット)
{ Saw.ar(880, 0.7, 0.0).dup(2) }.freqscope

// パルス波
// Blip.ar(周波数, ハーモニクス数, 音量, オフセット)
{ Blip.ar(880, 200, 0.7, 0.0).dup(2) }.freqscope

// 三角波
// VarSaw.ar(周波数, 位相, 波形幅, 音量, オフセット)
{ VarSaw.ar(880, 0.0, 0.5, 0.7, 0.0).dup(2) }.freqscope

/*
 * list-3_14
 */
// ホワイトノイズの再生と波形表示
{ WhiteNoise.ar(0.5).dup(2) }.scope

// ホワイトノイズのスペクトル表示
{ WhiteNoise.ar(0.5).dup(2) }.freqscope

/*
 * list-3_15
 */
// ピンクノイズの再生と波形表示
{ PinkNoise.ar(0.5).dup(2) }.scope

// ピンクノイズのスペクトル表示
{ PinkNoise.ar(0.5).dup(2) }.freqscope

/*
 * list-3_16
 */
// ブラウンノイズの再生と波形表示
{ BrownNoise.ar(0.5).dup(2) }.scope

// ブラウンノイズのスペクトル表示
{ BrownNoise.ar(0.5).dup(2) }.freqscope

/*
 * list-3_17
 */
(
// Blip関数を定義し変数fに代入
f = { Blip.ar(440, 200, 0.7, 0.0).dup(2) };
)

// 変数fを使って再生し、生成されたSynthオブジェクトをxに代入
x = f.play;

// Synthオブジェクトxを使って停止
x.free;

/*
 * list-3_18
 */
(
// Blip関数を定義し変数fに代入
f = {
  // 再生中に変更したいパラメータを引数として定義
  arg freq = 440; // 周波数の引数。デフォルト値は440
  // 引数freqの値をBlip.arの周波数パラメータに適用
  Blip.ar(freq, 200, 0.7, 0.0).dup(2);
};
)

// 再生し、Synthオブジェクトをxに代入
x = f.play;

// 再生中にSynthオブジェクトxの'freq'引数の値を220に変更
x.set('freq', 220);

// さらに'freq'引数の値を110に変更
x.set('freq', 110);

// 停止
x.free;

/*
 * list-3_19
 */
(
// Blip関数を定義し変数fに代入
f = {
  // 複数の引数を定義（周波数、倍音数、振幅）
  arg freq = 440, numharm = 200, mul = 0.7;
  // それぞれの引数をBlip.arの対応するパラメータに適用
  Blip.ar(freq, numharm, mul, 0.0).dup(2);
};
)

// 再生し、Synthオブジェクトをxに代入
x = f.play;

// 'freq'と'numharm'の値を同時に変更
x.set('freq', 220, 'numharm', 20);

// さらに'freq'と'numharm'の値を変更
x.set('freq', 110, 'numharm', 5);

// 停止
x.free;

/*
 * list-3_20
 */
(
// Blip関数を定義し変数fに代入
f = {
  arg freq = 440, numharm = 200, mul = 0.7;
  Blip.ar(freq, numharm, mul, 0.0).dup(2);
};
)

// 再生
x = f.play;

// パラメータ変更
x.set('freq', 220, 'numharm', 20);
x.set('freq', 110, 'numharm', 5);

// 2秒かけてフェードアウト（またはリリース時間を設定）して停止
x.release(2);
