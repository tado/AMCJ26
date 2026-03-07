/*
 * Claude Codeで生成されたコード例
 * プロンプト「学習した成果を生かして、FM音響合成を行う楽器 (SynthDef) を作成してください。」
 * ================================================================
 * FM音響合成による楽器コレクション
 * ================================================================
 *
 * FM合成の基本:
 *   modFreq  = carFreq * ratio          // モジュレーター周波数（C:M比）
 *   modDepth = modFreq * index          // 変調深度 = index × modFreq
 *   mod      = SinOsc.ar(modFreq, mul: modDepth)
 *   carrier  = SinOsc.ar(carFreq + mod) // 周波数にモジュレーターを加算
 *
 * C:M比の音楽的意味:
 *   整数比  (1:1, 2:1, 3:2 ...) → 倍音が調和的（音楽的な音色）
 *   非整数比 (1:1.414, 1:1.5...) → 非調和音（ベル・金属的な音色）
 *
 * 変調インデックス (index) の効果:
 *   小 (0〜1)   → 倍音が少なく純音に近い（柔らかい）
 *   中 (3〜10)  → 豊かな倍音（明るく複雑な音色）
 *   大 (20以上) → 非常に多くの倍音（激しく鋭い音色）
 *
 * ================================================================
 */

// まずサーバーを起動
s.boot;


// ================================================================
// SynthDef 1: FMPad
// ================================================================
/*
 * 特徴:
 * - 変調インデックスをエンベロープで制御
 *   → 発音直後は倍音豊か、時間とともに柔らかくなる自然な音色変化
 * - 振動（ビブラート）をLFOで付加
 * - ADSRエンベロープでゲート制御
 * - GVerbによるリバーブ
 *
 * 設計:
 *   modulator → carrier → ADSR env → pan → reverb → out
 *   indexEnv  ↗
 *   lfo       ↗（ビブラート）
 */
(
SynthDef(\FMPad, {
    arg
    out        = 0,
    gate       = 1,
    freq       = 440,    // キャリア基本周波数（Hz）
    ratio      = 1.0,    // C:M比（モジュレーター / キャリア）
    index      = 6,      // 変調インデックスの最大値
    indexDecay = 3.0,    // インデックスエンベロープのディケイ時間
    vibRate    = 5.0,    // ビブラートの速さ（Hz）
    vibDepth   = 0.01,   // ビブラートの深さ（周波数比率）
    attk       = 0.1,    // 振幅エンベロープのアタック
    decay      = 0.3,    // 振幅エンベロープのディケイ
    sustain    = 0.7,    // 振幅エンベロープのサステインレベル
    rel        = 1.5,    // 振幅エンベロープのリリース
    room       = 40,     // リバーブのルームサイズ
    revTime    = 3.0,    // リバーブタイム
    pan        = 0.0,    // ステレオ定位（-1〜1）
    amp        = 0.4;

    var modFreq, mod, car, sig, ampEnv, indexEnv, vibrato;

    // --- インデックスエンベロープ ---
    // 発音直後に最大値 index → 素早くゼロに近づく（ピアノ的な音色変化）
    indexEnv = EnvGen.kr(
        Env.perc(0.001, indexDecay, curve: -4),
        gate
    ).range(0, index);

    // --- ビブラート（音程の揺れ）---
    // 発音から少し遅れてかかるように EnvGen でフェードイン
    vibrato = SinOsc.kr(vibRate) * vibDepth
        * EnvGen.kr(Env.asr(0.5, 1.0, 0.2), gate);

    // --- モジュレーター ---
    modFreq = freq * ratio;
    mod     = SinOsc.ar(modFreq, mul: modFreq * indexEnv);

    // --- キャリア（FM変調 + ビブラート）---
    car = SinOsc.ar(freq * (1 + vibrato) + mod);

    // --- 振幅エンベロープ（ADSR）---
    ampEnv = EnvGen.kr(
        Env.adsr(attk, decay, sustain, rel),
        gate,
        doneAction: Done.freeSelf
    );

    // --- パン → リバーブ → 出力 ---
    sig = Pan2.ar(car * ampEnv * amp, pan);
    sig = GVerb.ar(sig, room, revTime, 0.5, 0.5, 15, 1, 0.7, 0.5) * 0.6;

    Out.ar(out, sig);
}).add;
)

// --- FMPad 演奏例 ---

// 基本再生（ゲートでオン/オフ）
x = Synth(\FMPad, [\freq: 220, \ratio: 1.0, \index: 8, \amp: 0.4]);
x.set(\gate, 0);

// ベル的な音色（非整数C:M比）
x = Synth(\FMPad, [\freq: 440, \ratio: 1.414, \index: 12, \amp: 0.3]);
x.set(\gate, 0);

// 柔らかいパッド（低インデックス、長いアタック）
x = Synth(\FMPad, [\freq: 110, \ratio: 0.5, \index: 3, \attk: 2.0, \rel: 4.0, \amp: 0.35]);
x.set(\gate, 0);

// Pbind でスケール演奏
(
p = Pbind(
    \instrument, \FMPad,
    \scale,  Scale.hirajoshi,
    \degree, Pxrand([0, 1, 2, 3, 4], inf),
    \octave, Prand([3, 4, 5], inf),
    \dur,    Prand([0.5, 1.0, 1.5], inf),
    \legato, Pexprand(0.5, 2.0, inf),
    \ratio,  Prand([1.0, 1.5, 1.414], inf),
    \index,  Prand([2, 5, 10, 15], inf),
    \pan,    Prand([-0.5, -0.2, 0, 0.2, 0.5], inf),
    \amp,    0.3
).play;
)
p.stop;


// ================================================================
// SynthDef 2: FMBell
// ================================================================
/*
 * 特徴:
 * - 非整数C:M比による非倍音的な倍音構造（ベル・鐘の音）
 * - インデックスが指数的に急減衰（発音後すぐに柔らかくなる）
 * - 振幅はゆっくり減衰（long decay）
 * - 2オペレーター（モジュレーター1つ + キャリア1つ）
 *
 * 古典的なFMベルの設定:
 *   ratio = 1.4 〜 1.414（√2に近い値）→ 金属的な不協和感
 *   index = 10 〜 20 → 発音直後の倍音の豊かさ
 */
(
SynthDef(\FMBell, {
    arg
    out       = 0,
    freq      = 440,
    ratio     = 1.414,   // C:M比（√2: 非整数 → ベル的）
    index     = 14,      // 変調インデックスの最大値
    dur       = 4.0,     // 音の長さ（減衰時間）
    pan       = 0.0,
    amp       = 0.5;

    var modFreq, mod, car, sig, ampEnv, indexEnv;

    // --- インデックスエンベロープ（指数的に急減衰）---
    // 発音直後は豊かな倍音 → 素早く消える（打楽器的）
    indexEnv = EnvGen.kr(
        Env.perc(0.001, dur * 0.8, curve: -8)
    ).range(0, index);

    // --- 振幅エンベロープ（ゆっくり減衰）---
    ampEnv = EnvGen.kr(
        Env.perc(0.001, dur, curve: -3),
        doneAction: Done.freeSelf
    );

    // --- FM変調 ---
    modFreq = freq * ratio;
    mod     = SinOsc.ar(modFreq, mul: modFreq * indexEnv);
    car     = SinOsc.ar(freq + mod);

    // --- 出力 ---
    sig = Pan2.ar(car * ampEnv * amp, pan);
    Out.ar(out, sig);
}).add;
)

// --- FMBell 演奏例 ---

// 単発のベル
Synth(\FMBell, [\freq: 880, \ratio: 1.414, \index: 14, \dur: 5.0, \amp: 0.5]);

// 和音のように複数を重ねる
(
Synth(\FMBell, [\freq: 440,  \ratio: 1.414, \index: 12, \dur: 6.0, \pan: -0.3, \amp: 0.4]);
Synth(\FMBell, [\freq: 550,  \ratio: 1.414, \index: 12, \dur: 6.0, \pan:  0.0, \amp: 0.3]);
Synth(\FMBell, [\freq: 660,  \ratio: 1.414, \index: 12, \dur: 6.0, \pan:  0.3, \amp: 0.3]);
)

// Pbind でランダムなベルのテクスチャ
(
p = Pbind(
    \instrument, \FMBell,
    \scale,  Scale.ritusen,
    \degree, Pxrand([0, 1, 2, 3, 4], inf),
    \octave, Prand([4, 5, 6], inf),
    \dur,    Pexprand(0.3, 2.0, inf),
    \ratio,  Prand([1.414, 1.5, 1.618], inf),   // 黄金比も使える
    \index,  Prand([8, 12, 16, 20], inf),
    \dur,    Pexprand(0.2, 1.5, inf),
    \pan,    Pwhite(-0.8, 0.8, inf),
    \amp,    Pexprand(0.2, 0.5, inf)
).play;
)
p.stop;


// ================================================================
// SynthDef 3: FMBass
// ================================================================
/*
 * 特徴:
 * - 低い基本周波数 + FMによる倍音追加
 * - 非常に短いインデックスエンベロープ（キック風の「アタック音」を作る）
 * - 基本周波数自体もエンベロープで急降下させてキック的な効果を追加
 * - 短いパーカッシブなエンベロープで自動解放
 *
 * キックドラムのFM設定例:
 *   freq  = 50〜80Hz（低音）
 *   ratio = 1.0 〜 1.5
 *   index = 5〜20（発音後すぐ0に）
 *   pitchDecay: 周波数が素早く下降（ドンという音の輪郭）
 */
(
SynthDef(\FMBass, {
    arg
    out        = 0,
    freq       = 60,     // 基本周波数（サステイン音）
    pitchStart = 180,    // 発音直後の周波数（ここから freq へ降下）
    pitchDecay = 0.06,   // ピッチ降下にかかる時間（秒）
    ratio      = 1.0,    // C:M比
    index      = 12,     // 変調インデックスの最大値
    indexDecay = 0.08,   // インデックス減衰時間
    dur        = 0.5,    // 全体の長さ
    pan        = 0.0,
    amp        = 0.8;

    var carFreq, modFreq, mod, car, sig, ampEnv, indexEnv, pitchEnv;

    // --- ピッチエンベロープ（発音後すぐに下降 → キック的な輪郭）---
    pitchEnv = EnvGen.kr(
        Env.new([pitchStart, freq, freq], [pitchDecay, dur - pitchDecay], curve: -8)
    );

    // --- インデックスエンベロープ（超短い減衰）---
    indexEnv = EnvGen.kr(
        Env.perc(0.001, indexDecay, curve: -6)
    ).range(0, index);

    // --- 振幅エンベロープ ---
    ampEnv = EnvGen.kr(
        Env.perc(0.001, dur, curve: -4),
        doneAction: Done.freeSelf
    );

    // --- FM変調（ピッチエンベロープを適用）---
    modFreq = pitchEnv * ratio;
    mod     = SinOsc.ar(modFreq, mul: modFreq * indexEnv);
    car     = SinOsc.ar(pitchEnv + mod);

    // --- 出力 ---
    sig = Pan2.ar(car * ampEnv * amp, pan);
    Out.ar(out, sig);
}).add;
)

// --- FMBass 演奏例 ---

// 単発のキック
Synth(\FMBass, [\freq: 55, \pitchStart: 200, \pitchDecay: 0.05, \index: 15, \dur: 0.6, \amp: 0.8]);

// ベースライン（Routineで繰り返し）
(
r = Routine({
    inf.do({
        // キック（4つ打ち）
        Synth(\FMBass, [\freq: 55, \pitchStart: 200, \pitchDecay: 0.05, \index: 15, \dur: 0.5, \amp: 0.8]);
        0.5.yield;
        Synth(\FMBass, [\freq: 55, \pitchStart: 200, \pitchDecay: 0.05, \index: 15, \dur: 0.5, \amp: 0.8]);
        0.5.yield;
        Synth(\FMBass, [\freq: 55, \pitchStart: 200, \pitchDecay: 0.05, \index: 15, \dur: 0.5, \amp: 0.8]);
        0.5.yield;
        // アクセント（少し高い音）
        Synth(\FMBass, [\freq: 82, \pitchStart: 280, \pitchDecay: 0.06, \index: 18, \dur: 0.5, \amp: 0.7]);
        0.5.yield;
    });
});
r.reset.play;
)
r.stop;


// ================================================================
// 3種類の楽器を組み合わせたアンサンブル
// ================================================================
(
var t = TempoClock(120/60);  // 120 BPM

// ベースライン（FMBass）
~bass = Routine({
    inf.do({
        Synth(\FMBass, [\freq: 55,  \pitchStart: 180, \index: 14, \dur: 0.4, \amp: 0.7]);
        0.5.yield;
        Synth(\FMBass, [\freq: 55,  \pitchStart: 180, \index: 14, \dur: 0.4, \amp: 0.5]);
        0.25.yield;
        Synth(\FMBass, [\freq: 73,  \pitchStart: 220, \index: 12, \dur: 0.3, \amp: 0.6]);
        0.25.yield;
    });
});

// ベルのメロディー（FMBell）
~bells = Routine({
    inf.do({
        [0, 2, 4, 7].do({ |deg|
            Synth(\FMBell, [
                \freq,  (60 + [0, 2, 4, 7].choose).midicps * Prand([1, 2], 1).next,
                \ratio, 1.414,
                \index, Prand([8, 12, 16], 1).next,
                \dur,   Prand([1.5, 2.0, 3.0], 1).next,
                \pan,   rrand(-0.6, 0.6),
                \amp,   rrand(0.2, 0.4)
            ]);
            Prand([0.25, 0.5, 0.75], 1).next.yield;
        });
    });
});

// パッドのロングトーン（FMPad）
~pad = Routine({
    inf.do({
        var notes = [55, 62, 64, 67].collect(_.midicps);
        notes.do({ |f|
            Synth(\FMPad, [
                \freq,  f,
                \ratio, 0.5,
                \index, 3,
                \attk,  1.5,
                \rel,   3.0,
                \amp,   0.15,
                \pan,   rrand(-0.4, 0.4)
            ]);
        });
        4.0.yield;  // 4拍ごとに和音を変える
    });
});

~bass.reset.play(t);
~bells.reset.play(t, quant: 1);
~pad.reset.play(t, quant: 4);
)

// 停止
~bass.stop; ~bells.stop; ~pad.stop;
