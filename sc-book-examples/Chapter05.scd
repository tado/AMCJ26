// 第5章

/*
 * list-5_01
 */
(
SynthDef("AdditiveSynth_Manual",
  {
    // --- 引数の宣言 ---
    arg
    out = 0,       // 出力バス番号
    freq = 440,    // 基本周波数（Hz）
    attk = 0.01,   // アンプ・エンベロープのアタックタイム（秒）
    rel = 1.0,     // アンプ・エンベロープのリリースタイム（秒）
    amp = 0.5,     // 全体の最終的な振幅（ゲイン）
    gate = 1.0;    // エンベロープのゲート制御

    // --- ローカル変数の宣言 ---
    var sig, env;

    // --- サイン波の生成と加算 ---
    // 基音（第1倍音）: freq
    sig = SinOsc.ar(freq, mul: (1.0 / 4.0)); // 各倍音の振幅を均等に配分（仮）
    // 第2倍音 : freq * 2
    sig = sig + SinOsc.ar(freq * 2, mul: (1.0 / 4.0));
    // 第3倍音 : freq * 3
    sig = sig + SinOsc.ar(freq * 3, mul: (1.0 / 4.0));
    // 第4倍音 : freq * 4
    sig = sig + SinOsc.ar(freq * 4, mul: (1.0 / 4.0));

    // --- ステレオ化 ---
    // モノラル信号を左右両チャンネルに複製
    sig = sig.dup(2);

    // --- エンベロープの作成（Env.asr）---
    // Env.asr(attackTime, sustainLevel(通常1.0), releaseTime)
    // gate オンでアタックしレベル1.0に達すると即座にリリースへ移行するか、
    // gate オフでリリースへ移行するエンベロープ。
    env = Env.asr(attk, 1.0, rel); // sustainLevelは1.0固定
    env = EnvGen.kr(env, gate, doneAction: 2); // doneAction:2で自動解放

    // --- エンベロープ適用と最終的な音量調整 ---
    // 合成信号にエンベロープと最終ゲインを適用
    sig = sig * env * amp;

    // --- 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// --- 再生 ---
// 基本周波数110Hzで再生
x = Synth("AdditiveSynth_Manual", [\freq: 110, \amp: 0.3, \rel: 2.0]);
// 基本周波数220Hzで再生
y = Synth("AdditiveSynth_Manual", [\freq: 220, \amp: 0.3, \rel: 2.0]);
// 基本周波数330Hzで再生
z = Synth("AdditiveSynth_Manual", [\freq: 330, \amp: 0.3, \rel: 2.0]);

// --- 停止 ---
// gate を 0 にするとリリース開始
x.set(\gate, 0);
y.set(\gate, 0);
z.set(\gate, 0);

/*
 * list-5_02
 */
(
SynthDef("AdditiveSynth_Loop",
  {
    // --- 引数の宣言 ---
    arg
    out = 0,
    freq = 440,
    attk = 0.01,
    rel = 1.0,
    amp = 0.5,
    gate = 1.0;

    // --- ローカル変数の宣言 ---
    var sig = 0, env;

    // --- ループによるサイン波の生成と加算 ---
    4.do {
      arg i;
      var currentFreq, currentAmp;
      // 第 (i + 1) 倍音の周波数
      currentFreq = freq * (i + 1);
      // 各倍音の振幅: 指数関数的に減衰させる (1, 1/2, 1/4, 1/8...)
      // 2.pow(i) は 2のi乗を計算
      currentAmp = 1.0 / (2.pow(i));
      // SinOsc を生成し、sig に加算
      sig = sig + SinOsc.ar(currentFreq, mul: currentAmp);
    }; // ループ終了

    // --- ステレオ化 ---
    sig = sig.dup(2);

    // --- エンベロープの作成（Env.asr）---
    env = Env.asr(attk, 1.0, rel);
    env = EnvGen.kr(env, gate, doneAction: 2);

    // --- エンベロープ適用と最終的な音量調整 ---
    sig = sig * env * amp;

    // --- 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// --- 再生 ---
x = Synth("AdditiveSynth_Loop", [\freq: 220, \amp: 0.1, \rel: 3.0]);
y = Synth("AdditiveSynth_Loop", [\freq: 110, \amp: 0.1, \rel: 3.0]);

// --- 停止 ---
x.set(\gate, 0);
y.set(\gate, 0);

/*
 * list-5_03
 */
(
SynthDef("AdditiveSynth_Klang",
  {
    // --- 引数の宣言 ---
    arg
    out = 0,
    attk = 0.01,
    rel = 1.0,
    amp = 1.0,
    gate = 1.0;

    // --- ローカル変数の宣言 ---
    var num = 40, sig = 0, env, freqs, amps, phases;

    // --- Klangのためのパラメータ配列生成 ---
    // 周波数：50Hzから15000Hzの間で指数分布に従うランダム値をnum個生成しソート
    freqs = Array.exprand(num, 50, 15000).sort;
    // 振幅：0.001から0.05の間で指数分布に従うランダム値をnum個生成し逆順ソート
    amps = Array.exprand(num, 0.001, 0.05).sort.reverse; // 低域強調傾向
    // 位相：0から2πの間で一様分布に従うランダム値をnum個生成
    phases = Array.rand(num, 0, 2pi);

    // --- Klang UGenによる合成 ---
    // Klang.ar( `[ frequencies, amplitudes, phases ]` )
    // バッククォート(`)で囲み、配列をUGenグラフ内に直接埋め込む
    sig = Klang.ar(`[freqs, amps, phases]); // 多数のサイン波を効率的に生成・ミックス

    // --- ステレオ化 ---
    sig = sig.dup(2);

    // --- エンベロープの作成（Env.asr）---
    env = Env.asr(attk, 1.0, rel);
    env = EnvGen.kr(env, gate, doneAction: 2);

    // --- エンベロープ適用と最終的な音量調整 ---
    sig = sig * env * amp;

    // --- 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// --- 再生 ---
// ランダムな倍音構成による複雑なサウンド
x = Synth("AdditiveSynth_Klang", [\attk: 2.0, \rel: 5.0]);

// 再度実行 (異なる響きになる)
y = Synth("AdditiveSynth_Klang", [\attk: 2.0, \rel: 5.0]);

// --- 停止 ---
x.set(\gate, 0);
y.set(\gate, 0);

/*
 * list-5_04
 */
(
SynthDef("AdditiveSynth_DynKlang",
  {
    // --- 引数の宣言 ---
    arg
    out = 0,
    attk = 0.01,
    rel = 1.0,
    amp = 1.0,
    gate = 1.0;

    // --- ローカル変数の宣言 ---
    var sig, env, freqs, amps, phases;

    // --- DynKlangのための静的なパラメータ配列生成 ---
    freqs = Array.exprand(40, 50, 8000).sort;
    amps = Array.exprand(40, 0.005, 0.2).sort.reverse;
    phases = Array.rand(40, 0, 2pi);

    // 周波数と振幅の配列にノイズ信号を乗算し、動的に変化させる
    sig = DynKlang.ar(`[
      freqs * LFNoise1.kr(0.02 ! 40).exprange(0.25, 2),
      amps * LFNoise1.kr(1 ! 40).exprange(0.02, 1),
      phases
    ]);

    // --- ステレオ化 ---
    sig = sig.dup(2);

    // --- エンベロープの作成（Env.asr）---
    env = Env.asr(attk, 1.0, rel);
    env = EnvGen.kr(env, gate, doneAction: 2);

    // --- エンベロープ適用と最終的な音量調整 ---
    sig = sig * env * amp;

    // --- 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// --- 再生 ---
// 時間とともにテクスチャが変化するサウンド
x = Synth("AdditiveSynth_DynKlang", [\attk: 8.0, \rel: 10.0]);

// 再度再生（ランダムな値なので毎回違う響きになる）
y = Synth("AdditiveSynth_DynKlang", [\attk: 2.0, \rel: 5.0]);

// --- 停止 ---
x.set(\gate, 0);
y.set(\gate, 0);

/*
 * list-5_05
 */
(
// AM変調の周波数の変化を観察
f = {
  var sig, mod, modHz;
  // モジュレーターの周波数: 10秒かけて1から3000まで変化させる
  modHz = XLine.kr(1, 3000, 10);
  // 変化する周波数でモジュレーターを作成
  // 振幅は0から1の範囲で作成する（古典的AM）
  mod = SinOsc.ar(modHz).range(0, 1);
  // キャリアのSin波を6000Hzで作成
  // モジュレーターの信号を振幅に乗算（AM変調）
  sig = SinOsc.ar(6000, mul: mod);
  // ステレオで出力
  sig = sig.dup(2);
}.freqscope;
)

/*
 * list-5_06
 */
(
SynthDef("AmSynth_Perc",
  {
    // --- 引数の宣言 ---
    arg
    out = 0,
    gate = 1,      // Env.perc をトリガー（通常1で起動しすぐ完了）
    freq = 440,    // キャリア周波数
    modFreq = 200, // モジュレーション周波数
    amp = 0.8;     // 全体の振幅

    // --- ローカル変数の宣言 ---
    var sig, env, mod;

    // --- モジュレータ信号の生成とスケーリング ---
    // モジュレータのサイン波
    mod = SinOsc.ar(modFreq);
    // .range(0, 1)：出力を0~1の範囲にマッピング（古典的AM）
    mod = mod.range(0, 1);

    // --- キャリア信号の生成とAM変調 ---
    // キャリア: freq ヘルツのサイン波
    // mul: mod で振幅を変調
    sig = SinOsc.ar(freq, mul: mod);

    // --- ステレオ化 ---
    sig = sig.dup(2);

    // --- エンベロープの作成（Env.perc）---
    // パーカッシブなエンベロープ（短いアタック、減衰）
    env = Env.perc();
    env = EnvGen.kr(env, gate, doneAction: 2);

    // --- エンベロープ適用と最終的な音量調整 ---
    sig = sig * env * amp;

    // --- 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// --- 再生 ---
// 様々なキャリア周波数（freq）とモジュレーション周波数（modFreq）の組み合わせを試す
// キャリア周波数と「和」「差」の側波帯が生成されることを意識する
Synth("AmSynth_Perc", [\freq: 220, \modFreq: 30]);
Synth("AmSynth_Perc", [\freq: 220, \modFreq: 800]);
Synth("AmSynth_Perc", [\freq: 880, \modFreq: 20]);
Synth("AmSynth_Perc", [\freq: 880, \modFreq: 100]);
Synth("AmSynth_Perc", [\freq: 880, \modFreq: 400]);

/*
 * list-5_07
 */
(
// RM変調の周波数の変化を観察
f = {
  var sig, mod, modHz;
  // モジュレーターの周波数：10秒かけて1から3000まで変化させる
  modHz = XLine.kr(1, 3000, 10);
  // 変化する周波数でモジュレーターを作成
  // 振幅は補正せず-1から1の範囲で作成する（RM）
  mod = SinOsc.ar(modHz);
  // キャリアのSin波を6000Hzで作成
  // モジュレーターの信号を振幅に乗算（RM変調）
  sig = SinOsc.ar(6000, mul: mod);
  // ステレオで出力
  sig = sig.dup(2);
}.freqscope;
)

/*
 * list-5_08
 */
(
SynthDef("RmSynth_Perc",
  {
    // --- 引数の宣言 ---
    arg
    out = 0,
    gate = 1,      // Env.percをトリガー
    freq = 440,    // キャリア周波数
    modFreq = 200, // モジュレーション周波数
    amp = 0.8;     // 全体の振幅

    // --- ローカル変数の宣言 ---
    var sig, env, mod;

    // --- モジュレータ信号の生成 ---
    // モジュレータmodFreqのサイン波（-1 ~ 1 の出力）
    mod = SinOsc.ar(modFreq);
    // リング変調なので、そのまま使う（または深さを調整する係数を掛ける）

    // --- キャリア信号の生成とRM変調 ---
    // mul: mod で振幅を変調（RM）
    sig = SinOsc.ar(freq, mul: mod);

    // --- ステレオ化 ---
    sig = sig.dup(2);

    // --- エンベロープの作成（Env.perc）---
    env = Env.perc();
    env = EnvGen.kr(env, gate, doneAction: 2);

    // --- エンベロープ適用と最終的な音量調整 ---
    sig = sig * env * amp;

    // --- 出力 ---
    Out.ar(out, sig);
  }
).add;
)

// --- 再生 ---
// 様々なキャリア・モジュレータ周波数の組み合わせを試す
// キャリア周波数の「和」と「差」の側波帯のみが聞こえることを意識する
Synth("RmSynth_Perc", [\freq: 220, \modFreq: 30]);
Synth("RmSynth_Perc", [\freq: 220, \modFreq: 800]);
Synth("RmSynth_Perc", [\freq: 880, \modFreq: 20]);
Synth("RmSynth_Perc", [\freq: 880, \modFreq: 100]);
Synth("RmSynth_Perc", [\freq: 880, \modFreq: 400]);

/*
 * list-5_09
 */
(
// FM変調の周波数を観察
{
  var sig, mod, modHz;
  // モジュレータ周波数(modHz)を10秒かけて1Hzから1000Hzまで指数的に変化
  modHz = XLine.kr(1, 1000, 10);
  // モジュレータ(mod): 周波数modHz、振幅500のサイン波
  // この mul: 500 が周波数偏移の最大値（変調深度）を決める
  mod = SinOsc.ar(modHz, mul: 500);
  // キャリア(sig): 基本周波数6000Hzのサイン波
  // 周波数入力にモジュレータ信号(mod)を加算 => FM変調
  sig = SinOsc.ar(6000 + mod);
  // 音量調整とステレオ化
  sig = (sig * 0.2).dup(2);
}.freqscope
)

/*
 * list-5_10
 */
(
SynthDef("simpleFM",
  {
    // 引数の宣言
    arg out = 0, modFreq = 440, carFreq = 440, index = 3, dur = 1.0, amp = 0.5;
    // 変数の宣言
    var mod, car, env, sig;

    // エンベロープの生成（パーカッシブ）
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    // モジュレーター: 周波数 modFreq, 振幅(周波数偏移)は index * modFreq とする
    //（indexは単位なしの係数、偏移はHz）
    mod = SinOsc.ar(modFreq, 0, index * modFreq);
    // キャリア: 周波数carFreqをmodで変調
    car = SinOsc.ar(carFreq + mod, 0);
    // エンベロープと最終的なアンプを適用
    sig = car * env * amp;
    // ステレオ化して出力
    Out.ar(out, sig.dup(2));
}).add;
)

// 演奏
Synth("simpleFM", [\modFreq: 220, \index: 5, \dur: 2, \amp: 0.3]);
Synth("simpleFM", [\modFreq: 100, \index: 15, \dur: 3, \amp: 0.2]);

/*
 * list-5_11
 */
(
SynthDef("FmSynth",
  {
    // 引数の宣言
    arg
    out = 0,
    gate = 1,
    carFreq = 440,    // キャリアの基本周波数（Hz）- 音の高さの基準
    ratio = 1.0,      // C:M比（モジュレータ周波数 / キャリア周波数）
    index = 3,        // モジュレーションインデックス - 変調の基本的な激しさ
    attk = 0.01,      // エンベロープのアタックタイム（秒）
    rel = 1.0,        // リリースタイム（Env.asr用）
    idxNoiseRate = 0.2, // インデックスを揺らすノイズの速さ（Hz）
    room = 50,        // リバーブルームサイズ
    revtime = 5.0,    // リバーブタイム
    amp = 0.5;        // 全体の最終的な音量

    // ローカル変数の宣言
    var modFreq, modDepth, indexNoiseMod, mod, car, sig, env;

    // モジュレータ周波数
    modFreq = carFreq * ratio;

    // モジュレータ（変調をかける音）の生成
    // インデックス自体をノイズで揺らす（0からindexの範囲で変動）
    indexNoiseMod = LFNoise1.kr(idxNoiseRate).abs;
    // 周波数偏移（Hz）= モジュレータ周波数 * インデックス * ノイズ（0~1）
    modDepth = modFreq * index * indexNoiseMod;
    mod = SinOsc.ar(modFreq, 0.0, modDepth);

    // キャリア（変調される音）の生成とFM変調
    car = SinOsc.ar(carFreq + mod, 0);

    // エンベロープ（音量変化）の作成（Env.asr）
    env = Env.asr(attk, 0.2, rel);
    env = EnvGen.kr(env, gate, doneAction:2);

    // エンベロープの適用とステレオ化
    sig = (car * env).dup(2);

    // エフェクトの適用（リバーブ）と最終アンプ調整
    sig = GVerb.ar(sig, room, revtime) * amp;

    // 出力
    Out.ar(out, sig);
  }
).add;
)

// 再生
x = Synth("FmSynth", [\carFreq: 220, \ratio: 1.414, \index:  20, \attk: 0.01, \rel: 4.0, \amp: 0.2]); // ベル風
y = Synth("FmSynth", [\carFreq: 55, \ratio: 0.5, \index:  40, \attk: 0.001, \rel: 4.0, \amp: 0.2]); // パーカッシブな音

// 停止
x.set(\gate, 0);
y.set(\gate, 0);

/*
 * list-5_12
 */
(
SynthDef("noiseLPF",
  // ホワイトノイズにローパスフィルター(RLPF)を適用するデモ
  {
    // 引数の宣言
    arg out = 0, cutoff = 2000, rq = 1.0, amp = 0.1;
    var sig;
    // ホワイトノイズの生成
    sig = WhiteNoise.ar(); // ホワイトノイズの振幅はRLPF内で調整されるため、ここでは1.0で生成
    // レゾナンス付きローパスフィルター（RLPF）を適用
    // RLPF.ar(input, cutoffFreq, rq, mul, add)
    // rqは値が小さいほどレゾナンスが高くなる （通常 0 < rq）
    sig = RLPF.ar(sig, cutoff, rq, amp).dup(2); // RLPF内でampを適用し、その後ステレオ化
    Out.ar(out, sig);
}).add;
)

// 再生: ホワイトノイズにローパスフィルターをかける
// カットオフ周波数とレソナンス（rq）を変化させて音色の変化を観察
x = Synth("noiseLPF", [\cutoff: 800, \rq: 0.5, \amp: 0.1]); // 低めのカットオフ、ややレゾナンスあり
y = Synth("noiseLPF", [\cutoff: 4000, \rq: 0.1, \amp: 0.05]); // 高めのカットオフ、強いレゾナンス（音量注意）

// 別の設定を試す（Synth実行中にパラメータ変更）
x.set(\cutoff, 200); x.set(\rq, 0.05); // さらに低いカットオフ
y.set(\cutoff, 10000); y.set(\rq, 1.0);// 高いカットオフ

// 終わったら解放
x.free; y.free;

/*
 * list-5_13
 */
(
SynthDef("noiseHPF",
  // ホワイトノイズにハイパスフィルター（RHPF）を適用するデモ
  {
    // 引数の宣言
    arg out = 0, cutoff = 2000, rq = 1.0, amp = 0.1;
    var sig;
    // ホワイトノイズの生成
    sig = WhiteNoise.ar();
    // レゾナンス付きハイパスフィルター（RHPF）を適用
    sig = RHPF.ar(sig, cutoff, rq, amp).dup(2);
    Out.ar(out, sig);
}).add;
)

// 再生：ホワイトノイズにハイパスフィルターをかける
x = Synth("noiseHPF", [\cutoff: 5000, \rq: 0.8, \amp: 0.1]); // 高めのカットオフ、シャープな音
y = Synth("noiseHPF", [\cutoff: 1000, \rq: 0.1, \amp: 0.05]); // 低めのカットオフ、強いレゾナンス

// 別の設定を試す
x.set(\cutoff, 10000); x.set(\rq, 0.05); // 非常に高いカットオフ
y.set(\cutoff, 200); y.set(\rq, 1.0);// 低いカットオフ

// 終わったら解放
x.free; y.free;

/*
 * list-5_14
 */
(
SynthDef("noiseBPF",
  // ホワイトノイズにバンドパスフィルター（BPF）を適用するデモ
  {
    // 引数の宣言
    arg out = 0, cutoff = 2000, rq = 0.1, amp = 0.2; // BPFはrqが小さいほど狭帯域になる
    var sig;
    // ホワイトノイズの生成
    sig = WhiteNoise.ar();
    // バンドパスフィルター(BPF)を適用
    // BPF.ar(input, freq, rq, mul, add)
    // rq は値が小さいほど通過帯域が狭くなる（Qの逆数）
    sig = BPF.ar(sig, cutoff, rq, amp).dup(2);
    Out.ar(out, sig);
}).add;
)

// 再生：ホワイトノイズにバンドパスフィルターをかける
x = Synth("noiseBPF", [\cutoff: 800, \rq: 0.05, \amp: 0.3]); // 低めの中心周波数、狭帯域（特定の音程感が聞こえる）
y = Synth("noiseBPF", [\cutoff: 4000, \rq: 0.5, \amp: 0.1]); // 高めの中心周波数、広帯域（ノイズ感が残る）

// 別の設定を試す
x.set(\cutoff, 8000); x.set(\rq, 0.01); // 非常に狭い帯域（より強い音程感）
y.set(\cutoff, 2000); y.set(\rq, 1.0); // 非常に広い帯域（もとのノイズに近い）

// 終わったら解放
x.free; y.free;

/*
 * list-5_15
 */
(
SynthDef("simpleSub",
  // 減算合成のシンプルなシンセサイザー：ノコギリ波 + LPF + エンベロープ
  {
    // 引数の宣言
    arg out = 0, freq = 440, cutoff = 880, rq = 0.5, amp = 0.2, dur = 1.0;
    var sig, env;

    // 基本波形（ノコギリ波 Saw）の生成：豊かな倍音を含む
    // モノラルで生成し、フィルター後にステレオ化
    sig = Saw.ar(freq);

    // エンベロープの生成（パーカッシブ）
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);

    // ローパスフィルターの適用
    sig = RLPF.ar(sig, cutoff, rq);

    // エンベロープと最終アンプを適用し、ステレオ化
    sig = sig.dup(2) * env * amp;

    // 出力
    Out.ar(out, sig);
}).add;
)

// 減算合成のシンプルなシンセサイザーを再生
// 暗く柔らかい音
Synth("simpleSub", [\freq: 110, \cutoff: 400, \rq: 0.8, \amp: 0.3, \dur: 1.5]);
// 明るくレゾナンスが効いた音
Synth("simpleSub", [\freq: 220, \cutoff: 2000, \rq: 0.2, \amp: 0.15, \dur: 0.5]);
// ベースのような太い音
Synth("simpleSub", [\freq: 55, \cutoff: 100, \rq: 0.5, \amp: 0.4, \dur: 3.0]);

/*
 * list-5_16
 */
(
SynthDef("pulseSub",
  // 減算合成によるリズミックなテクスチャ生成の例
  {
    // 引数の宣言
    arg out = 0, speed = 6, rq = 0.2, amp = 0.1; // rqとampのデフォルト値を調整
    // ローカル変数の宣言
    var freq, sig, env, cutoff;

    // カットオフ周波数を動的に変化させる信号
    // VarSaw.kr：ノコギリ波に似ているが形状を変えられるオシレーター、LFOとして使用
    // speed（Hz）で周期的に変化し、.exprangeで80Hzから8000Hzの範囲に
    // これによりフィルターのカットオフが複雑に動き、音色を時間変化
    cutoff = VarSaw.kr(speed, width: 0.1).exprange(80, 8000);

    // パルス波の基本周波数を決定する信号
    // LFNoise0.kr：ランダムな値をspeed（Hz）のレートで生成するノイズジェネレータ。
    // .range(10, 60)：出力範囲を10から60に設定
    // .midicps：MIDIノートナンバーを対応する周波数（Hz）に変換
    // リズミカルなクリック列のような効果
    freq = LFNoise0.kr(speed).range(10, 60).midicps;

    // パルス波（Pulse）の生成
    // freq * [0.99, 1.01]：左右チャンネルで周波数をわずかにずらす
    sig = Pulse.ar(freq * [0.99, 1.01]);

    // ローパスフィルターの適用：動的に変化するcutoffでフィルター
    sig = RLPF.ar(sig, cutoff, rq);

    // 最終的な音量調整
    sig = sig * amp;

    // 出力
    Out.ar(out, sig);
}).add;
)

// 再生
x = Synth("pulseSub", [\speed: 2, \rq: 0.3, \amp: 0.15]); // ゆっくりした変化
y = Synth("pulseSub", [\speed: 10, \rq: 0.05, \amp: 0.08]); // 速い変化、強いレゾナンス

// 停止
x.free;
y.free;

/*
 * list-5_17
 */
(
SynthDef("supersaw",
  {
    // --- 引数の宣言 ---
    arg out = 0,       // 出力バス
    attk = 0.01,   // アンプエンベロープのアタックタイム（秒）
    decay = 0.3,   // アンプエンベロープのディケイタイム（秒）
    sustain = 0.5, // アンプエンベロープのサステインレベル（0.0 ~ 1.0）
    rel = 1.0,     // アンプエンベロープのリリースタイム（秒）
    gate = 1,      // エンベロープゲート（1で開き、0で閉じる）
    rate = 0.2,    // LFOの周波数（Hz）
    freq = 440,    // 基本周波数（Hz）
    voice = 0.2,   // Saw波のデチューン量
    semitone = 12, // 第2オシレータ（Tri）のピッチシフト量
    resonance = 0.5, // Moogフィルターのレゾナンス
    lfo = 1,       // LFOによるフィルター変調の深さ
    pitch1 = 1,    // LFO変調の中心周波数への係数
    amp = 0.5;     // 最終的な出力ゲイン

    // --- ローカル変数の宣言 ---
    var env, basefreq, basefreq2, lfof1, lfof2, sig;

    // --- エンベロープ ---
    // ADSRエンベロープを生成し、全体の音量を制御
    env = EnvGen.ar(Env.adsr(attk, decay, sustain, rel), gate, doneAction: 2);

    // --- オシレーター周波数計算 ---
    // 基本周波数
    basefreq = freq;
    // 第2オシレータの周波数 (基本周波数 + semitone)
    basefreq2 = basefreq * (2 ** (semitone / 12));

    // --- LFOによるフィルターカットオフ周波数計算 ---
    // LFO変調の中心周波数付近を計算（上限22kHz）
    lfof1 = min(basefreq * 10 * pitch1, 22000);
    // LFO変調の最大周波数を計算（上限22kHz）
    lfof2 = min(lfof1 * (lfo + 1), 22000);

    // --- 音源（オシレーター）---
    // 複数のデチューンされたノコギリ波（Saw）と三角波（LFTri）をミックス
    sig = (
      // 3つのSawを生成しミックス（SuperSaw風サウンド）
      0.5 * Mix.arFill(3, { arg i;
        // ノコギリ波を生成
        // 周波数をわずかにずらす（i=0,1,2に対して、voiceで広がりを調整）
        Saw.ar(basefreq * ((i - 1) * voice / 50 + 1));
      })
      // 第2オシレータとして三角波を追加（semitoneでピッチ調整）
      + (0.5 * LFTri.ar(basefreq2, voice))
    );

    // --- フィルター ---
    // Moogラダーフィルターエミュレーション（MoogFF）
    // MoogFF.ar(input, freq, gain=resonance*4, reset=0)
    sig = MoogFF.ar(
      sig, // 入力信号
      // LFTri LFOでフィルターカットオフ周波数を変調
      LFTri.ar(basefreq / 64 * rate, 0.5).range(lfof1, lfof2),
      resonance * 4 // レゾナンス（MoogFFでは gain 引数で制御、0-4程度）
    );

    // --- ポストプロセッシング ---
    // ソフトクリッピング（歪み）を追加
    sig = (sig.tanh * 2);
    // ステレオ化
    sig = sig.dup(2);
    // エンベロープと最終アンプを適用
    sig = sig * env * amp;
    // リバーブを追加
    sig = GVerb.ar(sig, 50, 1); // ルームサイズ50、リバーブタイム1秒

    // --- 出力 ---
    Out.ar(out, sig); // 出力バス引数 'out'を使用
}).add
)

// --- 再生例 ---

// 例1：和音のように鳴らす
x = Synth("supersaw", [\freq: 440, \resonance: 0.6, \amp: 0.2]);
y = Synth("supersaw", [\freq: 440 / (3/2), \resonance: 0.6, \amp: 0.2]); // 完全5度下
z = Synth("supersaw", [\freq: 440 / (3/2 ** 2), \resonance: 0.6, \amp: 0.2]); // さらに完全5度下

// 停止（gateを0にするとリリース開始）
x.set(\gate, 0);
y.set(\gate, 0);
z.set(\gate, 0);


// 例2：長いアタックとリリースのパッドサウンド
a = Synth("supersaw", [\freq: 55, \attk: 3.0, \decay: 1.0, \sustain: 0.8, \rel: 5.0, \resonance: 0.8, \amp: 0.15]);
b = Synth("supersaw", [\freq: 55 * 1.5, \attk: 3.0, \decay: 1.0, \sustain: 0.8, \rel: 5.0, \resonance: 0.8, \amp: 0.15]); // 完全5度上
c = Synth("supersaw", [\freq: 55 * (1.5 ** 2), \attk: 3.0, \decay: 1.0, \sustain: 0.8, \rel: 5.0, \resonance: 0.8, \amp: 0.15]); // さらに完全5度上

// 停止
a.set(\gate, 0);
b.set(\gate, 0);
c.set(\gate, 0);

// 例3：パーカッシブなベースサウンド（短いADSR）
d = Synth("supersaw", [\freq: 55, \attk: 0.005, \decay: 0.1, \sustain: 0.1, \rel: 0.2, \resonance: 0.7, \amp: 0.3, \semitone: 0]); // 第2オシレータをユニゾンに
e = Synth("supersaw", [\freq: 55 * 1.25, \attk: 0.005, \decay: 0.15, \sustain: 0.1, \rel: 0.2, \resonance: 0.7, \amp: 0.3, \semitone: 0]); // 短3度上

// 停止（リリースが短いため、gateを0にするとすぐに消える。doneAction:2で自動解放）
d.set(\gate, 0);
e.set(\gate, 0);
