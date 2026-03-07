/*
 * ================================================================
 * Sin波から始めるSuperColliderの基本
 * AMCJ ワークショップ「共鳴するコード、SuperColliderで創る音の世界」
 * ================================================================
 *
 * このチュートリアルはSuperColliderを初めて使う方を対象に、
 * Sin波（サイン波）の再生から始めて、段階的に音作りの基本を学びます。
 *
 * 使い方:
 * - まずサーバーを起動してください: s.boot
 * - コードブロックを選択して Ctrl+Enter（または Shift+Enter）で実行
 * - サーバーを停止するには Ctrl+. (ピリオド)
 *
 * ================================================================
 */


// ================================================================
// まず最初に：サーバーを起動する
// ================================================================
s.boot;


// ================================================================
// SECTION 1: Sin波の再生 — 最初の一音
// ================================================================
/*
 * SuperColliderで音を鳴らす最もシンプルなコードです。
 *
 * { } の中に音を生成するUGen（ユニット・ジェネレーター）を書き、
 * .play を呼ぶことで音が鳴ります。
 *
 * SinOsc.ar() : サイン波（正弦波）を生成するUGen
 *   .ar = Audio Rate（オーディオレート）で動作することを示す
 *   引数を指定しない場合のデフォルト周波数は 440Hz（A4の音）
 */

// まずこれを実行してみましょう
{ SinOsc.ar() }.play

// 止めるには Ctrl+. を押してください


// ================================================================
// SECTION 2: ステレオ再生
// ================================================================
/*
 * 先ほどのコードで鳴らした音は「モノラル」でした。
 * SuperColliderは左チャンネルのみに音を出します。
 *
 * ステレオで鳴らすには、信号を2チャンネルに複製する必要があります。
 *
 * .dup(2) : 信号を指定した数だけ複製する
 * ! 2      : .dup(2) と同じ意味（省略記法）
 */

// ステレオ再生（左右両チャンネルに同じ音）
{ SinOsc.ar().dup(2) }.play

// 省略記法
{ SinOsc.ar() ! 2 }.play

// 波形を確認する（.scope でオシロスコープ表示）
{ SinOsc.ar().dup(2) }.scope


// ================================================================
// SECTION 3: 音量の変更
// ================================================================
/*
 * SinOsc.ar() の2番目の引数は「位相」、3番目の引数は「振幅（音量）」です。
 *
 * SinOsc.ar(freq, phase, mul, add)
 *   freq  : 周波数（Hz）デフォルト: 440
 *   phase : 位相（ラジアン）デフォルト: 0.0
 *   mul   : 振幅（乗数）デフォルト: 1.0
 *   add   : オフセット デフォルト: 0.0
 *
 * 注意: mul=1.0 はフルボリューム。0.0〜1.0 の範囲が適切です。
 *       1.0を超えるとクリッピング（音割れ）が起きる可能性があります。
 */

// 音量を0.3に下げる
{ SinOsc.ar(440, 0.0, 0.3).dup(2) }.play

// 音量を0.8に上げる
{ SinOsc.ar(440, 0.0, 0.8).dup(2) }.play

// キーワード引数を使った書き方（より明瞭）
{ SinOsc.ar(freq: 440, mul: 0.3).dup(2) }.play

// 音量が大きすぎる例（音割れに注意！）
// { SinOsc.ar(440, 0.0, 2.0).dup(2) }.play


// ================================================================
// SECTION 4: 周波数の変更
// ================================================================
/*
 * SinOsc.ar() の1番目の引数が周波数（Hz）です。
 *
 * 音の高さと周波数の関係:
 *   110 Hz = A2（低いラ）
 *   220 Hz = A3
 *   440 Hz = A4（標準的な「ラ」）
 *   880 Hz = A5（1オクターブ上）
 *
 * 周波数を2倍にすると1オクターブ上の音になります。
 */

// A3: 220Hz
{ SinOsc.ar(220).dup(2) }.scope

// A4: 440Hz（標準ピッチ）
{ SinOsc.ar(440).dup(2) }.scope

// A5: 880Hz（1オクターブ上）
{ SinOsc.ar(880).dup(2) }.scope

// MIDIノートナンバーを周波数に変換する
// .midicps（MIDIノートナンバーをHz＝サイクル毎秒に変換）メソッドを使います
// A4 = MIDIノート 69
69.midicps.postln    // -> 440.0Hz
57.midicps.postln    // -> 220.0Hz (A3)

{ SinOsc.ar(69.midicps).dup(2) }.play


// ================================================================
// SECTION 5: 変数による指定
// ================================================================
/*
 * コードの中で同じ値を何度も使う場合や、値に名前をつけたい場合に変数を使います。
 *
 * SuperColliderの変数には以下の種類があります:
 *
 * 1. ローカル変数 (var): 関数や括弧()の中でのみ有効
 * 2. グローバル変数: 英小文字1文字 (a〜z, sを除く)
 * 3. 環境変数 (~): ~name の形式で宣言不要で使える
 */

// ローカル変数を使った例
(
var freq, amp;
freq = 440;   // 周波数
amp  = 0.3;   // 振幅

{ SinOsc.ar(freq, mul: amp).dup(2) }.play;
)

// 環境変数を使った例
~freq = 330;
~amp  = 0.3;
{ SinOsc.ar(~freq, mul: ~amp).dup(2) }.play


// ================================================================
// SECTION 6: SinOscのパラメータをコントロール信号で変化させる
// ================================================================
/*
 * 静的な値ではなく、時間とともに変化する「コントロール信号」で
 * SinOscのパラメータを制御できます。
 *
 * よく使われるLFO（低周波オシレーター）系のUGen:
 *
 * SinOsc.kr(freq)  : サイン波の低周波バージョン（制御信号）
 * LFNoise0.kr(rate): ランダムなステップ信号を生成
 * LFNoise1.kr(rate): ランダムな直線補間信号を生成
 * XLine.kr(start, end, dur): 指数的に変化する信号
 * Line.kr(start, end, dur) : 直線的に変化する信号
 *
 * .kr = Control Rate（コントロールレート）で動作
 *   音声信号より低いサンプリングレートで動作し、CPU負荷が低い
 */

// --- 6-1: 周波数を変化させる ---

// SinOsc.kr でビブラートを作る
// SinOsc.kr(5) = 5Hzで振動するコントロール信号（-1〜1の範囲）
// .range(400, 480) = -1〜1 を 400〜480 の範囲に変換
(
{
  var freq;
  // 5Hzのサイン波で400〜480Hzの間を行き来する（ビブラート）
  freq = SinOsc.kr(5).range(400, 480);
  SinOsc.ar(freq, mul: 0.3).dup(2);
}.play
)

// LFNoise1 でランダムに周波数を変化させる
(
{
  var freq;
  // 2Hzのレートでランダムに200〜800Hzの間を変化
  freq = LFNoise1.kr(2).range(200, 800);
  SinOsc.ar(freq, mul: 0.3).dup(2);
}.play
)

// XLine.kr で周波数を指数的に変化させる（glide / portamento 風）
(
{
  var freq;
  // 5秒かけて200Hzから2000Hzまで指数的に上昇
  freq = XLine.kr(200, 2000, 5);
  SinOsc.ar(freq, mul: 0.3).dup(2);
}.play
)

// --- 6-2: 音量（振幅）を変化させる ---

// SinOsc.kr でトレモロ（音量の揺れ）を作る
(
{
  var amp;
  // 4Hzのサイン波で音量を0〜0.5の範囲で揺らす（トレモロ）
  amp = SinOsc.kr(4).range(0, 0.5);
  SinOsc.ar(440, mul: amp).dup(2);
}.play
)

// --- 6-3: 周波数と音量の両方を同時に変化させる ---
(
{
  var freq, amp;
  freq = LFNoise1.kr(0.5).range(200, 800);  // ゆっくりランダムに周波数変化
  amp  = SinOsc.kr(3).range(0, 0.4);         // トレモロ
  SinOsc.ar(freq, mul: amp).dup(2);
}.play
)


// ================================================================
// SECTION 7: 音を混ぜる（加算）
// ================================================================
/*
 * 複数の音（UGenの信号）を混ぜるには、単純に + で足し合わせます。
 * ただし、音を重ねるほど音量が大きくなることに注意してください。
 *
 * 音量管理のポイント:
 * - 各音源の振幅を低くして混ぜる
 * - 最後に全体の音量を掛け合わせる
 */

// --- 7-1: 2つの音を足し合わせる ---
(
{
  var sig1, sig2;
  sig1 = SinOsc.ar(440, mul: 0.3).dup(2);  // A4: 440Hz
  sig2 = SinOsc.ar(660, mul: 0.3).dup(2);  // E5: 660Hz (5度上)
  sig1 + sig2;  // 単純に加算するだけでミックスできる
}.play
)

// --- 7-2: 倍音を重ねる（加算合成の入り口）---
(
{
  var sig1, sig2, sig3, freq, mul;
  freq = 220;
  mul  = 0.2;

  sig1 = SinOsc.ar(freq, mul: mul).dup(2);        // 基音（220Hz）
  sig2 = SinOsc.ar(freq * 2, mul: mul).dup(2);    // 第2倍音（440Hz）
  sig3 = SinOsc.ar(freq * 3, mul: mul).dup(2);    // 第3倍音（660Hz）

  // 3つの音を足し合わせる
  sig1 + sig2 + sig3;
}.play
)

// --- 7-3: ミックスした後に全体の音量を調整する ---
(
{
  var sig1, sig2, sig3, mix, freq;
  freq = 220;

  // 各音源を振幅1.0で生成
  sig1 = SinOsc.ar(freq).dup(2);
  sig2 = SinOsc.ar(freq * 2).dup(2);
  sig3 = SinOsc.ar(freq * 3).dup(2);

  // 足し合わせてから全体の音量を調整
  mix = sig1 + sig2 + sig3;
  mix * 0.2;  // 全体を0.2倍に
}.play
)


// ================================================================
// SECTION 8: エンベロープ
// ================================================================
/*
 * エンベロープ（Envelope）とは、音の時間的な変化（音量の形）のことです。
 *
 * リアルな楽器の音は、発音してから消えるまでの間に音量が変化します。
 * これをADSRと呼びます:
 *   A (Attack)  : 鍵盤を押してから最大音量に達するまでの時間
 *   D (Decay)   : 最大音量からサステインレベルに落ちるまでの時間
 *   S (Sustain) : 鍵盤を押し続けている間の音量レベル
 *   R (Release) : 鍵盤を離してから消えるまでの時間
 *
 * よく使うエンベロープ:
 *   Env.perc(attackTime, releaseTime)  : パーカッシブな形（ピアノ/打楽器）
 *   Env.adsr(a, d, s, r)               : ADSRエンベロープ（シンセサイザー）
 *   Env.asr(a, sustainLevel, r)        : アタック・サステイン・リリース
 *   Env.linen(a, sustainTime, r)       : 台形のエンベロープ
 */

// エンベロープの形をプロットして確認する
Env.perc(attackTime: 0.01, releaseTime: 1.0).plot;
Env.adsr(attackTime: 0.1, decayTime: 0.3, sustainLevel: 0.5, releaseTime: 1.0).plot;

// --- 8-1: パーカッシブなエンベロープ（Env.perc）---
// EnvGen.kr() でエンベロープ信号を生成し、音源に掛け合わせます
// doneAction: Done.freeSelf = エンベロープが終わったら自動的にSynthを解放
(
{
  var sig, env;
  env = EnvGen.kr(Env.perc(0.01, 1.5), doneAction: Done.freeSelf);
  sig = SinOsc.ar(440);
  sig = sig * env;      // 音源にエンベロープをかける
  sig.dup(2);
}.play
)

// 何度か実行して、打楽器のように鳴らしてみましょう
(
{
  var sig, env;
  env = EnvGen.kr(Env.perc(0.01, 1.5), doneAction: Done.freeSelf);
  sig = SinOsc.ar(440);
  (sig * env).dup(2);
}.play
)

// --- 8-2: ADSRエンベロープ ---
// gate引数で「鍵盤を押す/離す」を制御します
// gate = 1: 押した状態（アタック→サステイン）
// gate = 0: 離した状態（リリース開始）
(
f = {
  arg gate = 1;
  var sig, env;
  env = Env.adsr(attackTime: 0.1, decayTime: 0.3, sustainLevel: 0.5, releaseTime: 1.5);
  env = EnvGen.kr(env, gate, doneAction: Done.freeSelf);
  sig = SinOsc.ar(440);
  (sig * env * 0.5).dup(2);
};
)

// 再生（鍵盤を押した状態）
x = f.play;

// 少し待ってからリリース（鍵盤を離した状態）
x.set(\gate, 0);


// ================================================================
// SECTION 9: SynthDefによる楽器の作成
// ================================================================
/*
 * SynthDef（シンセサイザー定義）は、サーバーに「楽器の設計図」を登録する仕組みです。
 *
 * SynthDef を使う利点:
 * - 一度定義すれば、何度でも呼び出せる
 * - 引数を指定して音の高さや音量を変えられる
 * - Synth() を使って複数の音を同時に鳴らせる
 *
 * 構文:
 * SynthDef.new("名前", { 音の定義 }).add;
 * Synth("名前", [引数のリスト]);
 *
 * 重要: SynthDefの中では必ず Out.ar() を使って出力します。
 */

// --- 9-1: シンプルなSynthDefの定義 ---
(
SynthDef.new("SinTone",
  {
    arg out = 0,    // 出力バス（0 = スピーカーのL/R）
    freq = 440,     // 周波数
    amp  = 0.3;     // 音量

    var sig;
    sig = SinOsc.ar(freq, mul: amp);
    Out.ar(out, sig.dup(2));  // Out.ar でサーバーに出力
  }
).add;  // .add でサーバーに登録
)

// Synth() で鳴らす
x = Synth("SinTone");               // デフォルト設定で再生
y = Synth("SinTone", [\freq: 660]); // 660Hzで再生
z = Synth("SinTone", [\freq: 880, \amp: 0.2]); // 880Hz、小さめの音量

// 停止
x.free;
y.free;
z.free;

// --- 9-2: エンベロープ付きのSynthDef（完全な楽器の定義）---
(
SynthDef.new("SinNote",
  {
    arg out = 0,
    freq = 440,
    amp  = 0.5,
    attk = 0.01,   // アタックタイム
    rel  = 1.0,    // リリースタイム
    gate = 1;      // ゲート制御

    var sig, env;

    // ADSRエンベロープ
    env = Env.adsr(attk, 0.2, 0.7, rel);
    env = EnvGen.kr(env, gate, doneAction: Done.freeSelf);

    sig = SinOsc.ar(freq);
    sig = sig * env * amp;
    Out.ar(out, sig.dup(2));
  }
).add;
)

// さまざまな音高で演奏
a = Synth("SinNote", [\freq: 261.63, \amp: 0.4]);  // C4
b = Synth("SinNote", [\freq: 329.63, \amp: 0.4]);  // E4
c = Synth("SinNote", [\freq: 392.00, \amp: 0.4]);  // G4（Cメジャーコード）

// リリース
a.set(\gate, 0);
b.set(\gate, 0);
c.set(\gate, 0);


// ================================================================
// SECTION 10: 加算合成 — 倍音を重ねる
// ================================================================
/*
 * 加算合成（Additive Synthesis）とは、多数のサイン波を重ねることで
 * 複雑な音色を作り出す合成方式です。
 *
 * 基音 f に対して倍音は: f, 2f, 3f, 4f, 5f, ...
 * 各倍音の振幅バランスが音色の特徴を決定します。
 *
 * 例: 鋸波（Saw波）= 1/1 + 1/2 + 1/3 + 1/4 + ... の倍音を持つ
 *     矩形波（Square波）= 奇数倍音のみ 1/1 + 1/3 + 1/5 + ...
 */

// --- 10-1: 手動で倍音を重ねる ---
(
SynthDef("AddSynth_Manual",
  {
    arg out = 0, freq = 110, amp = 0.5, gate = 1;
    var sig = 0, env;

    // 4つの倍音を重ねる（振幅は自然倍音列に倣って 1/n）
    sig = sig + SinOsc.ar(freq * 1, mul: 1.0 / 1);  // 基音
    sig = sig + SinOsc.ar(freq * 2, mul: 1.0 / 2);  // 第2倍音
    sig = sig + SinOsc.ar(freq * 3, mul: 1.0 / 3);  // 第3倍音
    sig = sig + SinOsc.ar(freq * 4, mul: 1.0 / 4);  // 第4倍音

    env = EnvGen.kr(Env.asr(0.01, 1.0, 1.5), gate, doneAction: 2);
    sig = sig.dup(2) * env * amp * 0.2;  // 倍音の合計で振幅が増えるので調整
    Out.ar(out, sig);
  }
).add;
)

x = Synth("AddSynth_Manual", [\freq: 110, \amp: 0.4]);
y = Synth("AddSynth_Manual", [\freq: 220, \amp: 0.3]);
x.set(\gate, 0);
y.set(\gate, 0);

// --- 10-2: Klang UGenを使った加算合成（効率的な方法）---
/*
 * Klang は多数のサイン波を効率的に生成するUGenです。
 * 周波数、振幅、位相の配列を渡すだけで、指定した数のサイン波をミックスします。
 *
 * Klang.ar( `[ freqs, amps, phases ] )
 *   freqs  : 周波数の配列
 *   amps   : 振幅の配列
 *   phases : 位相の配列
 *   バッククォート(`) で配列をUGenグラフに埋め込む
 */
(
SynthDef("AddSynth_Klang",
  {
    arg out = 0, amp = 0.5, gate = 1;
    var num = 30, sig, env, freqs, amps, phases;

    // ランダムな周波数・振幅の倍音を30個生成
    freqs  = Array.exprand(num, 80, 12000).sort;     // 80〜12000Hzの範囲でランダム
    amps   = Array.exprand(num, 0.002, 0.05).sort.reverse; // 低域を強調
    phases = Array.rand(num, 0, 2pi);                // ランダムな位相

    sig = Klang.ar(`[freqs, amps, phases]);
    sig = sig.dup(2);

    env = EnvGen.kr(Env.asr(1.0, 1.0, 3.0), gate, doneAction: 2);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }
).add;
)

x = Synth("AddSynth_Klang", [\amp: 0.5]);
// 別の音（ランダムなので毎回違う響き）
y = Synth("AddSynth_Klang", [\amp: 0.3]);

x.set(\gate, 0);
y.set(\gate, 0);

// --- 10-3: DynKlang — 動的に変化する加算合成 ---
/*
 * DynKlang は Klang の動的版。
 * 各倍音の周波数・振幅をリアルタイムに変化させることができます。
 * LFOなどのコントロール信号で変調することで、
 * 時間とともにうごめくような複雑なサウンドを作れます。
 */
(
SynthDef("AddSynth_DynKlang",
  {
    arg out = 0, amp = 0.5, gate = 1;
    var num = 30, sig, env, freqs, amps, phases;

    // ベースとなる周波数・振幅・位相を生成
    freqs  = Array.exprand(num, 80, 8000).sort;
    amps   = Array.exprand(num, 0.005, 0.1).sort.reverse;
    phases = Array.rand(num, 0, 2pi);

    // LFNoise1.kr で周波数と振幅をゆっくり変調（DynKlangで動的に変化）
    sig = DynKlang.ar(`[
      freqs  * LFNoise1.kr(0.05 ! num).exprange(0.5, 2.0),  // 周波数を揺らす
      amps   * LFNoise1.kr(0.5  ! num).exprange(0.1, 1.0),  // 振幅を揺らす
      phases
    ]);

    sig = sig.dup(2);
    env = EnvGen.kr(Env.asr(3.0, 1.0, 5.0), gate, doneAction: 2);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }
).add;
)

x = Synth("AddSynth_DynKlang", [\amp: 0.4]);
x.set(\gate, 0);


// ================================================================
// SECTION 11: 変調合成
// ================================================================
/*
 * 変調合成では、一方のオシレーター（モジュレーター）の出力を
 * もう一方のオシレーター（キャリア）のパラメータに使って音色を作ります。
 *
 * 3種類の基本的な変調合成:
 * - AM (Amplitude Modulation): 振幅変調 — モジュレーターで振幅を変化
 * - RM (Ring Modulation):      リング変調 — AM変調の特殊な形
 * - FM (Frequency Modulation): 周波数変調 — モジュレーターで周波数を変化
 */

// --- 11-1: AM変調（振幅変調）---
/*
 * モジュレーター信号の範囲を 0〜1 にマッピングして
 * キャリアの振幅に掛け合わせます。
 *
 * 生成される側波帯: キャリア周波数 ± モジュレーター周波数
 * （例: キャリア 500Hz + モジュレーター 100Hz → 400Hz, 500Hz, 600Hz）
 */

// AM変調の効果を視覚的に確認（freqscope でスペクトルを表示）
(
{
  var sig, mod, modHz;
  modHz = XLine.kr(1, 3000, 10);     // 1〜3000Hzまで変化するモジュレーター周波数
  mod   = SinOsc.ar(modHz).range(0, 1);  // 0〜1の範囲にマッピング（AM）
  sig   = SinOsc.ar(6000, mul: mod); // キャリア6000Hz
  sig.dup(2);
}.freqscope
)

// AM変調のシンセサイザー
(
SynthDef("AmSynth",
  {
    arg out = 0, gate = 1,
    freq    = 440,   // キャリア周波数（音の高さ）
    modFreq = 100,   // モジュレーター周波数（側波帯を決定）
    amp     = 0.5;

    var sig, env, mod;

    // モジュレーターを0〜1の範囲で生成（古典的AM）
    mod = SinOsc.ar(modFreq).range(0, 1);

    // キャリアのサイン波の振幅にモジュレーターを適用
    sig = SinOsc.ar(freq, mul: mod);
    sig = sig.dup(2);

    env = EnvGen.kr(Env.perc(0.01, 1.5), gate, doneAction: 2);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }
).add;
)

// モジュレーター周波数による音色の変化を聴き比べる
Synth("AmSynth", [\freq: 440, \modFreq: 20]);   // うなり音
Synth("AmSynth", [\freq: 440, \modFreq: 110]);  // 金属的な音
Synth("AmSynth", [\freq: 440, \modFreq: 440]);  // より金属的
Synth("AmSynth", [\freq: 440, \modFreq: 1000]); // さらに複雑な音色

// --- 11-2: RM変調（リング変調）---
/*
 * AMとの違い: モジュレーターを -1〜1 の範囲のまま使います（range調整なし）。
 * 結果として、キャリア周波数の成分が消え、側波帯のみが残ります。
 *
 * 生成される側波帯: キャリア ± モジュレーター の2成分のみ
 */
(
SynthDef("RmSynth",
  {
    arg out = 0, gate = 1,
    freq    = 440,
    modFreq = 100,
    amp     = 0.5;

    var sig, env, mod;

    // モジュレーターをそのまま使う（-1〜1の範囲）
    mod = SinOsc.ar(modFreq);

    // キャリアの振幅にモジュレーターを掛ける（RM変調）
    sig = SinOsc.ar(freq, mul: mod);
    sig = sig.dup(2);

    env = EnvGen.kr(Env.perc(0.01, 1.5), gate, doneAction: 2);
    sig = sig * env * amp;
    Out.ar(out, sig);
  }
).add;
)

// AMとRMの音色の違いを聴き比べる
Synth("AmSynth", [\freq: 440, \modFreq: 110, \amp: 0.4]);  // AM
Synth("RmSynth", [\freq: 440, \modFreq: 110, \amp: 0.4]);  // RM

// --- 11-3: FM変調（周波数変調）---
/*
 * モジュレーターの出力をキャリアの「周波数」に加算します。
 * これにより豊かな倍音を持つ複雑な音色が生まれます。
 *
 * 重要なパラメーター:
 * - C:M比（Carrier:Modulator ratio）: キャリアとモジュレーターの周波数比
 *   整数比 → 倍音が調和的（音楽的な音色）
 *   非整数比 → 非調和音（ベル、金属的な音）
 * - 変調インデックス（index）: 変調の深さ
 *   小さい → 少ない倍音（純音に近い）
 *   大きい → 豊かな倍音（明るく複雑な音色）
 *   変調深度（Hz）= index × モジュレーター周波数
 */

// FMの効果を視覚的に確認
(
{
  var sig, mod, modHz;
  modHz = XLine.kr(1, 1000, 10);    // 1〜1000Hzまで変化するモジュレーター周波数
  mod   = SinOsc.ar(modHz, mul: 500); // 変調深度=500Hz
  sig   = SinOsc.ar(6000 + mod);    // キャリア周波数にモジュレーターを加算（FM）
  (sig * 0.2).dup(2);
}.freqscope
)

// FMシンセサイザー（基本形）
(
SynthDef("FmSynth_Basic",
  {
    arg out = 0,
    carFreq = 440,   // キャリア周波数（音の高さ）
    ratio   = 1.0,   // C:M比（整数比で倍音的、非整数で非倍音的）
    index   = 3,     // 変調インデックス（大きいほど複雑な音色）
    dur     = 1.0,   // 音の長さ
    amp     = 0.5;

    var mod, car, env, sig, modFreq;

    // モジュレーター周波数 = キャリア周波数 × C:M比
    modFreq = carFreq * ratio;

    // モジュレーター: 変調深度 = index × modFreq
    mod = SinOsc.ar(modFreq, mul: index * modFreq);

    // キャリア: 周波数にモジュレーターを加算
    car = SinOsc.ar(carFreq + mod);

    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = car * env * amp;
    Out.ar(out, sig.dup(2));
  }
).add;
)

// C:M比による音色の変化（整数比 vs 非整数比）
Synth("FmSynth_Basic", [\carFreq: 220, \ratio: 1.0, \index: 3, \dur: 2, \amp: 0.3]);   // 同じ周波数（明るい音）
Synth("FmSynth_Basic", [\carFreq: 220, \ratio: 2.0, \index: 3, \dur: 2, \amp: 0.3]);   // 2倍（1オクターブ上）
Synth("FmSynth_Basic", [\carFreq: 220, \ratio: 1.5, \index: 5, \dur: 2, \amp: 0.3]);   // 3:2 (5度)
Synth("FmSynth_Basic", [\carFreq: 220, \ratio: 1.414, \index: 10, \dur: 2, \amp: 0.3]); // √2 (ベル的)

// インデックスによる音色の変化
Synth("FmSynth_Basic", [\carFreq: 330, \ratio: 1.0, \index: 1, \dur: 3, \amp: 0.3]);   // インデックス低 → 純音に近い
Synth("FmSynth_Basic", [\carFreq: 330, \ratio: 1.0, \index: 5, \dur: 3, \amp: 0.3]);   // インデックス中 → 明るい音
Synth("FmSynth_Basic", [\carFreq: 330, \ratio: 1.0, \index: 20, \dur: 3, \amp: 0.3]);  // インデックス高 → 非常に明るい音


// ================================================================
// SECTION 12: 本格的な楽器をデザインする
// ================================================================
/*
 * ここまで学んだ技術を組み合わせて、より本格的な楽器をデザインします。
 *
 * キーとなるアイデア:
 * - 複数の音源を組み合わせる
 * - エンベロープで音量変化だけでなく音色変化も作る
 * - LFOでビブラートやトレモロを追加する
 * - エフェクト（フィルター、リバーブ）で空間感を加える
 */

// --- 12-1: より表情豊かなFMシンセサイザー ---
/*
 * 変調インデックス自体をエンベロープで変化させることで、
 * 時間とともに音色が変化するリアルな楽器の振る舞いを模倣できます。
 * （例: ピアノは最初は倍音豊か → 時間とともに純音に近くなる）
 */
(
SynthDef("FmSynth_Expressive",
  {
    arg out = 0,
    gate    = 1,
    carFreq = 440,
    ratio   = 1.0,
    index   = 8,         // インデックスの最大値
    attk    = 0.01,
    rel     = 2.0,
    amp     = 0.5;

    var mod, car, sig, env, idxEnv, modFreq, modDepth;

    modFreq = carFreq * ratio;

    // インデックスをエンベロープで制御（発音直後は高い → 徐々に低くなる）
    // これで「最初は倍音豊か→消えるにつれて柔らかくなる」効果が得られる
    idxEnv  = EnvGen.kr(Env.perc(0.001, rel * 1.5), gate).range(0, index);
    modDepth = modFreq * idxEnv;
    mod = SinOsc.ar(modFreq, mul: modDepth);

    // 音量エンベロープ
    env = EnvGen.kr(Env.adsr(attk, 0.3, 0.6, rel), gate, doneAction: 2);

    car = SinOsc.ar(carFreq + mod);
    sig = car * env * amp;

    // リバーブを追加して空間感を演出
    sig = GVerb.ar(sig.dup(2), 30, 2.0) * 0.8;
    Out.ar(out, sig);
  }
).add;
)

// ベル的な音色（非整数比）
x = Synth("FmSynth_Expressive", [\carFreq: 440, \ratio: 1.414, \index: 12, \rel: 4.0, \amp: 0.3]);
y = Synth("FmSynth_Expressive", [\carFreq: 330, \ratio: 1.414, \index: 12, \rel: 4.0, \amp: 0.3]);

x.set(\gate, 0);
y.set(\gate, 0);

// --- 12-2: SuperSawシンセサイザー ---
/*
 * SuperSawはEDMやトランスなどのジャンルで定番のサウンドです。
 * 複数のノコギリ波（Saw）をわずかにデチューン（音程をずらす）して
 * 重ねることで、豊かな厚みのある音を作ります。
 */
(
SynthDef("SuperSaw",
  {
    arg out    = 0,
    gate       = 1,
    freq       = 440,    // 基本周波数
    detune     = 0.15,   // デチューン量（値が大きいほどコーラス感が強い）
    cutoff     = 3000,   // フィルターカットオフ周波数
    resonance  = 0.3,    // フィルターレゾナンス
    attk       = 0.01,
    decay      = 0.2,
    sustain    = 0.7,
    rel        = 1.0,
    amp        = 0.4;

    var sig, env, voices = 5;  // Saw波の数（多いほど厚くなる）

    // 複数のSaw波を生成してミックス（各波を少しずつデチューン）
    sig = Mix.fill(voices, { arg i;
      // -detune 〜 +detune の範囲でデチューン（均等に分散）
      var detuneAmount = detune * (i - ((voices - 1) / 2)) / (voices - 1);
      Saw.ar(freq * (1 + detuneAmount));
    });

    // 音量エンベロープ（ADSR）
    env = EnvGen.kr(Env.adsr(attk, decay, sustain, rel), gate, doneAction: 2);

    // ローパスフィルターで音色を整える（音の丸みを作る）
    sig = RLPF.ar(sig, cutoff, resonance);

    // ステレオ化（少し広がりを持たせる）
    sig = sig.dup(2);

    // エンベロープと音量を適用
    sig = sig * env * amp * (1.0 / voices);  // voices数で正規化

    // リバーブで空間感を追加
    sig = GVerb.ar(sig, 30, 1.5) * 0.7;

    Out.ar(out, sig);
  }
).add;
)

// 和音（コード）で鳴らす
(
var freqs = [261.63, 329.63, 392.00];  // Cメジャーコード (C4, E4, G4)
~supersaw = freqs.collect { |f|
  Synth("SuperSaw", [\freq: f, \detune: 0.2, \cutoff: 2500, \amp: 0.25]);
};
)

// 停止
~supersaw.do { |s| s.set(\gate, 0) };

// パッドサウンドとして（長いアタックとリリース）
(
var freqs = [220, 277.18, 329.63];  // Aマイナーコード (A3, C#4, E4)
~pad = freqs.collect { |f|
  Synth("SuperSaw", [
    \freq: f,
    \detune: 0.25,
    \attk: 2.0,     // ゆっくり立ち上がる
    \decay: 1.0,
    \sustain: 0.8,
    \rel: 4.0,      // ゆっくり消える
    \cutoff: 1500,
    \amp: 0.2
  ]);
};
)

~pad.do { |s| s.set(\gate, 0) };


// ================================================================
// まとめ と 次のステップ
// ================================================================
/*
 * このチュートリアルで学んだこと:
 *
 * 1. SinOsc.ar() — 最初の一音
 * 2. .dup(2) — ステレオ化
 * 3. mul 引数 — 音量の変更
 * 4. freq 引数 — 周波数（音高）の変更
 * 5. var, ~env — 変数の使い方
 * 6. SinOsc.kr, LFNoise1.kr — コントロール信号で変化させる
 * 7. + 演算子、Mix — 音を混ぜる
 * 8. Env, EnvGen — エンベロープで時間変化を作る
 * 9. SynthDef, Synth — 楽器として定義して演奏する
 * 10. Klang, DynKlang — 効率的な加算合成
 * 11. AM, RM, FM — 変調合成
 * 12. SuperSaw, FMシンセ — 本格的な楽器のデザイン
 *
 * 次のステップとして探求できるテーマ:
 * - Pbind / Patterning — シーケンサーとパターンによる自動演奏
 * - Buffer / SamplePlayer — サンプル音源の再生
 * - Bus / Effect Chain — エフェクトのルーティング
 * - OSC — 外部アプリケーションとの連携
 * - Granular Synthesis — グラニュラー合成
 */
