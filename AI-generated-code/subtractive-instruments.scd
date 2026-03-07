/*
 * ================================================================
 * 減算合成（Subtractive Synthesis）による楽器コレクション
 * AMCJ ワークショップ「共鳴するコード、SuperColliderで創る音の世界」
 * ================================================================
 *
 * 減算合成の基本:
 *   豊富な倍音を持つ波形（ノコギリ波・矩形波など）を出発点に、
 *   フィルターで不要な周波数成分を「削る」ことで音色を作る。
 *
 *   オシレーター（Saw / Pulse / VarSaw）
 *        ↓
 *   フィルター（RLPF / RHPF / BPF）← カットオフEVとLFOで変化
 *        ↓
 *   振幅エンベロープ（ADSR）
 *        ↓
 *   エフェクト（リバーブ / コーラスなど）
 *
 * 収録楽器:
 *   1. SubLead  — クラシックなリードシンセ（Saw + RLPF + フィルターEV）
 *   2. SubBass  — 太いベースシンセ（デチューンSaw + ピッチEV + RLPF）
 *   3. SubPad   — 厚みのあるパッド（マルチオシレーター + スローフィルター）
 *
 * ================================================================
 */

s.boot;


// ================================================================
// SynthDef 1: SubLead
// ================================================================
/*
 * クラシックなモノフォニックリードシンセ
 *
 * 設計:
 * - わずかにデチューンした2本のSawで厚みを作る
 * - フィルターカットオフをエンベロープで制御
 *   → アタック時は開いて明るく、サステインで暗く閉じる
 * - ビブラートを遅延させてかけることでよりリアルな演奏感
 * - cutEnvAmt でフィルターEVの深さを調整
 *
 * 引数:
 *   cutoff     — フィルターのサステイン時カットオフ周波数
 *   cutEnvAmt  — フィルターEVの深さ（0〜1、大きいほど開き方が大きい）
 *   rq         — フィルターのレゾナンス（小さいほど強い）
 *   vibRate    — ビブラートの速さ（Hz）
 *   vibDepth   — ビブラートの深さ（周波数比率）
 *   vibDelay   — ビブラートがかかり始めるまでの時間（秒）
 */
(
SynthDef(\SubLead, {
    arg
    out        = 0,
    gate       = 1,
    freq       = 440,
    detune     = 0.007,   // オシレーター間のデチューン量（周波数比率）
    cutoff     = 1200,    // サステイン時のカットオフ周波数（Hz）
    cutEnvAmt  = 0.8,     // フィルターEVの深さ（0〜1）
    rq         = 0.25,    // レゾナンス（1/Q）小さいほど強い
    fAttk      = 0.005,   // フィルターEVアタック
    fDecay     = 0.25,    // フィルターEVディケイ
    attk       = 0.008,
    decay      = 0.2,
    sustain    = 0.6,
    rel        = 0.4,
    vibRate    = 5.5,
    vibDepth   = 0.012,
    vibDelay   = 0.25,    // ビブラートが始まるまでの遅延（秒）
    pan        = 0.0,
    amp        = 0.5;

    var sig, ampEnv, cutEnv, cutFreq, vibrato;

    // --- ビブラート（遅延フェードイン）---
    vibrato = SinOsc.kr(vibRate) * vibDepth
        * EnvGen.kr(Env.asr(vibDelay, 1.0, 0.1), gate);

    // --- オシレーター（デチューンしたSaw x2）---
    sig = Mix([
        Saw.ar(freq * (1.0 + vibrato)),
        Saw.ar(freq * (1.0 + detune + vibrato))
    ]) * 0.5;

    // --- フィルターカットオフエンベロープ ---
    // アタック後すぐに開き、ディケイで閉じる（ブライトなアタック）
    cutEnv  = EnvGen.kr(Env.adsr(fAttk, fDecay, 1.0 - cutEnvAmt, rel), gate);
    // cutEnvAmt = 1 のとき: cutoff × 1〜(1/(1-cutEnvAmt)) まで変化
    // cutEnvAmt = 0 のとき: 常にcutoff固定
    cutFreq = (cutoff * (1.0 + cutEnv * cutEnvAmt * 3)).clip(80, 18000);

    // --- RLPF フィルター ---
    sig = RLPF.ar(sig, cutFreq, rq);

    // --- 振幅エンベロープ（ADSR）---
    ampEnv = EnvGen.kr(
        Env.adsr(attk, decay, sustain, rel),
        gate,
        doneAction: Done.freeSelf
    );

    Out.ar(out, Pan2.ar(sig * ampEnv * amp, pan));
}).add;
)

// --- SubLead 演奏例 ---

// 基本（gateでオン/オフ）
x = Synth(\SubLead, [\freq: 440, \cutoff: 800, \cutEnvAmt: 0.9, \amp: 0.5]);
x.set(\gate, 0);

// 明るくレゾナンスの効いた音
x = Synth(\SubLead, [\freq: 220, \cutoff: 600, \cutEnvAmt: 0.95, \rq: 0.1, \amp: 0.4]);
x.set(\gate, 0);

// Pbind でメロディー演奏
(
p = Pbind(
    \instrument, \SubLead,
    \scale,      Scale.minor,
    \degree,     Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf),
    \octave,     4,
    \dur,        Pseq([0.5, 0.25, 0.25, 0.5, 0.5, 0.25, 0.25, 1.0], inf),
    \legato,     0.9,
    \cutoff,     Prand([600, 800, 1200, 2000], inf),
    \cutEnvAmt,  Prand([0.6, 0.8, 0.95], inf),
    \rq,         0.2,
    \amp,        0.45
).play;
)
p.stop;


// ================================================================
// SynthDef 2: SubBass
// ================================================================
/*
 * 太くパンチのあるベースシンセ
 *
 * 設計:
 * - 3本のSawをデチューンして重厚さを作る
 * - ピッチエンベロープで発音直後に僅かにピッチが上から下降
 *   → アナログシンセのポルタメント感 / ベースの「ごろっ」とした質感
 * - フィルターカットオフEVで発音直後だけ開く（パンチ感）
 * - lowCut で余計な超低域を除去してスッキリした低音に
 */
(
SynthDef(\SubBass, {
    arg
    out        = 0,
    gate       = 1,
    freq       = 110,
    detune     = 0.012,   // デチューン量
    pitchDrop  = 0.04,    // ピッチ降下の幅（発音後に freq × (1+pitchDrop) から freq へ）
    pitchTime  = 0.04,    // ピッチ降下にかかる時間
    cutoff     = 400,     // サステイン時カットオフ
    cutPeak    = 4000,    // アタック時カットオフピーク
    fDecay     = 0.12,    // フィルターEVのディケイ
    rq         = 0.5,
    attk       = 0.005,
    decay      = 0.15,
    sustain    = 0.7,
    rel        = 0.3,
    lowCut     = 40,      // ハイパスで超低域をカット
    pan        = 0.0,
    amp        = 0.6;

    var sig, ampEnv, cutEnv, cutFreq, pitchEnv, oscFreq;

    // --- ピッチエンベロープ（発音直後に軽くピッチが落ちる）---
    pitchEnv = EnvGen.kr(
        Env.new(
            [freq * (1 + pitchDrop), freq, freq],
            [pitchTime, 1.0],
            curve: [-6, 0]
        )
    );

    // --- オシレーター（3本デチューンSaw）---
    sig = Mix([
        Saw.ar(pitchEnv),
        Saw.ar(pitchEnv * (1.0 + detune)),
        Saw.ar(pitchEnv * (1.0 - detune))
    ]) * (1.0 / 3);

    // --- フィルターカットオフエンベロープ ---
    // アタック直後だけ cutPeak まで開き、素早く cutoff に戻る（パンチ感）
    cutEnv  = EnvGen.kr(
        Env.new([cutPeak, cutoff, cutoff], [fDecay, 1.0], curve: [-5, 0]),
        gate
    );
    sig = RLPF.ar(sig, cutEnv.clip(80, 18000), rq);

    // --- 超低域カット（HighPass で濁りを除去）---
    sig = HPF.ar(sig, lowCut);

    // --- 振幅エンベロープ ---
    ampEnv = EnvGen.kr(
        Env.adsr(attk, decay, sustain, rel),
        gate,
        doneAction: Done.freeSelf
    );

    Out.ar(out, Pan2.ar(sig * ampEnv * amp, pan));
}).add;
)

// --- SubBass 演奏例 ---

// 単音
x = Synth(\SubBass, [\freq: 55, \amp: 0.6]);
x.set(\gate, 0);

// レゾナンス強めの太いベース
x = Synth(\SubBass, [\freq: 55, \cutoff: 300, \cutPeak: 5000, \rq: 0.15, \amp: 0.5]);
x.set(\gate, 0);

// ベースラインのシーケンス
(
p = Pbind(
    \instrument, \SubBass,
    \midinote,   Pseq([36, 36, 43, 36, 38, 36, 41, 43], inf),
    \dur,        Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25], inf),
    \legato,     Prand([0.8, 0.4, 0.6], inf),
    \cutoff,     Prand([300, 400, 500], inf),
    \cutPeak,    Prand([3000, 5000, 8000], inf),
    \rq,         0.3,
    \amp,        0.55
).play;
)
p.stop;


// ================================================================
// SynthDef 3: SubPad
// ================================================================
/*
 * 厚みのあるポリフォニックパッドシンセ
 *
 * 設計:
 * - 5本のSawと1本のPulse（矩形波）をデチューン + ステレオ拡散
 * - フィルターカットオフをゆっくりした LFO で揺らす（うねり感）
 * - 長いADSRでサステイン型のパッド
 * - Splay.ar でオシレーターをステレオに自動拡散
 * - chorusDepth で軽いコーラス感を追加
 */
(
SynthDef(\SubPad, {
    arg
    out         = 0,
    gate        = 1,
    freq        = 220,
    detune      = 0.025,    // デチューン量
    cutoff      = 1800,     // フィルターカットオフ
    cutLFORate  = 0.15,     // カットオフLFOの速さ（Hz）
    cutLFODepth = 0.4,      // カットオフLFOの深さ（0〜1）
    rq          = 0.6,
    attk        = 1.5,
    decay       = 0.5,
    sustain     = 0.8,
    rel         = 3.0,
    chorusDepth = 0.003,    // コーラス感のデチューン量
    amp         = 0.3;

    var sig, ampEnv, cutMod, cutFreq, oscs;

    // --- マルチオシレーター（5本Saw + 1本Pulse、デチューン拡散）---
    oscs = Array.fill(5, { |i|
        // 各オシレーターをわずかずつデチューン（均等分散）
        var d = detune * (i - ((5 - 1) / 2)) / (5 - 1);
        Saw.ar(freq * (1.0 + d));
    }) ++ [Pulse.ar(freq * (1.0 + chorusDepth), 0.45)];  // Pulseで倍音の厚み追加

    // Splay.ar で全オシレーターをステレオに自動拡散
    sig = Splay.ar(oscs) * (1.0 / oscs.size);

    // --- フィルターカットオフをLFOで変調（うねり感）---
    cutMod  = SinOsc.kr(cutLFORate).range(1.0 - cutLFODepth, 1.0 + cutLFODepth);
    cutFreq = (cutoff * cutMod).clip(80, 18000);
    sig     = RLPF.ar(sig, cutFreq, rq);

    // --- 振幅エンベロープ（長いADSR）---
    ampEnv = EnvGen.kr(
        Env.adsr(attk, decay, sustain, rel),
        gate,
        doneAction: Done.freeSelf
    );

    Out.ar(out, sig * ampEnv * amp);
}).add;
)

// --- SubPad 演奏例 ---

// 単音パッド（gateでオン/オフ）
x = Synth(\SubPad, [\freq: 220, \cutoff: 1500, \amp: 0.35]);
x.set(\gate, 0);

// コード（複数音を重ねる）
(
~pad = [
    Synth(\SubPad, [\freq: 220,    \cutoff: 1200, \amp: 0.3]),   // A3
    Synth(\SubPad, [\freq: 261.63, \cutoff: 1500, \amp: 0.25]),  // C4
    Synth(\SubPad, [\freq: 329.63, \cutoff: 1800, \amp: 0.22]),  // E4
    Synth(\SubPad, [\freq: 440,    \cutoff: 2000, \amp: 0.2]),   // A4
];
)
~pad.do { |s| s.set(\gate, 0) };

// Pbindでコードプログレッション
(
p = Pbind(
    \instrument,  \SubPad,
    \scale,       Scale.minor,
    \degree,      Pdup(4, Pxrand([0, 2, 4, 5, 7], inf)),
    \octave,      Prand([3, 4], inf),
    \dur,         Prand([1.0, 2.0], inf),
    \legato,      Pexprand(1.5, 3.0, inf),
    \cutoff,      Prand([800, 1200, 1800, 2500], inf),
    \cutLFORate,  Prand([0.1, 0.2, 0.3], inf),
    \cutLFODepth, Prand([0.3, 0.5, 0.7], inf),
    \rq,          Prand([0.4, 0.6, 0.8], inf),
    \amp,         0.25
).play;
)
p.stop;


// ================================================================
// 3種類の楽器を組み合わせたアンサンブル
// ================================================================
(
var t = TempoClock(110 / 60);  // 110 BPM

// ベースライン（SubBass）
~bass = Pbind(
    \instrument, \SubBass,
    \midinote,   Pseq([36, 36, 43, 36, 38, 36, 41, 38], inf),
    \dur,        Pseq([0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.25], inf),
    \legato,     0.7,
    \cutoff,     400,
    \cutPeak,    Prand([3000, 5000], inf),
    \rq,         0.35,
    \amp,        0.55
);

// リードメロディー（SubLead）
~lead = Pbind(
    \instrument, \SubLead,
    \scale,      Scale.minor,
    \degree,     Prand([0, 2, 3, 5, 7, 9], inf),
    \octave,     Prand([4, 5], inf),
    \dur,        Prand([0.25, 0.5, 0.75, 1.0], inf),
    \legato,     Prand([0.6, 0.9, 1.2], inf),
    \cutoff,     Prand([600, 900, 1400], inf),
    \cutEnvAmt,  Prand([0.7, 0.9], inf),
    \rq,         0.2,
    \amp,        0.4
);

// パッドの和音（SubPad）
~pad = Pbind(
    \instrument,  \SubPad,
    \scale,       Scale.minor,
    \degree,      Pdup(3, Pxrand([0, 2, 4, 7], inf)),
    \octave,      3,
    \dur,         Prand([2.0, 3.0], inf),
    \legato,      2.5,
    \cutoff,      Prand([800, 1200, 1600], inf),
    \cutLFORate,  0.2,
    \cutLFODepth, 0.4,
    \rq,          0.7,
    \amp,         0.22
);

// 全パートを同期して再生
~bassPlayer = ~bass.play(t, quant: 2);
~leadPlayer = ~lead.play(t, quant: 2);
~padPlayer  = ~pad.play(t, quant: 4);
)

// 停止
~bassPlayer.stop;
~leadPlayer.stop;
~padPlayer.stop;