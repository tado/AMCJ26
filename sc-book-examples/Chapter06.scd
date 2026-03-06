// 第6章

/*
 * list-6_01
 */
// サーバーを起動
s.boot;

// サウンドファイルをバッファーに読み込み
// SuperCollierに付属された「a11wlk01.wav」
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// b.plotでバッファの波形を表示
b.plot;

// b.playでバッファを単純に再生
b.play;

// 使い終わったバッファはメモリを解放する
b.free;

/*
 * list-6_02
 */
(
b = [
  // サウンドファイルを3つ読み込み
  Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01-44_1.aiff"),
  Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01.wav"),
  Buffer.read(s, Platform.resourceDir ++ "/sounds/SinedPink.aiff")
];
)

// 配列の0番目のバッファを再生
b[0].play;

// 配列の1番目のバッファを再生
b[1].play;

// 配列の2番目のバッファを再生
b[2].play;

/*
 * list-6_03
 */
(
b = [
  // サウンドファイルを3つ読み込み
  // ファイルのパスはサウンドファイルを格納した場所に書き換える
  // この例ではユーザーディレクトリ以下に「Sounds」フォルダを作成して保存
  Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-stereo.wav"),
  Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-mix-stereo.wav"),
  Buffer.read(s, Platform.userHomeDir ++ "/Sounds/guitar-mix-stereo.wav")
];
)

// 配列の0番目のバッファを再生
b[0].play;

// 配列の1番目のバッファを再生
b[1].play;

// 配列の2番目のバッファを再生
b[2].play;

/*
 * list-6_04
 */
//サウンドファイルへのパス
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-stereo.wav");

b.duration;     // 長さ（秒）
b.bufnum;       // バッファ番号
b.numFrames;    // 全サンプルフレーム数
b.numChannels;  // チャンネル数
b.sampleRate;   // サンプルレート（Hz）
b.query;        // いくつかの属性をまとめてポスト

/*
 * list-6_05
 */
(
b = Buffer.readChannel(
  s,
  //サウンドファイルへのパス
  Platform.userHomeDir ++ "/Sounds/guitar-mix-stereo.wav",
  channels: [0] // 左チャンネル（0番）のみを読み込む
);
)

b.play;

/*
 * list-6_06
 */
(
//サウンドファイルの入ったフォルダへのパス
var folder = PathName.new(Platform.userHomeDir ++ "/Sounds/");
// folder.entriesでフォルダ内の全ファイル（PathNameオブジェクト）の配列を取得
// .collectで各ファイルに対してBuffer.readを実行
b = folder.entries.collect({ |file| Buffer.read(s, file.fullPath) });
)

b[0].play;
b[1].play;
b[2].play;
// ...必要なだけバッファを再生

/*
 * list-6_07
 */
// サウンドファイルを読み込む
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

// PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop, doneAction)
// ここではチャンネル数とバッファ番号のみを指定
{PlayBuf.ar(b.numChannels, b.bufnum)}.play;

/*
 * list-6_08
 */
(
// このSynthDefはエラーになります

// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\playbuf_error, {
  arg nch = 1, buf = 0, out = 0;
  // nchはargなので、実行時に変更可能
  // しかしPlayBufのチャンネル数は固定でなければならない。
  var sig = PlayBuf.ar(nch, buf);
  Out.ar(out, sig ! 2);
}).add;
)

/*
 * list-6_09
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

// モノラルファイル再生用のSynthDef（チャンネル数を1に固定）
SynthDef(\playbuf_mono, {
  arg buf = 0, out = 0;
  // モノラル出力をステレオにパンニング
  var sig = PlayBuf.ar(1, buf).dup();
  Out.ar(out, sig);
}).add;
)

// 先ほど読み込んだバッファ（モノラル）を再生
Synth(\playbuf_mono, [buf: b.bufnum]);

/*
 * list-6_10
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\playbuf_loop, {
  arg buf = 0, loop = 1, out = 0;
  // doneAction: 2 で、ループがオフの時に再生終了後Synthを自動解放
  var sig = PlayBuf.ar(1, buf, loop: loop, doneAction: 2).dup();
  Out.ar(out, sig);
}).add;
)

// loopはデフォルトで1なので、ループ再生が始まる
x = Synth(\playbuf_loop, [buf: b.bufnum]);

// 演奏中にloopを0にすると、現在のループが終わり次第、再生を停止しSynthが解放される
x.set(\loop, 0);

/*
 * list-6_11
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\playbuf_rate, {
  arg buf = 0, rate = 1, loop = 1, out = 0;
  var sig, finalRate;
  // rateにBufRateScaleを乗算することで、サンプルレートの違いを補正
  finalRate = rate * BufRateScale.kr(buf);
  sig = PlayBuf.ar(1, buf, finalRate, loop: loop, doneAction: 2).dup();
  Out.ar(out, sig);
}).add;
)

// 通常の再生
x = Synth(\playbuf_rate, [\buf: b.bufnum]);

// 2倍速に
x.set(\rate, 2.0);

// 1/2スロー再生
x.set(\rate, 0.5);

// 逆再生
x.set(\rate, -1.0);

// 異なる再生速度を同時に再生
(
x = Synth(\playbuf_rate, [\buf: b.bufnum, \rate, 1.0]);
y = Synth(\playbuf_rate, [\buf: b.bufnum, \rate, 1.5]);
)

/*
 * list-6_12
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\playbuf_seek, {
  arg buf = 0, rate = 1, t_trig = 0, startPos = 0, loop = 1, out = 0;
  var sig, finalRate;
  finalRate = rate * BufRateScale.kr(buf);
  sig = PlayBuf.ar(1, buf, finalRate, t_trig, startPos, loop, doneAction: 2).dup();
  Out.ar(out, sig);
}).add;
)

x = Synth(\playbuf_seek, [buf: b.bufnum]);

// 0.5秒の地点にジャンプして再生を続ける
// s.sampleRateは1秒あたりのサンプルフレーム数なので、s.sampleRate / 2 で0.5秒地点のフレーム番号を計算
x.set(\startPos, s.sampleRate / 2, \t_trig, 1);

x.free;

/*
 * list-6_13
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\bufrd_line, {
  arg buf = 0, out = 0;
  var sig, phs;
  // 位相信号(phs): BufDur.kr(buf)秒かけて、0からバッファの最終フレーム（BufFrames.kr(buf) - 1）まで変化
  phs = Line.ar(0, BufFrames.kr(buf) - 1, BufDur.kr(buf), doneAction: 2);
  sig = BufRd.ar(1, buf, phs).dup();
  Out.ar(out, sig);
}).add;
)

Synth(\bufrd_line, [buf: b.bufnum]);

/*
 * list-6_14
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\bufrd_phasor, {
  arg buf = 0, rate = 1, out = 0;
  var sig, phs, finalRate;
  // サンプルレート補正
  finalRate = rate * BufRateScale.kr(buf);
  // 位相信号（phs）：0からBufFrames.kr(buf)までをfinalRateの速さで繰り返し
  phs = Phasor.ar(rate: finalRate, start: 0, end: BufFrames.kr(buf));
  sig = BufRd.ar(1, buf, phs).dup();
  Out.ar(out, sig);
}).add;
)

Synth(\bufrd_phasor, [buf: b.bufnum]);

/*
 * list-6_15
 */
(
// サウンドファイルを読み込み
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

SynthDef(\bufrd_noise, {
  arg buf = 0, rate = 1, out = 0;
  var sig, phs, finalRate;
  // サンプルレート補正
  finalRate = rate * BufRateScale.kr(buf);
  // 位相信号（phs）：0からBufFrames.kr(buf)までをノイズで読み出す
  phs = LFNoise2.ar(0.5).range(0, BufFrames.kr(buf));
  sig = BufRd.ar(1, buf, phs).dup();
  Out.ar(out, sig);
}).add;
)

Synth(\bufrd_noise, [buf: b.bufnum]);

/*
 * list-6_16
 */
// 0.5秒、モノラルの空のバッファを確保
b = Buffer.alloc(s, s.sampleRate * 0.5, 1);

/*
 * list-6_17
 */
(
{
  var sig;
  // 録音する音源を生成
  sig = SinOsc.ar(ExpRand(200, 1200));
  sig = sig * Env.perc(0.01, 0.49).ar(2);
  // RecordBufでバッファbにsigを録音
  RecordBuf.ar(sig, b);
  // 録音しつつ、音をスピーカーからも出力する
  sig = sig * 0.25 ! 2;
}.play;
)

// 録音された内容を再生して確認
b.play(mul: 0.25);

/*
 * list-6_18
 */
(
{
  var sig = SinOsc.ar(ExpRand(200, 1200));
  sig = sig * Env.perc(0.01, 0.49).ar(2);
  RecordBuf.ar(sig, b);
  0; // 出力は無音
}.play;
)

// 録音後に再生
b.play(mul: 0.25);

/*
 * list-6_19
 */
b.zero; // バッファをクリア

(
// この関数を4-5回実行してみる
{
  var sig = SinOsc.ar(ExpRand(200, 1200));
  sig = sig * Env.perc(0.01, 0.49).ar(2);
  // 新しい音(recLevel:1)と既存の音(preLevel:0.5)をミックスして録音
  RecordBuf.ar(sig, b, recLevel: 1, preLevel: 0.5);
  sig = sig * 0.25 ! 2;
}.play;
)

// 重ね録りされた結果を再生
{ PlayBuf.ar(1, b, doneAction: 2) * 0.25 ! 2 }.play;

/*
 * list-6_20
 */
b.zero; // バッファをクリア

(
x = {
  var sig, freq;
  freq = TExpRand.ar(200, 1200, Dust.ar(12));
  sig = SinOsc.ar(freq.lag(0.02));
  // ループ録音をオン
  RecordBuf.ar(sig, b, loop: 1);
  sig = sig * 0.25 ! 2;
}.play;
)

x.free; // 録音を停止

// 録音されたループを再生
y = { PlayBuf.ar(1, b, loop: 1) * 0.25 ! 2 }.play;

y.release(2);

/*
 * list-6_21
 */
// バッファーを確保
b = Buffer.alloc(s, s.sampleRate * 4.0, 2);
// バッファをクリア
b.zero;

(
x = {
  var sig, freq, phs, delay;
  freq = TExpRand.ar(100, 1200, Dust.ar(10).dup());
  // sig = SinOsc.ar(freq.lag(0.01));
  sig = SinOsc.ar(freq.lag(0.1));

  // 書き込み/読み込み用の位相信号（Phasorでループ）
  phs = Phasor.ar(0, BufRateScale.kr(b), 0, BufFrames.kr(b));

  // 現在の位相より少し前の位置から信号を読み出す（ディレイ）
  delay = BufRd.ar(2, b, phs - (SampleRate.ir / 4.0));

  // 書き込み：現在の音（sig）をバッファに書き込む
  BufWr.ar(sig, b, phs);

  // 出力：現在の音（sig）と、少し前に録音した音（delay）をミックス
  sig = sig + delay;
  sig = sig * 0.25;
}.play;
)

/*
 * list-6_22
 */
(
// 2秒のバッファーを確保（ステレオ）
b = Buffer.alloc(s, s.sampleRate * 2.0, 2);
// バッファをクリア
b.zero;

x = {
  var sig, freq, phs, delay;
  freq = LFNoise2.kr(0.1).range(50, 200);
  freq = [freq, freq * 1.01];
  sig = Blip.ar(freq, numharm: 8, width:0.01);
  sig = sig * Line.kr(0, 1, 0.1); // クリックノイズ防止の短いフェードイン

  phs = Phasor.ar(0, BufRateScale.kr(b), 0, BufFrames.kr(b));

  // バッファから読み出した音（フィードバック信号）
  delay = BufRd.ar(2, b, phs);

  // 現在の音（sig）とフィードバック信号（delay）をミックス
  sig = sig + (delay * 0.8);

  // ミックスした結果を再びバッファに書き込む
  BufWr.ar(sig, b, phs);

  // 出力
  sig = sig * 0.5;
}.play;
)

// 停止
x.release(2);

/*
 * list-6_23
 */
(
// --- 1. バッファへの音声ファイルの読み込み ---
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/drum-loop-mono.wav");

// --- 2. シンセサイザー定義 (SynthDef) ---
SynthDef(\GrainSimple,
  {
    // --- 2.1. 引数（arg）の定義 ---
    arg
    out = 0,       // 出力バスのインデックス
    trate = 20,    // 1秒あたりに生成するグレイン（音の粒）の数（Hz）
    speed = 0.02,  // サンプル再生位置を動かすLFOの周波数（Hz）
    rate = 1.0,    // 各グレインの再生速度（1.0が原曲と同じ速度）
    dur = 0.04,    // 各グレインの長さ（秒）
    amp = 1.0;     // 全体の音量

    // --- 2.2. ローカル変数の定義 ---
    var sig, trigger, pos;

    // --- 2.3. グラニュラーシンセシスの実装 ---
    // Impulse UGenを使い、trateで指定された周波数でトリガー信号を生成
    // このトリガーがグレインを生成するきっかけとなる
    trigger = Impulse.ar(trate);

    // LFSaw（低周波鋸波）を使い、再生位置を周期的に変化させる
    // .rangeメソッドで、LFOの出力範囲をバッファの開始位置（0）から終了位置（BufDur.kr(b)）に設定
    pos = LFSaw.kr(speed).range(0, BufDur.kr(b));

    // TGrains UGenを使い、グラニュラーシンセシスを行う
    // triggerが発生するたびに、バッファbのposで示される位置からグレインを生成
    sig = TGrains.ar(
      2,          // チャンネル数 (2: ステレオ)
      trigger,    // グレイン生成のトリガー
      b.bufnum,   // 使用するバッファの番号
      rate,       // グレインの再生速度
      pos,        // バッファ上の再生位置
      dur,        // グレインの持続時間
      0.0,        // パン（ステレオ定位）。0.0は中央。
      amp         // グレインの音量
    );

    // --- 2.4. 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// 再生
x = Synth(\GrainSimple);
// 停止
x.free();

// パラメータを変更して再生、より細かなグレインを高速に
x = Synth(\GrainSimple, [\trate, 40, \speed, 0.1, \rate, 1.0, \dur, 0.03, \amp, 0.5]);
// 停止
x.free();

// グレインの長さを長くして、より滑らかなサウンドに
x = Synth(\GrainSimple, [\trate, 20, \speed, 0.01, \rate, 1.0, \dur, 0.2, \amp, 0.5]);
// 停止
x.free();

/*
 * list-6_24
 */
(
// --- 1. バッファへの音声ファイルの読み込み ---
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/guitar-mix-mono.wav");

// --- 2. シンセサイザー定義（SynthDef）---
SynthDef(\GrainRandpos,
  {
    // --- 2.1. 引数（arg）の定義 ---
    arg
    out = 0,       // 出力バスのインデックス
    trate = 40,    // 1秒あたりに生成するグレイン（音の粒）の数（Hz）
    speed = 0.02,  // サンプル再生位置を動かすLFOの周波数（Hz）
    rate = 1.0,    // 全体的な音程
    posVar = 0.05, // 読み出し位置の分散
    dur = 0.04,    // 各グレインの長さ（秒）
    fadeIn = 2.0,  // フェードイン時間（秒）
    amp = 1.0;     // 全体の音量

    var sig, trigger, pos, rrate, pan, env; // 使用するローカル変数を宣言

    // Impulse UGenを使い、trateで指定された周波数でトリガー信号を生成
    // このトリガーがグレインを生成するきっかけとなる
    trigger = Impulse.ar(trate);

    // LFNoise2を使い、再生位置をランダムに変化させる
    pos = LFSaw.kr(speed).range(0, BufDur.kr(b))
    + LFNoise2.kr(100.0).range(0, posVar);

    // グレインの再生速度をランダムに変化させる
    rrate = Dseq([Dshuf([1.0, 1.5, 1.5**2, 1.5**3], 1)], inf) * rate;

    // パンニングをランダムに変化させる
    pan = Dseq([Dshuf([-1.0, -0.5, 0.0, 0.5, 1.0], 1)], inf);

    // TGrains UGenを使い、グラニュラーシンセシスを行う
    // triggerが発生するたびに、バッファbのposで示される位置からグレインを生成
    sig = TGrains.ar(
      2,          // チャンネル数 (2: ステレオ)
      trigger,    // グレイン生成のトリガー
      b.bufnum,   // 使用するバッファの番号
      rrate,       // グレインの再生速度
      pos,        // バッファ上の再生位置
      dur,        // グレインの持続時間
      pan,        // パン（ステレオ定位）。0.0は中央。
      amp         // グレインの音量
    );

    // 指定時間でフェードインするエンベロープを生成
    env = EnvGen.ar(Env.asr(fadeIn, curve:-1.0), 1.0);
    // エンベロープの適用
    sig = sig * env;

    // --- 2.3. 出力 ---
    // 生成されたオーディオ信号（sig）を、outで指定されたバスに出力
    Out.ar(out, sig);
  }
).add; // 作成したSynthDefをサーバーに追加
)

// 再生
x = Synth(\GrainRandpos);
// 停止
x.free();


// パラメータを変更して再生、よりグレインを高速に高密度に
x = Synth(\GrainRandpos, [\trate, 200, \speed, 0.004, \dur, 0.2, \fadeIn, 8.0, \amp, 0.5]);
// 全体の音程を変化させて音を重ねていく
y = Synth(\GrainRandpos, [\trate, 200, \speed, 0.002, \dur, 0.2, \amp, 0.5, \rate, 1.5]);
z = Synth(\GrainRandpos, [\trate, 200, \speed, 0.008, \dur, 0.2, \amp, 0.5, \rate, 0.5]);

// 停止
x.free();
y.free();
z.free();

/*
 * list-6_25
 */
(
// --- 1. バッファへの音声ファイルの読み込み ---
b = Buffer.read(s, Platform.userHomeDir ++ "/Sounds/guitar-mix-mono.wav");

// --- 2. シンセサイザー定義（SynthDef）---
SynthDef(\buf_grain_test, {
  // --- 2.1. 引数（arg）の定義 ---
  arg out = 0,       // 出力バス
  gate = 1,      // エンベロープのゲート
  trate = 400,   // 1秒あたりのグレイン生成数（Hz）
  dur = 0.1,     // 各グレインの長さ（秒）
  speed = 0.1,   // 再生位置を変化させる低速ノイズの周波数（Hz）
  posVar = 0.01, // 再生位置の揺らぎの大きさ（0.0 ~ 1.0）
  rate = 1.0,    // グレインの基本再生速度
  fadeIn = 8.0,  // 全体のエンベロープのフェードイン時間（秒）
  interp = 4,    // 補間の品質
  amp = 1.0,     // 全体の音量
  sndbuf;        // 使用するバッファ

  // --- 2.2. グラニュラーシンセシスの実装 ---
  var trigger, pan, rrate, pos, env, freqdev, sig;

  // `trate`で指定された周波数で、グレイン生成のきっかけとなるトリガー信号を生成
  trigger = Impulse.kr(trate);

  // パン（ステレオ定位）の値を生成するパターンを定義
  pan = Dseq([Dshuf([-1.0, -0.5, 0.0, 0.5, 1.0], 1)], inf);

  // グレインの再生速度を生成するパターンを定義し、基本速度（rate）を乗算します。
  rrate = Dseq([Dshuf([1.0, 1.5, 1.5**2, 1.5**3], 1)], inf) * rate;

  // 再生位置を決定、`speed`で制御されるゆっくりしたランダムな動きに、
  // `posVar`で制御される細かい揺らぎを加える
  pos = LFNoise2.kr(speed).range(0, 1) + LFNoise2.kr(100.0).range(0, posVar);

  // シンセ全体の音量を制御するエンベロープを生成
  env = EnvGen.ar(Env.asr(fadeIn, curve:2), 1.0, levelScale: amp);

  // GrainBuf UGenを使い、グラニュラーサウンドを生成
  // 各パラメータには上で定義した動的な信号が入力される
  sig = GrainBuf.ar(2, trigger, dur, sndbuf, rrate, pos, interp, pan, -1) * env;

  // --- 2.3. 出力 ---
  Out.ar(out, sig);
}).add;
)


// パラメーターを変化させながら音を重ねていく
~s1 = Synth(\buf_grain_test, [\sndbuf, b, \speed, 0.01, \posVar, 0.0]);
~s2 = Synth(\buf_grain_test, [\sndbuf, b]);
~s3 = Synth(\buf_grain_test, [\sndbuf, b, \rate, 2.0]);
~s4 = Synth(\buf_grain_test, [\sndbuf, b, \rate, 0.25]);
~s5 = Synth(\buf_grain_test, [\sndbuf, b, \speed, 1.0, \posVar, 0.1]);

~s5.free;
~s4.free;
~s3.free;
~s2.free;
~s1.free;
