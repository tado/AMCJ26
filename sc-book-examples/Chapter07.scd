// 第7章

/*
 * list-7_01
 */
(
// simple-sine
// シンプルなサイン波とパーカッシブなエンベロープを持つ楽器
SynthDef("simple-sine", {
  arg out = 0, freq = 440, sustain = 1.0, pan = 0.0, amp = 0.8;
  var sig, env;
  sig = SinOsc.ar(freq);
  env = EnvGen.kr(Env.perc(), levelScale: amp, timeScale: sustain, doneAction: 2);
  sig = sig * env;
  sig = Pan2.ar(sig, pan);
  Out.ar(out, sig);
}).add;

// RLPF-Saw
// ローパスフィルターのかかったノコギリ波の楽器
SynthDef("RLPF-Saw", {
  arg out = 0, freq = 440, sustain = 1.0, cutoff = 2000, rq = 0.3, pan = 0.0, amp = 0.8;
  var sig;
  sig = LFSaw.ar(
    freq,
    mul: EnvGen.kr(Env.perc(), levelScale: amp, timeScale: sustain, doneAction: 2)
  );
  sig = RLPF.ar(
    sig,
    LFNoise1.kr(1, cutoff / 2, cutoff).abs,
    rq
  );
  sig = Pan2.ar(sig, pan);
  4.do({ sig = AllpassN.ar(sig, 0.05, [0.05.rand, 0.05.rand], 4) });
  Out.ar(out, sig);
}).add;

// FmSynth
// FM変調シンセサイザー
SynthDef("FmSynth",
  {
    arg  out = 0, gate = 1, freq = 440, ratio = 1.0, index = 3,
    attk = 0.01, rel = 1.0, idxNoiseRate = 0.2,
    sustain = 1.0, pan = 0, amp = 0.5;
    var modFreq, modDepth, indexNoiseMod, mod, car, sig, env;
    modFreq = freq * ratio;
    indexNoiseMod = LFNoise1.kr(idxNoiseRate).abs;
    modDepth = modFreq * index * indexNoiseMod;
    mod = SinOsc.ar(modFreq, 0.0, modDepth);
    car = SinOsc.ar(freq + mod, 0);
    env = Env.asr(attk, 1.0, rel);
    env = EnvGen.kr(env, gate, amp, 0.0, sustain, doneAction:2);
    sig = Pan2.ar((car * env), pan);
    6.do({
      sig = AllpassN.ar(sig, 0.05, [0.05.rand, 0.05.rand], 4)
    });
    Out.ar(out, sig);
  }
).add;
)

/*
 * list-7_02
 */
(
// Cメジャーコードを構成する音をほぼ同時に鳴らす
Synth("simple-sine", [freq: 60.midicps, amp: 0.3]); // C4 (中央ド)
Synth("simple-sine", [freq: 64.midicps, amp: 0.3]); // E4
Synth("simple-sine", [freq: 67.midicps, amp: 0.3]); // G4
Synth("simple-sine", [freq: 72.midicps, amp: 0.3]); // C5 (1オクターブ上のド)
)

/*
 * list-7_03
 */
(
// 複数のSynth起動を関数fにまとめる
f = {
  Synth("simple-sine", [freq: 60.midicps]);
  Synth("simple-sine", [freq: 64.midicps]);
  Synth("simple-sine", [freq: 67.midicps]);
};

// 関数fからルーチンrを作成
r = Routine(f);
)

// ルーチンを再生 (関数fの内容が一度だけ実行される)
r.play;

// ルーチンを再度再生するには、まずリセットが必要
r.reset; // ルーチンの実行状態を先頭に戻す
r.play;  // 再度再生

/*
 * list-7_04
 */
(
// 音と音の間に1拍の待機を入れる関数
f = {
  "C4を再生".postln;
  Synth("simple-sine", [freq: 60.midicps, sustain: 0.8]); // C4
  1.0.yield; // 1拍 (デフォルトテンポで0.5秒) 待機し、この値を返す
  "E4を再生".postln;
  Synth("simple-sine", [freq: 64.midicps, sustain: 0.8]); // E4
  1.0.yield; // 1拍待機
  "G4を再生".postln;
  Synth("simple-sine", [freq: 67.midicps, sustain: 0.8]); // G4
  1.0.yield; // 1拍待機
  "ルーチン終了".postln;
};

r = Routine(f); // ルーチン作成
)

// ルーチンをリセットし、ステップごとに手動で実行（.next）
r.reset;    // 実行状態をリセット
r.next;     // 最初のSynthが鳴り、コンソールに"C4を再生"と表示。ルーチンは最初の .yield で停止し、1.0を返す
r.next;     // 1拍待った後、次のSynthが鳴り、"E4を再生"と表示。ルーチンは次の .yield で停止し、1.0を返す
r.next;     // 1拍待った後、最後のSynthが鳴り、"G4を再生"と表示。ルーチンは最後の .yield で停止し、1.0を返す
r.next;     // "ルーチン終了" がポストされ、ルーチンは完全に終了し、nilを返す

// ルーチンをリセットし、最後まで自動再生（.play）
// .yieldで指定された時間ごとにSynthが順番に鳴る
r.reset.play;

/*
 * list-7_05
 */
// n.doを用いて指定回数繰り返す
(
f = {
  // このブロック全体（3つのSynth起動と3回のyield）を4回繰り返す
  4.do({ |i| // ループカウンタ i（0から3まで変化）も利用可能
    ("Loop iteration: " ++ i).postln; // ループ回数を出力
    Synth("simple-sine", [freq: 60.midicps, sustain: 0.4]);
    0.5.yield; // 半拍待機
    Synth("simple-sine", [freq: 64.midicps, sustain: 0.4]);
    0.5.yield;
    Synth("simple-sine", [freq: 67.midicps, sustain: 0.4]);
    0.5.yield;
  });
  "done".postln;
};
r = Routine(f);
)

// ルーチンをリセットした上で再生
r.reset.play;

/*
 * list-7_06
 */
// くりかえしのネストと無限ループ
(
f = {
  // inf.do は無限に繰り返す（停止するには r.stop が必要）
  inf.do({
    Synth("simple-sine", [freq: 48.midicps, sustain: 0.8]); // 低いC
    1.0.yield;
    Synth("simple-sine", [freq: 60.midicps, sustain: 0.8]); // 1オクターブ上のC
    // 内側のループ：2回繰り返す
    2.do({
      Synth("simple-sine", [freq: 65.midicps, sustain: 0.2]); // F
      0.25.yield;
      Synth("simple-sine", [freq: 67.midicps, sustain: 0.2]); // G
      0.25.yield;
    });
  });
};
r = Routine(f);
)

// リセット+再生
r.reset.play;
// 停止
r.stop;

/*
 * list-7_07
 */
// 使用する楽器（SynthDef）を変更
(
f = {
  inf.do({
    // 楽器を RLPF-Saw に変更、amp調整
    Synth("RLPF-Saw", [freq: 48.midicps, sustain: 0.8, amp: 0.5]);
    1.0.yield;
    Synth("RLPF-Saw", [freq: 60.midicps, sustain: 0.8, amp: 0.5]);
    2.do({
      Synth("RLPF-Saw", [freq: 65.midicps, sustain: 0.2, amp: 0.5]);
      0.25.yield;
      Synth("RLPF-Saw", [freq: 67.midicps, sustain: 0.2, amp: 0.5]);
      0.25.yield;
    });
  });
};
r = Routine(f);
)

// 再生
r.reset.play;
// 停止
r.stop;

/*
 * list-7_08
 */
// loop を使った無限ループ（inf.do とほぼ同等）
(
f = {
  loop({ // loop はそれ自体が無限ループを意味する
    Synth("RLPF-Saw", [\freq, 60.midicps, \sustain, 0.5, \amp, 0.8]);
    0.4.yield;
    Synth("RLPF-Saw", [\freq, 64.midicps, \sustain, 0.15, \amp, 0.8]);
    0.1.yield;
    Synth("RLPF-Saw", [\freq, 65.midicps, \sustain, 0.15, \amp, 0.8]);
    0.1.yield;
    Synth("RLPF-Saw", [\freq, 72.midicps, \sustain, 0.15, \amp, 0.8]);
    0.2.yield;
  });
};
r = Routine(f);
)

// 再生
r.reset.play;
// 停止
r.stop;

/*
 * list-7_09
 */
(
r = Routine({
  loop({
    Synth("RLPF-Saw", [\freq: 55.midicps, \sustain: 1.0, \amp: 0.8]); // G
    Synth("RLPF-Saw", [\freq: 60.midicps, \sustain: 1.0, \amp: 0.8]); // C
    0.5.yield;
    Synth("RLPF-Saw", [\freq: 72.midicps, \sustain: 0.4, \amp: 0.8]); // 1オクターブ上のC
    // 配列 [64, 65, 67] (E, F, G) の音を3連符のように鳴らす
    [64, 65, 67].do({
      arg noteNumber, i; // noteNumber とインデックス i を受け取る
      Synth("RLPF-Saw", [\freq: noteNumber.midicps, \sustain: (1.0 / 3), \amp: 0.5]); // sustainを少し短く
      (0.5 / 3).yield; // 0.5拍を3等分した長さ待機
    });
  });
});
)

// 再生
r.reset.play;
// 停止
r.stop;

/*
 * list-7_10
 */
(
// 新しいTempoClockを作成し、テンポを 132 BPM に設定
// TempoClockのコンストラクタには BPS (Beats Per Second) を渡す
t = TempoClock(132/60); // 132 BPM = 2.2 BPS

r = Routine({
  loop({
    [60, 70, 75].do({ |noteNumber| // C, A#, D
      Synth("RLPF-Saw", [\freq, noteNumber.midicps, \sustain, 0.3, \amp, 0.8]);
      (1/2).yield; // 半拍 (TempoClock t の半拍)
    });
  });
});
)

// ルーチンrをTempoClock t上で再生
r.reset.play(t);


// 再生中にテンポを変更
t.tempo = 80/60;  // 80 BPM に変更（ゆっくりになる）
t.tempo = 160/60; // 160 BPM に変更（速くなる）
t.tempo = 240/60; // 240 BPM に変更（さらに速くなる）

r.stop; // 停止
t.clear; // 作成したクロックをクリア（不要になったら、関連するルーチンも止まる）

/*
 * list-7_11
 */
(
t = TempoClock(132/60); // テンポクロック（132BPM）

// ベースライン風ルーチン（環境変数~r0に格納）
~r0 = Routine({
  loop({
    [60, 63, 65, 67].do({ |n| // C, D#, F, G
      Synth("RLPF-Saw", [\freq, n.midicps, \sustain, 0.4, \amp, 0.5]);
      (1/2).yield; // 半拍
    });
  });
});

// 上声部風ルーチン（環境変数~r1に格納）
~r1 = Routine({
  loop({
    [70, 72, 75, 77].do({ |n| // A#, C, D#, F (1オクターブ上)
      Synth("simple-sine", [\freq, n.midicps, \sustain, 0.2, \amp, 0.5]);
      (1/4).yield; // 1/4拍
    });
  });
});
)

// --- 同時再生の実験 ---

//（1）通常の連続実行（ほぼ同時に始まるが、厳密な同期ではない）
(
~r0.reset.play(t);
~r1.reset.play(t);
)
//停止
~r0.stop; ~r1.stop;

//（2）quantを使って厳密に同期（次の4拍周期の頭から同時に開始）
// 1行ずつ順番に実行
~r0.reset.play(t, quant: 4);
~r1.reset.play(t, quant: 4);
//停止
~r0.stop; ~r1.stop;

//（3）quantで開始タイミングをずらす
// ~r0は次の4拍周期の頭から、~r1はそこから1拍遅れて開始
// 1行ずつ順番に実行
~r0.reset.play(t, quant: [4, 0]);
~r1.reset.play(t, quant: [4, 1]);
//停止
~r0.stop; ~r1.stop;

//（4）複数のルーチンインスタンスを異なるタイミングで重ねる
// 1行ずつ順番に実行
~r0.reset.play(t, quant: [4, 0]); // 0拍目
~r0.reset.play(t, quant: [4, 1]); // 1拍目から同じ~r0を重ねる（カノン風）
~r1.reset.play(t, quant: [4, 0]); // 0拍目
~r1.reset.play(t, quant: [4, 1.5]); // 1.5拍目から同じ~r1を重ねる
//停止
~r0.stop; ~r1.stop;

// クロックをクリアすると関連するルーチンも止まる
t.clear;

/*
 * list-7_12
 */
Pseq([1, 2, 3], 2).asStream.all; // -> [ 1, 2, 3, 1, 2, 3 ]

/*
 * list-7_13
 */
Prand([10, 20, 30], 5).asStream.all; // 例：[ 20, 10, 20, 30, 10 ]

/*
 * list-7_14
 */
Pxrand([0, 1], 8).asStream.all; // 例：[ 0, 1, 0, 1, 0, 1, 0, 1 ]

/*
 * list-7_15
 */
Pwhite(0.0, 0.5, 4).asStream.all; // 例：[ 0.123, 0.456, 0.012, 0.389 ]

/*
 * list-7_16
 */
Pexprand(0.1, 1.0, 4).asStream.all; // 例：[ 0.15, 0.22, 0.11, 0.35 ]

/*
 * list-7_17
 */
Pseries(2, 3, 5).asStream.all; // -> [ 2, 5, 8, 11, 14 ]

/*
 * list-7_18
 */
Pgeom(3, 2, 5).asStream.all; // -> [ 3, 6, 12, 24, 48 ]

/*
 * list-7_19
 */
Pbrown(0, 10, 1, 10).asStream.all; // 例：[ 5, 6, 5, 4, 5, 6, 7, 6, 5, 4 ] （開始値は中間付近）

/*
 * list-7_20
 */
Pgbrown(0, 5, 1, 15).asStream.all; // 例：[ 2, 3, 4, 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5, 4 ]

/*
 * list-7_21
 */
Pdup(3, Pseq([10, 20], 1)).asStream.all; // -> [ 10, 10, 10, 20, 20, 20 ]
Pdup(Pseq([2, 1], inf), Pseq([5, 8], inf)).asStream.nextN(5); // -> [ 5, 5, 8, 5, 5 ]

/*
 * list-7_22
 */
Pwrand([0, 1, 2], [0.1, 0.7, 0.2].normalizeSum, 10).asStream.all; // 1が最も出やすい

/*
 * list-7_23
 */
(
//パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  \dur, 0.25, // 持続時間（必須）
  \amp, 0.8, // 音量
  \midinote, Pseq([60, 64, 65, 67], inf) //C, E, F, G
).play;
)

// 停止
p.stop;


/*
 * list-7_24
 */
(
// スケールを指定（メジャースケール）
~scale = Scale.major;
//パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  \dur, 0.25, // 持続時間（必須）
  \amp, 0.8, // 音量
  \scale, ~scale, // スケールの設定
  // スケールの度数で音程を指定
  // 順番に音程をピックアップしてくりかえす
  \degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7], inf)
).play;
)

// 停止
p.stop;


/*
 * list-7_25
 */
(
// スケールを指定（平調子）
~scale = Scale.hirajoshi;
// パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  \dur, 0.25, // 持続時間（必須）
  \amp, 0.8, // 音量
  \scale, ~scale, // スケールの設定
  // スケールの度数で音程を指定
  // ランダムに音程をピックアップ
  \degree, Prand([0, 1, 2, 3, 4, 5, 6, 7], inf)
).play;
)

// 停止
p.stop;


/*
 * list-7_26
 */
(
// スケールを指定（平調子）
~scale = Scale.hirajoshi;
// パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  \dur, 0.25, // 持続時間（必須）
  \amp, 0.8, // 音量
  \scale, ~scale, // スケールの設定
  // スケールの度数で音程を指定
  // 音程が重ならないようにランダムにピックアップ
  \degree, Pxrand([0, 1, 2, 3, 4, 5, 6, 7], inf)
).play;
)

// 停止
p.stop;

/*
 * list-7_27
 */
(
// スケールを指定
~scale = Scale.ritusen; // 律旋法
// パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  \dur, 0.25, // 持続時間（必須）
  \amp, 0.8, // 音量
  \scale, ~scale, // スケールの設定
  //オクターブをランダムに設定（3〜5）
  \octave, Prand([3, 4, 5], inf), // オクターブ
  // ランダムに音程をピックアップ
  \degree, Pxrand([0, 1, 2, 3, 4, 5, 6, 7], inf)
).play;
)

// 停止
p.stop;

/*
 * list-7_28
 */
(
// スケールを指定
~scale = Scale.ritusen; // 律旋法
// パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  // リズムもランダムに
  \dur, Prand([1/8, 1/4, 1/2], inf),
  \amp, 0.8, // 音量
  // スケールの設定
  \scale, ~scale,
  //オクターブをランダムに設定（3〜5）
  \octave, Prand([3, 4, 5], inf), // オクターブ
  // ランダムに音程をピックアップ
  \degree, Pxrand([0, 1, 2, 3, 4, 5, 6, 7], inf)
).play;
)

// 停止
p.stop;

/*
 * list-7_29
 */
(
// パターンを再生
p = Pbind(
  \instrument, "RLPF-Saw", // 楽器名
  // リズムもランダムに
  \root,
  Pdup(
    4, Pxrand([[0, 0], [0, 5], [0, 7], [0, 12]], inf)
  ),
  \dur, PstepNadd(
    Pseq([1, 0, 0, 1], 2),
    Pshuf([1, 1, 2, 1], 2)
  ).loop * (1/8),
  // 定位もランダムに選択
  \pan, Prand([-0.6, -0.2, 0, 0.2, 0.6], inf),
  // ローパスフィルターのカットオフ周波数もランダムに
  \cutoff, Pexprand(800, 15000, inf),
  \sustain, Pexprand(0.2, 1.0, inf),
  \amp, 0.8, // 音量
  // スケールの設定
  \scale, Pdup(
    32,
    Pxrand([Scale.minor, Scale.yu, Scale.hirajoshi, Scale.ritusen, Scale.minorPentatonic], inf)
  ),
  //オクターブをランダムに設定（3〜5）
  \octave, Prand([3, 4, 5], inf), // オクターブ
  // ランダムに音程をピックアップ
  \degree, Pxrand([0, 1, 2, 3, 4, 5, 6, 7], inf)
).play;
)

// 停止
p.stop;
