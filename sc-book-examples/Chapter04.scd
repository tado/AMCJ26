// 第4章

/*
 * list-4_01
 */
(
// 2つの音を混ぜるFunction
f = {
  // 変数の宣言
  var sig1, sig2;
  // 音1：Blip (オーディオレート .ar で生成、ステレオ化 .dup(2))
  sig1 = Blip.ar(110, 5, 0.5, 0.0).dup(2);
  // 音2：Pink Noise (オーディオレート .ar で生成、ステレオ化 .dup(2))
  sig2 = PinkNoise.ar(0.5).dup(2);
  // 2つの音の信号を足し合わせる
  sig1 + sig2;
};
)

// 再生
x = f.play;
// 停止（2秒かけてフェードアウト）
x.release(2);

/*
 * list-4_02
 */
(
// 3つのサイン波を混ぜるFunctionを定義
f = {
  // 引数の定義（音量調整用、デフォルト値0.2）
  arg mul = 0.2;

  // ローカル変数
  var sig1, sig2, sig3, freq;

  // 基本周波数の設定
  freq = 220; // A3

  // 音源1：基本周波数のサイン波
  sig1 = SinOsc.ar(freq, 0.0, mul).dup(2);

  // 音源2：周波数を変更したサイン波（1.5倍 = 完全5度上）
  freq = freq * 1.5; // 330Hz (E4)
  sig2 = SinOsc.ar(freq, 0.0, mul).dup(2);

  // 音源3：さらに周波数を変更したサイン波（さらに1.5倍 = 元の2.25倍）
  freq = freq * 1.5; // 495Hz (B4)
  sig3 = SinOsc.ar(freq, 0.0, mul).dup(2);

  // ミキシング：3つのサイン波の信号をすべて足し合わせる
  sig1 + sig2 + sig3;
};
)

x = f.play; // 再生（デフォルト音量 mul=0.2 で）
x.release(1); // 停止（1秒かけてフェードアウト）

// 引数を指定して音量を調整
x = f.play; // 再生
x.set('mul', 0.1); // 音量を半分にする
x.set('mul', 0.4); // 音量を倍にする
x.release(2); // 停止（2秒かけてフェードアウト）

/*
 * list-4_03
 */
(
// 3つの音を混ぜてから、全体の音量を調整するFunction
f = {
  // 引数: 全体の音量調整用、デフォルト 0.2
  arg mul = 0.2;

  // 変数の宣言
  var sig1, sig2, sig3, freq;

  // 基本周波数は220Hz
  freq = 220;

  // 音源1, 2, 3: 最大振幅 1.0 で生成
  sig1 = SinOsc.ar(freq).dup(2);      // 220Hz
  freq = freq * 1.5;
  sig2 = SinOsc.ar(freq).dup(2);      // 330Hz
  freq = freq * 1.5;
  sig3 = SinOsc.ar(freq).dup(2);      // 495Hz

  // ミキシングと全体の音量調整
  // まず3つの信号を足し合わせる（この時点では 1.0 を超える可能性あり）
  // その後、全体に mul（デフォルト 0.2）を掛けて最終的な振幅を調整
  (sig1 + sig2 + sig3) * mul;
};
)

// 再生（デフォルト mul=0.2 で）
x = f.play;
// 停止（2秒かけてフェードアウト）
x.release(2);

/*
 * list-4_04
 */
// Env.triangleの形状をプロット
Env.triangle(dur: 1.0, level: 1.0).plot;

// Env.sineの形状をプロット
Env.sine(dur: 1.0, level: 1.0).plot;

// Env.percの形状をプロット（curve = -4）
Env.perc(attackTime: 0.1, releaseTime: 1.0, level: 1.0, curve: -4).plot;

// Env.linenの形状をプロット（curve = 'lin'）
// sustainTime は gate が1であり続けた場合の最大持続時間を示す
Env.linen(attackTime: 0.1, sustainTime: 0.5, releaseTime: 1.0, level: 1.0, curve: 'lin').plot;

// Env.adsrの形状をプロット（curve = -4）
// sustainLevel は level に対する比率
Env.adsr(attackTime: 0.1, decayTime: 0.3, sustainLevel: 0.5, releaseTime: 1.0, level: 1.0, curve: -4).plot;

/*
 * list-4_05
 */
(
// パーカッシブなエンベロープを持つSinOscを演奏するFunction
f = {
  // ローカル変数を宣言
  var sig, env;

  // エンベロープ形状を定義（Env.percを使用）
  env = Env.perc(attackTime: 0.01, releaseTime: 1.0, curve: -4);

  // EnvGenでエンベロープ信号を生成（コントロールレート .kr）
  // doneAction: Done.freeSelf (2) を指定し、終了時に自動解放
  env = EnvGen.kr(env, doneAction: Done.freeSelf);

  // 音源（サイン波）を生成（オーディオレート .ar）
  sig = SinOsc.ar(freq: 440); // 440Hz（A4）

  // 音源（sig）にエンベロープ（env）を適用（乗算）
  sig = sig * env;

  // ステレオ出力にするために信号を複製
  sig = sig.dup(2);
};
)

// 再生
x = f.play;

/*
 * list-4_06
 */
(
// ADSRエンベロープを持つ音を生成するFunction
f = {
  // 引数の宣言：gateは外部から制御可能にする
  arg gate = 1; // デフォルトは1（オン）

  // 変数の宣言
  var sig, env;

  // エンベロープ形状を定義（Env.adsrを使用）
  // アタック0.01秒, ディケイ0.5秒, サステインレベル0.3, リリース1.0秒
  env = Env.adsr(0.01, 0.5, 0.3, 1.0, curve: -4);

  // EnvGenでエンベロープ信号を生成（コントロールレート .kr）
  // gate引数をEnvGenに接続する
  // doneAction: Done.freeSelf (2) で終了時に解放
  env = EnvGen.kr(env, gate, doneAction: Done.freeSelf);

  // 音源（サイン波）
  sig = SinOsc.ar(440);

  // エンベロープを適用
  sig = sig * env;

  // ステレオ出力
  sig = sig.dup(2);
};
)

// 再生（gate=1 で開始）-> アタック、ディケイを経てサステインレベルで持続
// 鍵盤を押した状態
x = f.play;

// 約2秒後にgateを0にする -> リリース段階開始
// 鍵盤を離した状態
x.set(\gate, 0);

/*
 * list-4_07
 */
(
// Functionベース：パーカッシブな音
f = {
  var sig, env;
  // エンベロープの形状をEnv.percで作成
  env = Env.perc();
  // エンベロープを生成、演奏が終わると自動解放
  env = EnvGen.kr(env, doneAction: Done.freeSelf);
  // 音源（Blip）
  sig = Blip.ar(110, 10);
  // 生成した音源にエンベロープを適用
  sig = sig * env;
  sig = sig.dup(2);
};
)
// 再生
x = f.play;

/*
 * list-4_08
 */
(
// SynthDefを定義します。SynthDef.new(名前, 関数)
SynthDef.new(
  "MyPercSynth", // SynthDefの名前（シンボル）
  {
    // --- 引数の宣言（arg）---
    // SynthDefが受け取る引数を定義
    // bus: 出力バス番号を受けとる、デフォルト値は0
    arg bus = 0;

    // --- ローカル変数の宣言（var）---
    var sig, env;

    // --- エンベロープの定義 ---
    env = Env.perc(attackTime: 0.01, releaseTime: 1.0, curve: -4);

    // --- エンベロープ信号の生成 ---
    env = EnvGen.kr(env, doneAction: Done.freeSelf);

    // --- 音源の生成 ---
    sig = Blip.ar(110, 10);

    // --- エンベロープ適用とステレオ化 ---
    sig = (sig * env).dup(2);

    // --- 出力先の明示（Out.ar）---
    // 最終的な信号をどのバスに出力するかをOut、UGenで明示
    // Out.ar(出力バス番号, 出力する信号);
    Out.ar(bus, sig);
  }
  // --- サーバーへの登録（.add）---
  // 定義したSynthDefをサーバーに送信し、コンパイル・登録
).add;
)

// --- 定義したSynthDefからSynthを生成して再生 ---
x = Synth("MyPercSynth");

/*
 * list-4_09
 */
(
// SynthDefを引数付きで再定義（同じ名前で上書き）
SynthDef.new("MyPercSynth",
  {
    // --- 引数の宣言（arg）---
    // busに加え、変更可能にしたいパラメータを引数として定義
    // 引数名 = デフォルト値 の形式で記述
    arg
    bus = 0,        // 出力バス
    freq = 110,     // 音源の周波数（Hz）
    numharm = 10,   // Blipのハーモニクス数
    attk = 0.01,    // エンベロープのアタックタイム（秒）
    rel = 1.0,      // エンベロープのリリースタイム（秒）
    amp = 0.3;      // 全体の振幅（音量）

    // --- ローカル変数の宣言（var）---
    var sig, env;

    // --- エンベロープ形状の定義 ---
    // 固定値ではなく、引数attkとrelを使用
    env = Env.perc(attk, rel);

    // --- エンベロープ信号の生成 ---
    // 全体の振幅調整用にlevelScaleにamp引数を指定
    env = EnvGen.kr(env, levelScale: amp, doneAction: Done.freeSelf);

    // --- 音源の生成 ---
    // 固定値ではなく、引数freqとnumharmを使用
    sig = Blip.ar(freq, numharm);

    // --- エンベロープ適用とステレオ化 ---
    // EnvGenのlevelScaleで振幅調整したので、ここでは単純に乗算
    sig = sig * env;
    sig = sig.dup(2);

    // --- 出力 ---
    Out.ar(bus, sig);
  }
).add; // 新しい定義をサーバーに登録
)

// --- 引数を指定してSynthを生成・再生 ---

// 1. 引数を指定せずに再生（デフォルト値が使用されます）
// "デフォルト値での再生:".postln;
x = Synth("MyPercSynth");

(
// 2. 周波数（freq）を 55Hz（A1）に変更して再生
// Synth() の第2引数に、変更したい引数とその値を配列で指定
// [引数名1(シンボル), 値1, 引数名2(シンボル), 値2, ...]
x = Synth("MyPercSynth", [\freq: 55]);
)

(
// 3. 周波数、ハーモニクス数、リリース、振幅を変更
"freq, numharm, rel, amp を変更:".postln;
x = Synth("MyPercSynth", [
  \freq: 330,     // E4
  \numharm: 25,   // より明るい音色に
  \rel: 1.5,      // 少し長めのリリース
  \amp: 0.5       // 少し大きめの音量
]);
)

(
// 4. アタックとリリースを長く変更
"アタックとリリースを長く変更:".postln;
x = Synth("MyPercSynth", [
  \attk: 0.4,   // ゆっくり立ち上がる
  \rel: 2.5,    // ゆっくり消える
  \freq: 440    // A4
]);
)
