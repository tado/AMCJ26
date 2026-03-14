// FM変調合成 + Pbind サンプル

// サーバーを起動
s.boot;

Server.killAll;

---

/*
 * 1. FM楽器 (SynthDef) の定義
 *
 * キャリア (carrier): 聞こえる音の基本周波数
 * モジュレーター (mod): キャリアの周波数を変調する音
 * ratio: モジュレーター周波数 / キャリア周波数
 *   - 整数比 (1, 2, 3...) → 倍音的（金属的でない）
 *   - 非整数比 (1.414, 2.1...) → 非倍音的（金属的・ベル的）
 * index: 変調の深さ（大きいほど倍音が増える）
 */
(
SynthDef(\fmSynth, {
    arg out = 0, gate = 1,
        freq = 440,     // キャリア周波数
        ratio = 1.0,    // C:M 比
        index = 3,      // モジュレーションインデックス
        attk = 0.01,    // アタックタイム
        rel = 1.0,      // リリースタイム
        pan = 0.0,      // パン
        amp = 0.5;      // 音量

    var modFreq, mod, car, env, sig;

    // モジュレーター周波数 = キャリア × ratio
    modFreq = freq * ratio;

    // モジュレーター: 周波数偏移 = modFreq × index
    mod = SinOsc.ar(modFreq, 0, modFreq * index);

    // キャリア: 周波数をモジュレーターで変調
    car = SinOsc.ar(freq + mod);

    // ASRエンベロープ（gate=0でリリース開始）
    env = EnvGen.kr(Env.asr(attk, 1.0, rel), gate, doneAction: 2);

    sig = car * env * amp;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

// 動作確認（手動）
a = Synth(\fmSynth, [\freq, 220, \ratio, 1.414, \index, 10]);
a.set(\gate, 0);

---

/*
 * 2. パターンで演奏
 *
 * Scale.hirajoshi（平調子）を使って和風な雰囲気に
 */
(
TempoClock.default.tempo = 72/60;

p = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.hirajoshi,
    \degree, Prand([0, 1, 2, 3, 4], inf),
    \octave, Prand([3, 4, 4, 5], inf),
    // 整数比 → 倍音的なFM音色
    \ratio,  Prand([1.0, 2.0, 3.0, 0.5], inf),
    // index を変えると音色が変わる
    \index,  Pexprand(1, 15, inf),
    \attk,   Pexprand(0.01, 0.3, inf),
    \rel,    Pexprand(0.3, 2.0, inf),
    \pan,    Pwhite(-0.7, 0.7),
    \amp,    Pwhite(0.2, 0.5),
    \dur,    Prand([1/4, 1/4, 1/2, 1], inf),
    \legato, Pwhite(0.4, 0.9)
).play;
)

p.stop;

---

/*
 * 3. 2パターンを重ねて演奏
 *
 * ~p1: 低音域（オクターブ 2〜3）、長めの音
 * ~p2: 高音域（オクターブ 4〜5）、短めの音
 * 非整数比 (ratio) でベル・金属的な倍音を出す
 */
(
TempoClock.default.tempo = 80/60;

~p1 = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.hirajoshi,
    \degree, Pxrand([0, 1, 2, 3, 4], inf),
    \octave, Prand([2, 3, 3], inf),
    \ratio,  Prand([1.0, 1.5, 2.0], inf),  // 倍音的
    \index,  Pexprand(2, 20, inf),
    \attk,   0.05,
    \rel,    Pexprand(1.0, 3.0, inf),
    \pan,    Pwhite(-0.4, 0.4),
    \amp,    Pwhite(0.2, 0.4),
    \dur,    Prand([1/2, 1, 2], inf),
    \legato, 1.2
).play;

~p2 = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.hirajoshi,
    \degree, Pxrand([0, 1, 2, 3, 4], inf),
    \octave, Prand([4, 5, 5], inf),
    \ratio,  Prand([1.414, 2.1, 3.5], inf), // 非整数比（ベル的）
    \index,  Pexprand(3, 30, inf),
    \attk,   0.01,
    \rel,    Pexprand(0.5, 2.0, inf),
    \pan,    Pwhite(-0.7, 0.7),
    \amp,    Pwhite(0.1, 0.3),
    \dur,    Prand([1/4, 1/4, 1/2], inf),
    \legato, Pwhite(0.3, 0.7)
).play;
)

~p1.stop; ~p2.stop; ~p3.stop;

---

/*
 * 4. パーカッシブFM楽器 (SynthDef) の定義
 *
 * 打楽器的なFM音色のポイント:
 *   - Env.perc で素早いアタック・減衰
 *   - indexEnv: モジュレーションインデックスにも別エンベロープをかける
 *     → アタック直後に倍音が多く、すぐに減衰（金属的な打撃音）
 *   - 高い ratio（非整数比）でシンバル・タム的な金属音に
 *   - 低い freq + ratio=1 でキック的な音に
 */
(
SynthDef(\fmPerc, {
    arg out = 0,
        freq = 60,      // キャリア周波数（低め=キック、高め=シンバル）
        ratio = 1.4,    // C:M 比（非整数比で金属的に）
        index = 8,      // モジュレーションインデックスの最大値
        attk = 0.001,   // アンプのアタック
        rel = 0.4,      // アンプのリリース
        idxRel = 0.15,  // インデックスエンベロープのリリース（短いほど鋭い）
        pan = 0.0,
        amp = 0.7;

    var modFreq, indexEnv, mod, car, ampEnv, sig;

    modFreq = freq * ratio;

    // インデックスエンベロープ: アタック時に最大、素早く0へ減衰
    // これにより「コン」「チン」という打撃感が生まれる
    indexEnv = EnvGen.kr(Env.perc(attk, idxRel, index, -8));

    mod = SinOsc.ar(modFreq, 0, modFreq * indexEnv);
    car = SinOsc.ar(freq + mod);

    // アンプエンベロープ: パーカッシブな形状
    ampEnv = EnvGen.kr(Env.perc(attk, rel, 1, -4), doneAction: 2);

    sig = car * ampEnv * amp;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

// 動作確認
Synth(\fmPerc, [\freq, 60,  \ratio, 1.0, \index, 12, \rel, 0.5]);  // キック風
Synth(\fmPerc, [\freq, 200, \ratio, 1.4, \index, 8,  \rel, 0.2]);  // スネア風
Synth(\fmPerc, [\freq, 400, \ratio, 3.5, \index, 5,  \rel, 0.1]);  // ハット風

---

/*
 * 5. 3パートを重ねて演奏（メロディ低音 + メロディ高音 + リズム）
 */
(
TempoClock.default.tempo = 80/60;

// ~p1: 低音メロディ（倍音的FM）
~p1 = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.hirajoshi,
    \degree, Pxrand([0, 1, 2, 3, 4], inf),
    \octave, Prand([2, 3, 3], inf),
    \ratio,  Prand([1.0, 1.5, 2.0], inf),
    \index,  Pexprand(2, 20, inf),
    \attk,   0.05,
    \rel,    Pexprand(1.0, 3.0, inf),
    \pan,    Pwhite(-0.4, 0.4),
    \amp,    Pwhite(0.2, 0.4),
    \dur,    Prand([1/2, 1, 2], inf),
    \legato, 1.2
).play;

// ~p2: 高音メロディ（ベル的FM）
~p2 = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.hirajoshi,
    \degree, Pxrand([0, 1, 2, 3, 4], inf),
    \octave, Prand([4, 5, 5], inf),
    \ratio,  Prand([1.414, 2.1, 3.5], inf),
    \index,  Pexprand(3, 30, inf),
    \attk,   0.01,
    \rel,    Pexprand(0.5, 2.0, inf),
    \pan,    Pwhite(-0.7, 0.7),
    \amp,    Pwhite(0.1, 0.3),
    \dur,    Prand([1/4, 1/4, 1/2], inf),
    \legato, Pwhite(0.3, 0.7)
).play;

// ~p3: リズム（パーカッシブFM）
// Pbindparを使い、3種の打楽器を同じタイムラインに重ねる
~p3 = Ppar([
    // キック: 1拍目と3拍目
    Pbind(
        \instrument, \fmPerc,
        \freq,   55,
        \ratio,  1.0,
        \index,  Prand([10, 14], inf),
        \rel,    0.5,
        \idxRel, 0.2,
        \pan,    0.0,
        \amp,    Prand([0.7, 0.8], inf),
        \dur,    Pseq([1, 1], inf)  // 2拍ごと
    ),
    // スネア: 2拍目と4拍目
    Pbind(
        \instrument, \fmPerc,
        \freq,   Prand([180, 200], inf),
        \ratio,  Prand([1.4, 1.6], inf),
        \index,  Prand([6, 9], inf),
        \rel,    0.25,
        \idxRel, 0.1,
        \pan,    Prand([-0.2, 0.2], inf),
        \amp,    Prand([0.5, 0.65], inf),
        \dur,    Pseq([1, 1], inf),
        \offset, 1  // 1拍ずらして2・4拍目に
    ),
    // ハイハット: 8分音符で刻む
    Pbind(
        \instrument, \fmPerc,
        \freq,   Prand([600, 800, 1000], inf),
        \ratio,  Prand([3.5, 4.1, 5.3], inf),
        \index,  Prand([3, 5], inf),
        \rel,    Prand([0.05, 0.08, 0.15], inf),
        \idxRel, 0.03,
        \pan,    Prand([-0.6, -0.3, 0.3, 0.6], inf),
        \amp,    Prand([0.2, 0.3, 0.15], inf),
        \dur,    Pseq([1/2], inf)  // 8分音符
    )
], inf).play;
)

~p1.stop; ~p2.stop; ~p3.stop; ~p4.stop;

---

/*
 * 6. ノイジー凶暴FM楽器 (SynthDef) の定義
 *
 * 設計コンセプト:
 *   - FM変調のインデックスを極限まで上げてノイズ域へ（index > 50 で事実上ノイズ）
 *   - モジュレーターをFMで入れ子に（FM of FM）→ より混沌とした倍音
 *   - WhiteNoiseをFMモジュレーターに注入 → ランダムな周波数揺らぎ
 *   - .tanh でソフトクリッピング → 歪み
 *   - RLPF で荒れ狂うカットオフ → レゾナンス爆発
 */
(
SynthDef(\fmBrute, {
    arg out = 0, gate = 1,
        freq = 80,       // キャリア基本周波数
        ratio = 2.73,    // C:M 比（非整数比）
        index = 40,      // インデックス（高いほどカオス）
        noiseMix = 0.5,  // ノイズ混入比（0=純FM, 1=純ノイズ）
        cutoff = 3000,   // フィルターカットオフ
        rq = 0.1,        // レゾナンス（小さいほど強い）
        attk = 0.001,
        rel = 0.8,
        pan = 0.0,
        amp = 0.6;

    var modFreq, innerMod, outerMod, noise, car, filt, env, sig;

    modFreq = freq * ratio;

    // 内側のFMモジュレーター（入れ子FM）
    innerMod = SinOsc.ar(modFreq * 1.41, 0, modFreq * index * 0.5);

    // 外側のFMモジュレーター（内側で変調済み）
    outerMod = SinOsc.ar(modFreq + innerMod, 0, modFreq * index);

    // ホワイトノイズ成分（高域の荒れを追加）
    noise = WhiteNoise.ar(modFreq * index * noiseMix);

    // キャリア: 外側FMモジュレーター + ノイズで変調
    car = SinOsc.ar(freq + outerMod + noise);

    // ソフトクリッピングで歪みを追加
    car = (car * 3).tanh;

    // カットオフをLFNoise1でランダムに暴れさせる
    filt = RLPF.ar(
        car,
        LFNoise1.kr(Rand(4, 12)).exprange(cutoff * 0.1, cutoff * 3).clip(80, 18000),
        rq
    );

    env = EnvGen.kr(Env.asr(attk, 1.0, rel), gate, doneAction: 2);

    sig = filt * env * amp;
    sig = Pan2.ar(sig, pan);

    Out.ar(out, sig);
}).add;
)

// 動作確認
a = Synth(\fmBrute, [\freq, 80,  \ratio, 2.73, \index, 40, \noiseMix, 0.3]);
a.set(\gate, 0);
a = Synth(\fmBrute, [\freq, 30,  \ratio, 7.1,  \index, 80, \noiseMix, 0.8, \rq, 0.05]);
a.set(\gate, 0);

---

/*
 * 7. アバンギャルド全パート演奏
 *    テンポ: 140 BPM（速く攻撃的）
 *    ~p1: 低音FM（クロマチック + 極端なindex）
 *    ~p2: 高音FM（非整数ratio + 超高index）
 *    ~p3: リズム（ポリリズム 5/8 + 3/8 交差）
 *    ~p4: 凶暴ノイズFM（突発的なカオス）
 */
(
TempoClock.default.tempo = 140/60;

// ~p1: 低音域 - 極端なindexで音色が激しく変化
~p1 = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.chromatic,
    \degree, Pwrand(
        [0, 1, 3, 6, 8, 11],
        [0.3, 0.1, 0.2, 0.2, 0.1, 0.1].normalizeSum,
        inf
    ),
    \octave, Prand([1, 2, 2, 3], inf),
    \ratio,  Prand([0.5, 1.0, 2.73, 3.14, 7.0], inf),
    \index,  Pexprand(5, 80, inf),
    \attk,   Prand([0.001, 0.01, 0.3], inf),
    \rel,    Pexprand(0.2, 4.0, inf),
    \pan,    Pwhite(-1.0, 1.0),
    \amp,    Pwhite(0.3, 0.7),
    \dur,    Prand([1/4, 1/4, 1/2, 3/4, 1/8], inf),
    \legato, Prand([0.1, 0.5, 1.5, 2.0], inf)
).play;

// ~p2: 高音域 - 微分音的な音程 + 暴力的なindex
~p2 = Pbind(
    \instrument, \fmSynth,
    \scale,  Scale.chromatic,
    \degree, Pxrand([0, 1, 2, 5, 7, 10, 11], inf),
    \octave, Prand([4, 5, 6, 6], inf),
    \ratio,  Prand([1.414, 3.14, 5.83, 0.333, 9.1], inf),
    \index,  Pexprand(20, 120, inf),
    \attk,   Prand([0.001, 0.005], inf),
    \rel,    Pexprand(0.05, 1.5, inf),
    \pan,    Pwhite(-1.0, 1.0),
    \amp,    Pwhite(0.15, 0.45),
    \dur,    Prand([1/8, 1/8, 1/4, 1/16], inf),
    \legato, Prand([0.05, 0.2, 0.8], inf)
).play;

// ~p3: リズム - ポリリズム（5/8 + 3/8 が交差）
~p3 = Ppar([
    // キック: 5拍子で刻む
    Pbind(
        \instrument, \fmPerc,
        \freq,   Prand([40, 50, 55, 30], inf),
        \ratio,  Prand([1.0, 1.5, 0.5], inf),
        \index,  Prand([15, 20, 30], inf),
        \rel,    Prand([0.3, 0.6, 0.1], inf),
        \idxRel, 0.15,
        \pan,    Pwhite(-0.3, 0.3),
        \amp,    Prand([0.8, 0.6, 1.0], inf),
        \dur,    Pseq([1, 1, 1, 1, 1] * (1/2), inf)  // 5/8拍子
    ),
    // スネア的なヒット: 3拍子
    Pbind(
        \instrument, \fmPerc,
        \freq,   Prand([150, 200, 250, 100], inf),
        \ratio,  Prand([1.7, 2.3, 3.1], inf),
        \index,  Prand([8, 12, 18], inf),
        \rel,    Prand([0.1, 0.2, 0.4], inf),
        \idxRel, Prand([0.05, 0.1], inf),
        \pan,    Pwhite(-0.7, 0.7),
        \amp,    Prand([0.5, 0.7, 0.4], inf),
        \dur,    Pseq([1, 1, 1] * (1/2), inf)  // 3/8拍子
    ),
    // 高速ハット: 細かく不規則
    Pbind(
        \instrument, \fmPerc,
        \freq,   Pexprand(500, 3000, inf),
        \ratio,  Pexprand(3.0, 9.0, inf),
        \index,  Prand([2, 4, 6, 1], inf),
        \rel,    Pexprand(0.02, 0.12, inf),
        \idxRel, 0.02,
        \pan,    Pwhite(-1.0, 1.0),
        \amp,    Pwhite(0.1, 0.35),
        \dur,    Prand([1/8, 1/16, 1/16, 1/4], inf)
    )
], inf).play;

// ~p4: 凶暴ノイズFM - 突発的に出現するカオス
~p4 = Pbind(
    \instrument, \fmBrute,
    \freq,     Pexprand(25, 800, inf),
    \ratio,    Prand([2.73, 7.1, 0.17, 4.5, 11.3], inf),
    \index,    Pexprand(30, 150, inf),
    \noiseMix, Pwhite(0.2, 0.9),
    \cutoff,   Pexprand(200, 8000, inf),
    \rq,       Prand([0.05, 0.08, 0.2, 0.5], inf),
    \attk,     Prand([0.001, 0.01, 0.1], inf),
    \rel,      Pexprand(0.1, 3.0, inf),
    \pan,      Pwhite(-1.0, 1.0),
    \amp,      Pwhite(0.3, 0.7),
    \dur,      Prand([1/4, 1/2, 1/8, 1, 1/16, 3/4], inf),
    \legato,   Prand([0.3, 0.8, 2.0, 0.05], inf)
).play;
)

~p1.stop; ~p2.stop; ~p3.stop; ~p4.stop;
