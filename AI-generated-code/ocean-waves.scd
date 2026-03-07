/*
 * ================================================================
 * 波が打ち寄せるような環境音
 * AMCJ ワークショップ「共鳴するコード、SuperColliderで創る音の世界」
 * ================================================================
 *
 * 設計コンセプト:
 *   海の音を3つの層に分解して合成する
 *
 *   Layer 1: OceanBase — 低音の持続的なうねり（常時）
 *     BrownNoise → LPF（カットオフをゆっくり揺らす）
 *     → 海の底から来るような低音の存在感
 *
 *   Layer 2: OceanWave — 波が打ち寄せる音（不規則にトリガー）
 *     PinkNoise → BPF（カットオフをEVで変化）
 *     → ゆっくり高まり、打ち寄せてから引いていく
 *
 *   Layer 3: OceanSpray — 波のしぶき（波のピークに合わせてトリガー）
 *     WhiteNoise → HPF（高域のみ通過）
 *     → 波の砕ける瞬間の高周波のしぶき
 *
 * ================================================================
 */

s.boot;

// ================================================================
// Layer 1: OceanBase — 低音の持続的なうねり
// ================================================================
/*
 * 常時鳴らす低音層。波の「土台」となる存在感。
 *
 * - BrownNoise: 低域に偏ったノイズ（海の深みを表現）
 * - カットオフ周波数を2つのSinOsc.krで緩やかに揺らす
 *   （速さの異なるLFO2つの合成で、不規則なうねりを作る）
 * - 音量もゆっくり揺れさせてうねりを強調
 */
(
SynthDef(\OceanBase, {
    arg
    out       = 0,
    cutoff    = 120,     // フィルターカットオフの中心周波数
    lfo1Rate  = 0.04,    // 主うねりの速さ（Hz）
    lfo1Depth = 0.5,     // 主うねりの深さ（0〜1）
    lfo2Rate  = 0.11,    // 副うねりの速さ（Hz）
    lfo2Depth = 0.25,    // 副うねりの深さ
    rq        = 0.9,     // レゾナンス（大きいほど柔らか）
    ampRate   = 0.06,    // 音量うねりの速さ
    amp       = 0.3;

    var sig, cutMod, ampMod, cutFreq;

    // --- 速さの異なる2つのLFOを合成してカットオフを揺らす ---
    // 完全に規則的にならないよう、位相もランダムにずらす
    cutMod = SinOsc.kr(lfo1Rate, Rand(0, 2pi)) * lfo1Depth
           + SinOsc.kr(lfo2Rate, Rand(0, 2pi)) * lfo2Depth;

    // カットオフ: 中心値 ± 変調（下限60Hz、上限400Hz）
    cutFreq = (cutoff * (1 + cutMod)).clip(60, 400);

    // --- 音量もゆっくり揺らす（波のうねりを表現）---
    ampMod = SinOsc.kr(ampRate, Rand(0, 2pi)).range(0.4, 1.0);

    // --- BrownNoise → RLPF ---
    sig = BrownNoise.ar();
    sig = RLPF.ar(sig, cutFreq, rq);

    // --- ステレオ（左右でわずかに揺らしてリアリティを出す）---
    sig = [
        RLPF.ar(BrownNoise.ar(), cutFreq * 0.98, rq),
        RLPF.ar(BrownNoise.ar(), cutFreq * 1.02, rq)
    ];

    Out.ar(out, sig * ampMod * amp);
}).add;
)


// ================================================================
// Layer 2: OceanWave — 波が打ち寄せる音
// ================================================================
/*
 * 個々の波をイベントとして生成する。
 *
 * 振幅エンベロープ:
 *   ゆっくり立ち上がる（波が沖から近づく）
 *   → ピークで砕ける
 *   → ゆっくり引いていく（波が引く音）
 *
 * フィルターエンベロープ:
 *   最初は低め（水の塊）
 *   → 砕ける瞬間に開く（明るく激しい音）
 *   → 引くにつれて閉じる（静かになる）
 *
 * pan: 左右の位置をランダムにずらして立体感を出す
 */
(
SynthDef(\OceanWave, {
    arg
    out      = 0,
    dur      = 6.0,     // 波1本の持続時間（秒）
    pan      = 0.0,     // ステレオ定位（-1〜1）
    cutLo    = 300,     // フィルターEV最低値（波の「水感」）
    cutHi    = 3000,    // フィルターEV最高値（波の砕ける音）
    rq       = 0.5,     // レゾナンス
    riseTime = 0.35,    // 振幅エンベロープの立ち上がり割合（0〜1）
    amp      = 0.6;

    var sig, ampEnv, cutEnv, cutFreq;

    // --- 振幅エンベロープ ---
    // ゆっくり上昇 → ピーク → ゆっくり減衰
    // curve: 上昇は指数的(-3)、減衰はゆっくり指数的(-2)
    ampEnv = EnvGen.kr(
        Env.new(
            [0, 0.2, 1.0, 0.15, 0],
            [riseTime * 0.5, riseTime * 0.5, (1 - riseTime) * 0.5, (1 - riseTime) * 0.5] * dur,
            curve: [-3, -4, -1, -3]
        ),
        doneAction: Done.freeSelf
    );

    // --- フィルターカットオフエンベロープ ---
    // 低め → 上昇（砕ける）→ 下降（引く）
    cutEnv = EnvGen.kr(
        Env.new(
            [cutLo, cutLo * 1.5, cutHi, cutLo * 0.6],
            [riseTime * 0.6, riseTime * 0.4, (1 - riseTime)] * dur,
            curve: [-2, -5, -2]
        )
    );

    // --- PinkNoise → RLPF（フィルターEVを適用）---
    // ステレオで2本のノイズを使い、わずかにカットオフをずらす
    sig = [
        RLPF.ar(PinkNoise.ar(), cutEnv * 0.95, rq),
        RLPF.ar(PinkNoise.ar(), cutEnv * 1.05, rq)
    ];

    // 音量に振幅EVとampを適用してパン
    sig = Balance2.ar(sig[0], sig[1], pan) * ampEnv * amp;

    Out.ar(out, sig);
}).add;
)


// ================================================================
// Layer 3: OceanSpray — 波のしぶき
// ================================================================
/*
 * 波が砕ける瞬間の高周波しぶき。
 * OceanWave のピーク付近に合わせてトリガーする。
 *
 * - WhiteNoise → HPF（高域のみ通過させてしぶき感を出す）
 * - 短い持続時間と速い減衰
 * - 左右に広がるよう Splay 的な処理
 */
(
SynthDef(\OceanSpray, {
    arg
    out    = 0,
    dur    = 1.5,     // しぶきの持続時間
    pan    = 0.0,
    cutoff = 5000,    // HPFのカットオフ（これより低い成分を除去）
    amp    = 0.2;

    var sig, env;

    // --- 短い減衰エンベロープ ---
    env = EnvGen.kr(
        Env.perc(0.01, dur, curve: -5),
        doneAction: Done.freeSelf
    );

    // --- WhiteNoise → HPF（しぶきの高域成分）---
    sig = [
        HPF.ar(WhiteNoise.ar(), cutoff * rrand(0.9, 1.1)),
        HPF.ar(WhiteNoise.ar(), cutoff * rrand(0.9, 1.1))
    ];

    // 左右に軽く広げてパン
    sig = Balance2.ar(sig[0], sig[1], pan);
    Out.ar(out, sig * env * amp);
}).add;
)


// ================================================================
// 再生 — 3つの層を組み合わせる
// ================================================================

// --- Step 1: 低音のベース層を起動（常時鳴らす）---
~base = Synth(\OceanBase, [
    \cutoff,    100,
    \lfo1Rate,  0.03,
    \lfo2Rate,  0.09,
    \ampRate,   0.05,
    \amp,       0.35
]);

// --- Step 2: 波を不規則なタイミングでトリガーするルーティン ---
(
~waveRoutine = Routine({
    loop({
        var waveDur, interval, pan, amp;

        // 波の長さ・タイミング・定位・音量をランダムに
        waveDur  = rrand(5.0, 10.0);      // 波の長さ（5〜10秒）
        interval = rrand(3.0, 8.0);       // 次の波までの間隔（3〜8秒）
        pan      = rrand(-0.5, 0.5);      // 左右の位置
        amp      = rrand(0.4, 0.8);       // 音量

        // 波のメイン音を起動
        Synth(\OceanWave, [
            \dur,      waveDur,
            \pan,      pan,
            \cutLo,    rrand(200, 400),   // 波の「水感」周波数
            \cutHi,    rrand(2000, 5000), // 砕ける際の明るさ
            \rq,       rrand(0.4, 0.7),
            \riseTime, rrand(0.25, 0.45),
            \amp,      amp
        ]);

        // 波のピーク付近（立ち上がりの85%のタイミング）でしぶきをトリガー
        (waveDur * rrand(0.25, 0.40)).yield;

        Synth(\OceanSpray, [
            \dur,    rrand(0.8, 2.5),
            \pan,    pan + rrand(-0.2, 0.2),
            \cutoff, rrand(4000, 8000),
            \amp,    rrand(0.1, 0.25)
        ]);

        // 次の波のトリガーまで待機
        (interval - (waveDur * 0.3)).yield;
    });
});

~waveRoutine.reset.play;
)

// --- 停止 ---
~waveRoutine.stop;
~base.free;

// ================================================================
// パラメータを変化させた別バリエーション
// ================================================================

// 穏やかな凪の海（小さい波、ゆっくり）
(
~base = Synth(\OceanBase, [\cutoff: 80, \lfo1Rate: 0.02, \amp: 0.2]);

~waveRoutine = Routine({
    loop({
        Synth(\OceanWave, [
            \dur,      rrand(7.0, 12.0),
            \pan,      rrand(-0.4, 0.4),
            \cutLo,    rrand(150, 300),
            \cutHi,    rrand(1000, 2000),
            \rq,       0.7,
            \riseTime, 0.4,
            \amp,      rrand(0.25, 0.45)
        ]);
        rrand(5.0, 10.0).yield;
    });
});
~waveRoutine.reset.play;
)

~waveRoutine.stop;
~base.free;


// 荒れた海（大きな波、短い間隔、強いレゾナンス）
(
~base = Synth(\OceanBase, [\cutoff: 150, \lfo1Rate: 0.07, \lfo1Depth: 0.8, \amp: 0.45]);

~waveRoutine = Routine({
    loop({
        var dur = rrand(4.0, 7.0);
        Synth(\OceanWave, [
            \dur,      dur,
            \pan,      rrand(-0.7, 0.7),
            \cutLo,    rrand(400, 700),
            \cutHi,    rrand(4000, 8000),
            \rq,       rrand(0.2, 0.4),
            \riseTime, rrand(0.2, 0.35),
            \amp,      rrand(0.6, 0.9)
        ]);
        (dur * 0.3).yield;
        Synth(\OceanSpray, [
            \dur,    rrand(1.5, 3.5),
            \pan,    rrand(-0.5, 0.5),
            \cutoff, rrand(5000, 10000),
            \amp,    rrand(0.2, 0.4)
        ]);
        rrand(1.5, 4.0).yield;
    });
});
~waveRoutine.reset.play;
)

~waveRoutine.stop;
~base.free;
