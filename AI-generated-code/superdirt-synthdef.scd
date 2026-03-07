SuperDirt.start;

/*
 * Claude Codeで生成されたコード例
 * プロンプト「FMPad・FMBell・FMBassをSuperDirt向けに書き換えて、
 *            superfmpad・superfmbell・superfmbassを作成してください。」
 * ================================================================
 * SuperDirt向け FM合成 SynthDef コレクション
 * ================================================================
 *
 * 使い方:
 *   1. SuperDirt を起動する
 *   2. このファイルを全選択して評価（Ctrl+A → Ctrl+Enter）
 *   3. TidalCycles から以下のように呼び出す：
 *        d1 $ s "superfmpad" # n "c4 e4 g4"
 *        d1 $ s "superfmbell" # n "c5" # voice 20 # pitch1 1.414
 *        d1 $ s "superfmbass" # n "c2" # voice 15 # pitch1 4
 *
 * SuperDirt SynthDef の設計ルール（03-superdirt.scd から学習）:
 *   - 必須引数: out, sustain=1, pan, freq, decay=0
 *   - Tidal制御引数: voice（音色）, pitch1（補助周波数・C:M比）
 *   - エンベロープ: Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3)
 *                   timeScale:sustain で長さを制御
 *   - 振幅: env を DirtPan に渡す（0〜1のスケール）
 *   - 出力: OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
 *
 * Tidal パラメータの対応:
 *   superfmpad  : voice = FMインデックス(0〜20), pitch1 = C:M比
 *   superfmbell : voice = FMインデックス(0〜30), pitch1 = C:M比（1.414でベル的）
 *   superfmbass : voice = FMインデックス(0〜20), pitch1 = ピッチ降下の開始倍率
 * ================================================================
 */


// ================================================================
// SynthDef 1: superfmpad
// ================================================================
/*
 * オリジナル FMPad を SuperDirt 向けに変換:
 *   - gate / ADSRエンベロープ → sustain/decay ベースのEnv.pairsに統一
 *   - GVerb リバーブ削除（SuperDirt の reverb エフェクトを使う）
 *   - Pan2.ar + Out.ar → DirtPan.ar + OffsetOut.ar に変換
 *   - amp引数削除（SuperDirtがamp/gainを外部管理）
 *   - voice = FMインデックス最大値（デフォルト6）
 *   - pitch1 = C:M比（デフォルト1.0）
 *
 * TidalCycles 使用例:
 *   d1 $ s "superfmpad" # n "c4 e4 g4" # sustain 2 # voice 8 # pitch1 1.5
 */
(
SynthDef(\superfmpad, {
    arg out, sustain=1, pan, freq, decay=0,
    voice=6.0,   // 変調インデックスの最大値（小: 柔らかい / 大: 明るく複雑）
    pitch1=1.0;  // C:M比（1.0: 基音と同じ / 0.5: 1オクターブ下 / 2.0: 1オクターブ上）

    var env, mod, car, modFreq, indexEnv, vibrato;

    // インデックスエンベロープ: 発音直後に最大 → 時間とともに柔らかく
    indexEnv = EnvGen.kr(
        Env.perc(0.001, sustain * 0.5, curve: -4)
    ).range(0, voice);

    // ビブラート: sustain の前半でフェードイン
    vibrato = SinOsc.kr(5.0) * 0.01
        * EnvGen.kr(Env.asr(sustain * 0.3, 1.0, sustain * 0.1), 1);

    // FM変調
    modFreq = freq * pitch1;
    mod = SinOsc.ar(modFreq, mul: modFreq * indexEnv);
    car = SinOsc.ar(freq * (1 + vibrato) + mod);

    // 標準 SuperDirt エンベロープ
    env = EnvGen.ar(
        Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3),
        timeScale: sustain,
        doneAction: 2
    );

    OffsetOut.ar(out, DirtPan.ar(car, ~dirt.numChannels, pan, env));
}).add;
)


// ================================================================
// SynthDef 2: superfmbell
// ================================================================
/*
 * オリジナル FMBell を SuperDirt 向けに変換:
 *   - dur → sustain に統一
 *   - Pan2.ar + Out.ar → DirtPan.ar + OffsetOut.ar に変換
 *   - インデックスの急速な減衰でベル・鐘らしい音色変化を維持
 *   - voice = FMインデックス最大値（デフォルト14）
 *   - pitch1 = C:M比（デフォルト1.414 = √2 でベル的な非調和音）
 *
 * TidalCycles 使用例:
 *   d1 $ s "superfmbell" # n "c5 e5 g5" # sustain 3 # voice 16 # pitch1 1.414
 *   d1 $ s "superfmbell" # n "c5" # voice 20 # pitch1 1.618  -- 黄金比（より複雑）
 */
(
SynthDef(\superfmbell, {
    arg out, sustain=1, pan, freq, decay=0,
    voice=14.0,   // 変調インデックスの最大値
    pitch1=1.414; // C:M比（デフォルト√2 → ベル・金属的な非倍音音色）

    var env, mod, car, modFreq, indexEnv;

    // インデックスエンベロープ: 発音直後のみ高く、指数的に急減衰（打楽器的）
    indexEnv = EnvGen.kr(
        Env.perc(0.001, sustain * 0.8, curve: -8)
    ).range(0, voice);

    // FM変調
    modFreq = freq * pitch1;
    mod = SinOsc.ar(modFreq, mul: modFreq * indexEnv);
    car = SinOsc.ar(freq + mod);

    // ベル向けエンベロープ: アタック極短 → sustain かけてゆっくり減衰
    env = EnvGen.ar(
        Env.pairs([[0,0],[0.002,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3),
        timeScale: sustain,
        doneAction: 2
    );

    OffsetOut.ar(out, DirtPan.ar(car, ~dirt.numChannels, pan, env));
}).add;
)


// ================================================================
// SynthDef 3: superfmbass
// ================================================================
/*
 * オリジナル FMBass を SuperDirt 向けに変換:
 *   - dur, pitchDecay → sustain ベースの相対時間に変換
 *   - pitchStart → pitch1 = ピッチ降下の開始倍率（freq * pitch1 が開始周波数）
 *   - Pan2.ar + Out.ar → DirtPan.ar + OffsetOut.ar に変換
 *   - voice = FMインデックス最大値（デフォルト12）
 *   - pitch1 = ピッチ降下の開始倍率（デフォルト3.0）
 *
 * TidalCycles 使用例:
 *   d1 $ s "superfmbass" # n "c2" # sustain 0.4 # voice 15 # pitch1 4
 *   d1 $ s "superfmbass" # n "c2 g1 c2 c2" # voice 10 # pitch1 3
 */
(
SynthDef(\superfmbass, {
    arg out, sustain=1, pan, freq, decay=0,
    voice=12.0,  // 変調インデックスの最大値（キックのアタック音の太さ）
    pitch1=3.0;  // ピッチ降下の開始倍率（freq * pitch1 からスタート）

    var env, mod, car, modFreq, pitchEnv, indexEnv;
    var pitchStart = freq * pitch1;  // 発音直後の周波数
    var pitchDecay = sustain * 0.12; // ピッチ降下時間（sustain の 12%）

    // ピッチエンベロープ: 発音後すぐに freq へ降下（キック的な輪郭）
    pitchEnv = EnvGen.kr(
        Env.new(
            [pitchStart, freq, freq],
            [pitchDecay, sustain - pitchDecay],
            curve: -8
        )
    );

    // インデックスエンベロープ: 超短い減衰でアタック感を演出
    indexEnv = EnvGen.kr(
        Env.perc(0.001, sustain * 0.15, curve: -6)
    ).range(0, voice);

    // FM変調（ピッチエンベロープを適用）
    modFreq = pitchEnv * 1.0;  // C:M = 1:1
    mod = SinOsc.ar(modFreq, mul: modFreq * indexEnv);
    car = SinOsc.ar(pitchEnv + mod);

    // パーカッシブなエンベロープ
    env = EnvGen.ar(
        Env.pairs([[0,0],[0.01,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -4),
        timeScale: sustain,
        doneAction: 2
    );

    OffsetOut.ar(out, DirtPan.ar(car, ~dirt.numChannels, pan, env));
}).add;
)


// ================================================================
// ================================================================
// 減算合成（Subtractive Synthesis）SynthDef コレクション
// ================================================================
// ================================================================
/*
 * オリジナル: AI-generated-code/subtractive-instruments.scd
 * SubLead / SubBass / SubPad を SuperDirt 向けに変換
 *
 * SuperDirt 変換のポイント:
 *   - gate / Env.adsr → sustain + Env.pairs(timeScale:sustain)
 *   - フィルターEV・ピッチEVの時間 → sustain に比例した相対時間に変換
 *   - Pan2.ar + Out.ar → DirtPan.ar + OffsetOut.ar
 *   - amp 引数削除（SuperDirt が外部管理）
 *
 * Tidal パラメータの対応:
 *   supersublead : voice = フィルターEV深さ(0〜1), pitch1 = レゾナンス rq(0〜1)
 *   supersubbass : voice = フィルターEV深さ(0〜1), pitch1 = ピッチ降下の幅(0〜1)
 *   supersubpad  : voice = カットオフLFO深さ(0〜1), pitch1 = LFO速さ(Hz)
 */


// ================================================================
// SynthDef 4: supersublead
// ================================================================
/*
 * クラシックなモノフォニックリードシンセ（SubLead の SuperDirt 変換）
 *
 * 設計:
 * - デチューンした2本のSawで厚みを作る
 * - フィルターEVでアタック時に明るく開き、sustain の 30% の時間で閉じる
 * - ビブラートを sustain に比例した遅延でかける
 *
 * TidalCycles 使用例:
 *   d1 $ s "supersublead" # n "c4 e4 g4" # cutoff 800 # voice 0.9 # pitch1 0.2
 *   d1 $ s "supersublead" # n "c5" # sustain 1.5 # voice 0.6 # cutoff 1500
 */
(
SynthDef(\supersublead, {
    arg out, sustain=1, pan, freq, decay=0,
    voice=0.8,     // フィルターEVの深さ（0=変化なし〜1=大きく開く）
    pitch1=0.25,   // フィルターのレゾナンス（rq, 小さいほど強いレゾナンス）
    cutoff=1200,   // サステイン時のカットオフ周波数（Hz）
    detune=0.007,  // 2本のSaw間のデチューン量
    speed=1, accelerate=0;

    var sig, env, cutEnv, cutFreq, vibrato;

    // ビブラート: sustain の前半でゆっくりフェードイン
    vibrato = SinOsc.kr(5.5) * 0.012
        * EnvGen.kr(Env.asr(sustain * 0.25, 1.0, sustain * 0.1), 1);

    // オシレーター: デチューンした2本の Saw で厚みを作る
    sig = Mix([
        Saw.ar(freq * (1.0 + vibrato)),
        Saw.ar(freq * (1.0 + detune + vibrato))
    ]) * 0.5;

    // フィルターEV: アタック直後に開き、sustain の 30% の時間で閉じる
    // voice = 0 のとき cutoff 固定、voice = 1 のとき最大 4倍まで開く
    cutEnv  = EnvGen.kr(Env.perc(0.008, sustain * 0.3, curve: -5));
    cutFreq = (cutoff * (1.0 + cutEnv * voice * 3.0)).clip(80, 18000);
    sig     = RLPF.ar(sig, cutFreq, pitch1.clip(0.01, 1.0));

    // 標準 SuperDirt エンベロープ
    env = EnvGen.ar(
        Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3),
        timeScale: sustain,
        doneAction: 2
    );

    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;
)


// ================================================================
// SynthDef 5: supersubbass
// ================================================================
/*
 * 太くパンチのあるベースシンセ（SubBass の SuperDirt 変換）
 *
 * 設計:
 * - 3本デチューンSawで重厚さを作る
 * - ピッチEVで発音直後にピッチが上から降下（ベースの「ごろっ」とした質感）
 * - フィルターEVでアタック直後だけ開く（パンチ感）
 *
 * TidalCycles 使用例:
 *   d1 $ s "supersubbass" # n "c2" # voice 0.8 # pitch1 0.05 # cutoff 500
 *   d1 $ s "supersubbass" # n "c2 g1 c2 c2" # voice 0.9 # pitch1 0.1
 */
(
SynthDef(\supersubbass, {
    arg out, sustain=1, pan, freq, decay=0,
    voice=0.7,     // フィルターEVの深さ（0=cutoff固定〜1=大きく開くパンチ感）
    pitch1=0.04,   // ピッチ降下の幅（0=降下なし〜1=大きく降下）
    cutoff=400,    // サステイン時カットオフ（Hz）
    rq=0.5,        // レゾナンス (1/Q)
    detune=0.012,  // 3本のSaw間のデチューン量
    speed=1, accelerate=0;

    var sig, env, cutEnv, cutFreq, pitchEnv, cutPeak;
    var pitchDecay = sustain * 0.1;  // ピッチ降下時間 (sustain の 10%)
    var fDecay     = sustain * 0.15; // フィルターEV減衰時間 (sustain の 15%)

    // ピッチEV: pitch1 が大きいほど発音直後のピッチが高くスタートし、素早く降下
    pitchEnv = EnvGen.kr(
        Env.new(
            [freq * (1.0 + pitch1), freq, freq],
            [pitchDecay, sustain - pitchDecay],
            curve: [-6, 0]
        )
    );

    // オシレーター: 3本デチューン Saw
    sig = Mix([
        Saw.ar(pitchEnv),
        Saw.ar(pitchEnv * (1.0 + detune)),
        Saw.ar(pitchEnv * (1.0 - detune))
    ]) * (1.0 / 3);

    // フィルターEV: voice 0のときcutoff固定、1のとき最大8倍まで開く
    cutPeak = cutoff * (1.0 + voice * 8.0);
    cutEnv  = EnvGen.kr(
        Env.new([cutPeak, cutoff, cutoff], [fDecay, sustain - fDecay], curve: [-5, 0])
    );
    sig = RLPF.ar(sig, cutEnv.clip(80, 18000), rq);

    // 超低域カット（濁り除去）
    sig = HPF.ar(sig, 40);

    // 標準 SuperDirt エンベロープ（ベース向けに短いアタック）
    env = EnvGen.ar(
        Env.pairs([[0,0],[0.02,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -4),
        timeScale: sustain,
        doneAction: 2
    );

    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;
)


// ================================================================
// SynthDef 6: supersubpad
// ================================================================
/*
 * 厚みのあるポリフォニックパッドシンセ（SubPad の SuperDirt 変換）
 *
 * 設計:
 * - 5本のSaw + 1本のPulseをデチューン + ステレオ拡散（Splay.ar）
 * - フィルターカットオフをLFOでゆっくり変調（うねり感）
 * - voice でLFO深さ、pitch1 でLFO速さを制御
 *
 * TidalCycles 使用例:
 *   d1 $ s "supersubpad" # n "c3" # sustain 4 # voice 0.4 # pitch1 0.2
 *   d1 $ s "supersubpad" # n "c3 e3 g3" # sustain 6 # voice 0.7 # cutoff 2000
 */
(
SynthDef(\supersubpad, {
    arg out, sustain=1, pan, freq, decay=0,
    voice=0.4,     // カットオフLFOの変調深さ（0=揺れなし〜1=大きく揺れる）
    pitch1=0.15,   // カットオフLFOの速さ（Hz）
    cutoff=1800,   // フィルターカットオフ（Hz）
    rq=0.6,        // レゾナンス (1/Q)
    detune=0.025,  // 5本のSaw間のデチューン量
    speed=1, accelerate=0;

    var sig, env, cutMod, cutFreq, oscs;

    // マルチオシレーター: 5本の Saw + 1本の Pulse（対称的にデチューン分散）
    oscs = Array.fill(5, { |i|
        var d = detune * (i - ((5 - 1) / 2)) / (5 - 1);
        Saw.ar(freq * (1.0 + d));
    }) ++ [Pulse.ar(freq * 1.003, 0.45)];

    // Splay.ar でステレオに自動拡散
    sig = Splay.ar(oscs) * (1.0 / oscs.size);

    // カットオフをLFOで変調（うねり感）
    // voice = 0 のとき変調なし、voice = 1 のとき ±50% 変動
    cutMod  = SinOsc.kr(pitch1.max(0.01)).range(
        1.0 - (voice * 0.5),
        1.0 + (voice * 0.5)
    );
    cutFreq = (cutoff * cutMod).clip(80, 18000);
    sig     = RLPF.ar(sig, cutFreq, rq);

    // 標準 SuperDirt エンベロープ（パッド向けに緩やかなアタック）
    env = EnvGen.ar(
        Env.pairs([[0,0],[0.1,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -2),
        timeScale: sustain,
        doneAction: 2
    );

    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;
)
