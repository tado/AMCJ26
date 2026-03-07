/*
 * Claude codeを使用して生成
 * プロンプト: SuperColliderで「ミニマルな反復メロディー」を演奏するPbindを作って。
 * 律旋法スケールを使い、音量とリズムをランダムに変化させて。
 *
 * ================================================================
 * 律旋法スケールによるミニマルな反復メロディー
 * AMCJ ワークショップ「共鳴するコード、SuperColliderで創る音の世界」
 * ================================================================
 *
 * 設計コンセプト:
 *   ミニマルミュージックの手法 + 律旋法スケールの組み合わせ
 *
 *   律旋法 (Scale.ritusen):
 *     C - D - E - G - A（5音音階）
 *     日本の雅楽・民謡に由来する音階
 *
 *   ミニマル手法:
 *   1. フェーズシフト — 同じ音列を異なる音価で演奏し、徐々にずれていく
 *   2. 反復と微小変化 — Pbrown でゆっくりと音程が漂う
 *   3. 疎な低音 — 長い音価の少ない音でグラウンドを作る
 *   4. 音量・リズムのランダム変化 — Pexprand / Prand で有機的な揺れ
 *
 * レイヤー構成:
 *   Layer 1: MinTone   — クリーンなメロディー音（Saw + SinOsc + RLPF）
 *   Layer 2: MinBell   — ベル的な倍音トーン（FM合成）
 *   Pbind 1: ~main     — メインメロディー（固定音列の反復）
 *   Pbind 2: ~counter  — カウンターメロディー（異なる音価でフェーズシフト）
 *   Pbind 3: ~bass     — 低音の疎なパルス
 *   Pbind 4: ~accent   — ランダムに現れる高域のアクセント
 *
 * ================================================================
 */

s.boot;


// ================================================================
// SynthDef 1: MinTone — ミニマルなメロディー音
// ================================================================
/*
 * Sawとサイン波の2倍音を混ぜたクリーンなトーン。
 * カットオフをエンベロープでわずかに動かして有機的な質感を加える。
 */
(
SynthDef(\MinTone, {
    arg
    out    = 0,
    gate   = 1,
    freq   = 440,
    cutoff = 2500,
    rq     = 0.6,
    attk   = 0.015,
    rel    = 0.5,
    pan    = 0.0,
    amp    = 0.3;

    var sig, env, cutEnv;

    // ノコギリ波 + 2倍音のサイン波で倍音に厚みを加える
    sig = Mix([
        Saw.ar(freq),
        SinOsc.ar(freq * 2, mul: 0.4)
    ]) * 0.5;

    // カットオフを発音直後だけわずかに開く（自然な音色変化）
    cutEnv = EnvGen.kr(Env.perc(0.005, rel * 0.8, curve: -4)).range(1.0, 2.5);
    sig    = RLPF.ar(sig, (cutoff * cutEnv).clip(200, 12000), rq);

    env = EnvGen.kr(
        Env.adsr(attk, 0.08, 0.75, rel),
        gate,
        doneAction: Done.freeSelf
    );

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)


// ================================================================
// SynthDef 2: MinBell — アクセント用のベル音（FM合成）
// ================================================================
/*
 * ratio = 1.414（√2）の非整数C:M比でベル的な音色。
 * アクセントパターンの音として使用する。
 */
(
SynthDef(\MinBell, {
    arg
    out   = 0,
    freq  = 880,
    index = 10,
    dur   = 2.0,
    pan   = 0.0,
    amp   = 0.3;

    var mod, car, sig, ampEnv, idxEnv;

    idxEnv = EnvGen.kr(Env.perc(0.001, dur * 0.9, curve: -6)).range(0, index);
    ampEnv = EnvGen.kr(Env.perc(0.001, dur, curve: -4), doneAction: Done.freeSelf);

    mod = SinOsc.ar(freq * 1.414, mul: freq * 1.414 * idxEnv);
    car = SinOsc.ar(freq + mod);

    Out.ar(out, Pan2.ar(car * ampEnv * amp, pan));
}).add;
)


// ================================================================
// パターン定義
// ================================================================
(
var t = TempoClock(96 / 60);  // 96 BPM — ゆったりとしたテンポ

// --- 基本の音列（律旋法の5音から選んだ6音セル）---
// このセルが全レイヤーの基礎となる
var cell = [0, 2, 4, 2, 4, 7];

// ================================================================
// Pbind 1: ~main — メインメロディー
// ================================================================
// 固定の音列を反復しながら、音量・リズム・定位をランダムに揺らす。
// Pbrown で音程がゆっくりドリフトし、少しずつ変化していく。

~main = Pbind(
    \instrument, \MinTone,
    \scale,      Scale.ritusen,

    // 基本音列 (Pseq) + Pbrown でゆっくり上下にドリフト
    // Pbrown(低, 高, ステップ幅, 繰り返し): ランダムウォークでゆっくり変化
    \degree, Pclutch(
        Pbrown(0, 4, 1, inf),   // 0〜4度の範囲でランダムウォーク
        Prand([false, true], inf) // 一定確率で音程を固定（反復感を出す）
    ),

    \octave, Pdup(
        Prand([4, 6, 8], inf),  // 4〜8回同じオクターブを続けてから変化
        Prand([4, 5], inf)
    ),

    // リズム: 主に16分音符・8分音符、時々4分音符
    \dur, Prand([1/8, 1/8, 1/4, 1/8, 1/16, 1/4], inf),

    // 音量: 指数分布で自然な強弱（静かな音が多く、たまに大きい）
    \amp, Pexprand(0.08, 0.35, inf),

    // 発音の長さ（legato）: 短め〜長めでランダム
    \legato, Prand([0.5, 0.7, 1.0, 1.4], inf),

    // 定位: 左右にわずかに揺れる
    \pan, Prand([-0.3, -0.15, 0.0, 0.15, 0.3], inf),

    \cutoff, Prand([1500, 2000, 2800, 3500], inf),
    \rq,     Prand([0.5, 0.6, 0.8], inf)
);


// ================================================================
// Pbind 2: ~counter — カウンターメロディー（フェーズシフト）
// ================================================================
// 同じ律旋法スケールで、異なる音価・音域を使う。
// ~main とは異なるデュレーションパターンなので、
// 演奏するうちに少しずつ位相がずれていく（フェーズシフト）。

~counter = Pbind(
    \instrument, \MinTone,
    \scale,      Scale.ritusen,

    // 音列: Pxrand で直前と同じ音が連続しないランダム選択
    \degree, Pxrand([0, 2, 4, 7, 9], inf),

    \octave, Pdup(
        Prand([3, 5, 7], inf),  // ~main と異なる反復数 → 位相ずれを生む
        Prand([4, 5], inf)
    ),

    // ~main と微妙に異なる音価 → フェーズシフトの核心
    \dur, Prand([3/16, 1/8, 1/4, 3/8], inf),

    \amp,    Pexprand(0.06, 0.22, inf),
    \legato, Prand([0.8, 1.2, 1.8], inf),
    \pan,    Prand([-0.6, -0.3, 0.3, 0.6], inf),
    \cutoff, Prand([1000, 1800, 2500], inf),
    \rq,     0.7
);


// ================================================================
// Pbind 3: ~bass — 低音の疎なパルス
// ================================================================
// 律旋法の低音（オクターブ3）を長い音価でゆっくり刻む。
// 音量の揺れが大きく、たまに消えそうになる。

~bass = Pbind(
    \instrument, \MinTone,
    \scale,      Scale.ritusen,

    // 低音域では根音と5度（degree 0, 4）を中心に使う
    \degree, Pdup(
        Prand([2, 3, 4], inf),  // 同じ音を2〜4回繰り返す
        Pwrand([0, 2, 4], [0.5, 0.3, 0.2], inf)  // 根音を多め
    ),

    \octave, 3,

    // 疎なリズム: 4分音符〜付点2分音符
    \dur, Prand([1/2, 1, 3/4, 1/4, 1], inf),

    // 音量: 大きめで存在感を出しつつ揺らす
    \amp,    Pexprand(0.15, 0.45, inf),
    \legato, Pexprand(0.6, 2.0, inf),

    \pan,    Prand([-0.1, 0.0, 0.1], inf),
    \cutoff, Prand([600, 800, 1000], inf),
    \rq,     0.8,
    \attk,   0.03,
    \rel,    1.2
);


// ================================================================
// Pbind 4: ~accent — 高域のランダムアクセント（ベル）
// ================================================================
// 律旋法スケールの高域音をベル音色でランダムに点在させる。
// 音楽に光のような輝きを加える。

~accent = Pbind(
    \instrument, \MinBell,
    \scale,      Scale.ritusen,

    \degree, Pxrand([0, 2, 4, 7, 9], inf),
    \octave, Prand([5, 6], inf),

    // アクセントは疎に: 長めの音価でたまにしか鳴らない
    \dur,   Prand([1, 2, 3/4, 3/2], inf),

    \amp,   Pexprand(0.1, 0.3, inf),
    \index, Prand([6, 10, 14, 20], inf),
    \pan,   Pwhite(-0.8, 0.8, inf)
);


// ================================================================
// 全パートを quant で同期して再生
// ================================================================
// quant: 4 = 次の4拍の頭から開始（全パートがビートの頭で揃う）

~mainPlayer    = ~main.play(t,    quant: 4);
~counterPlayer = ~counter.play(t, quant: 4);
~bassPlayer    = ~bass.play(t,    quant: 4);
~accentPlayer  = ~accent.play(t,  quant: 4);

"全パートを再生開始。停止するには ~allStop.value を実行してください。".postln;
)


// ================================================================
// 停止
// ================================================================
(
~allStop = {
    ~mainPlayer.stop;
    ~counterPlayer.stop;
    ~bassPlayer.stop;
    ~accentPlayer.stop;
    "停止しました。".postln;
};
)

~allStop.value;


// ================================================================
// バリエーション: パートを段階的に重ねる（ライブ向け）
// ================================================================
(
var t = TempoClock(96 / 60);

// ベースのみからスタート
~bassPlayer = ~bass.play(t, quant: 4);
)

// 4〜8小節後にメインを追加
~mainPlayer = ~main.play(t, quant: 4);

// さらに後にカウンターを追加（フェーズシフトが始まる）
~counterPlayer = ~counter.play(t, quant: 4);

// アクセントを追加
~accentPlayer = ~accent.play(t, quant: 4);

// 逆順に外していく
~accentPlayer.stop;
~counterPlayer.stop;
~mainPlayer.stop;
~bassPlayer.stop;
