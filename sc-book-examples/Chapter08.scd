// 第8章

/*
 * list-8_01
 */
// 環境の準備
(
// サーバーの起動
s.boot;
// ProxySpaceの初期化
p = ProxySpace.push(s);
)

/*
 * list-8_02
 */
// ~outを再生状態に
// まだ何も定義されていないので無音、音を受け取る準備ができた状態
~out.play;

// ~outにサイン波を生成する関数を定義します。音が聞こえ始める
~out = { SinOsc.ar([220, 222], 0, 0.2) };

// 定義を差し替えます（ホットスワップ）。内部的にクロスフェードが行われ、
// 音が途切れることなく滑らかに変化する
~out = {SinOsc.ar([444, 440], 0, 0.2)};
~out = {RLPF.ar(Blip.ar([55, 56], 20, 0.4), LFNoise2.ar(1.0).range(100, 800), 0.2)};
~out = {Pan2.ar(BrownNoise.ar(0.3), LFNoise0.ar(4.0).range(-1, 1))};

/*
 * list-8_03
 */
// rateという引数を持つ音源を定義。デフォルト値は1
(
~out = {
  arg rate = 1;
  Pan2.ar(SinOsc.ar(880, 0.0, 0.2),Pulse.ar(rate).range(-1, 1));
};
)

// .setメソッドを使い、rateの値を4に変更
// \rateというシンボルで引数を指定
~out.set(\rate, 4);

// ホットスワップで別の音源に差し替え
// この新しい音源もrateという引数を持っているので、先ほどの.set(4)が維持される
// JITLibはプロキシに設定された値を記憶し、新しいソースにも適用しようと試みる
(
~out = {
  arg rate = 1;
  Pan2.ar(BrownNoise.ar(0.2), Pulse.ar(rate).range(-1, 1))};
)

// rateの値をデフォルトの1に戻す
~out.set(\rate, 1);

/*
 * list-8_04
 */
// LFO（低周波発振器）として機能するプロキシ~lfoを定義
~lfo = { LFNoise2.kr(4, 100, 400) };

// ~outの定義の中で、~lfoのコントロールレート出力（.kr）を参照
// これで~lfoが~outの周波数をコントロールする
~out = { SinOsc.ar(~lfo.kr * [1.0, 1.1], 0, 0.2) };

// ~outの定義をより複雑なものにホットスワップする
// ~lfoへの参照はそのままなので、~lfoが複数のパラメータを同時に制御
~out = { SinOsc.ar(~lfo.kr * [1.0, 1.1], 0, 0.2) * Saw.ar(~lfo.kr * 0.01, 0.5) };

// ~lfoの定義自体もホットスワップできる
// ~outの音も追従してリアルタイムに変化する。これにより、モジュレーションの様相だけを変更できる
~lfo = { LFNoise1.kr(30, 40) + SinOsc.kr(0.1, 0, 200, 500) };

// ~outの定義をシンプルなものに戻す
~out = { SinOsc.ar(~lfo.kr * [1, 1.1], 0, 0.2) };

// プロキシに数値を直接代入することも可能
// これにより~lfoは定数440を出力するコントロールレートのプロキシになります。
~lfo = 440;

/*
 * list-8_05
 */
// 単項演算子：.absは絶対値を取る
~lfo2 = { SinOsc.kr(0.5, 0, 600, 100) };
~lfo = ~lfo2.abs; // ~lfoは、~lfo2の出力の絶対値を取るプロキシになる
~lfo2 = { SinOsc.kr(1.3, 0, 600, 100) }; // ~lfo2の定義を変えると、~lfoの振る舞いも即座に変わります。

// 二項演算子：プロキシ同士を足し算する
~lfo3 = { LFTri.kr(0.5, 0, 80, 300) };
~lfo = ~lfo2 + ~lfo3; // ~lfo2と~lfo3の出力をミックスした結果が~lfoになる
~lfo = ~lfo3; // ~lfoのソースを~lfo3のみに差し替える

// 複雑な組み合わせも可能
// あるプロキシの出力を別のプロキシのパラメータに使うといった、自己言及的な構造も作れる
~lfo = (~lfo3 / 50).sin * 200 + 500 * { LFTri.kr(~lfo.kr * 0.0015, 0, 0.1 * ~lfo3.kr / 90, 1) };
~lfo3 = { Mix(~lfo2.kr * [1, 1.2]) };

// サーバー上の全てのノードを一度に解放
currentEnvironment.free;
~out.stop; // モニター用のシンセ（~out.playで生成されたもの）を停止

/*
 * list-8_06
 */
// Cmd+. を押して、全てのノードを停止させる

// 再び~outを再生状態にする
// ~outは~lfoを参照し、~lfoは~lfo2と~lfo3を参照しているので、
// 関連する全てのプロキシが再起動する
~out.play;

/*
 * list-8_07
 */
// ~out自身のオーディオレート出力（.ar）を、自身の周波数変調の入力として使う
~out = { SinOsc.ar([220, 330], ~out.ar(2).reverse * LFNoise2.kr(0.5, 4pi), 0.4) };

// 自身の出力を0.99倍して足し合わせることで、減衰するディレイのような効果を作る
~out = { Pan2.ar(Impulse.ar(1), LFNoise0.kr(2)) + (~out.ar(2).reverse * 0.99) };


// SuperColliderによる「微分方程式」的な表現
// Slopeは信号の時間変化率（傾き）を計算するUGenで、これを利用して複雑な振る舞いを生成
~out = { SinOsc.ar(Slope.ar(~out.ar) * MouseX.kr(1000, 18000, 1)) * 0.1 + SinOsc.ar(100, 0, 0.1) };

(
~out = { var z, zz;
  z = Slope.ar(~out.ar); // 1階微分
  zz = Slope.ar(z);      // 2階微分
  SinOsc.ar(Rand(300,410), z) *
  SinOsc.ar(zz * 410)
  * 0.1 + Decay2.ar(Pan2.ar(Dust.ar(600), MouseX.kr(-1,1)), 0.01, 0.05);
}
)

/*
 * list-8_08
 */
// `Control.names(\array)`で、`array`という名前でアクセス可能なコントロールバスの配列を作成
(
~out = { arg freqOffest;
  var ctl;
  ctl = Control.names(\array).kr(Array.rand(8, 200, 2000));
  Pan2.ar(Mix(SinOsc.ar(ctl + freqOffest, 0, 0.5/8)), LFNoise0.kr(2))
};
)

// .setnで`array`という名前のコントロールバスに、新しい配列の値をまとめて設定
~out.setn(\array, Array.exprand(8, 100, 800));
~out.set(\freqOffest, rrand(300,200));
~out.map(\freqOffest, ~lfo); // マッピングも可能
~out.map(\freqOffest, 0); // オフセットを0にリセット

// よりシンプルなショートカット記法。argで直接配列を定義できる
(
~out = { arg freqOffest=0, array = #[ 997, 777, 506, 553, 731, 891, 925, 580 ];
  Pan2.ar(Mix(SinOsc.ar(array + freqOffest, 0, 0.5 / 8)), LFNoise0.kr(2))
};
)

/*
 * list-8_09
 */
~out1 = { SinOsc.ar(220, 0, 0.1) };
~out2 = { SinOsc.ar(330, 0, 0.1) };
~out3 = { SinOsc.ar(550, 0, 0.1) };

// 方法1：プロキシ同士を+演算子で足し算する。最も直感的で、複数のソースを一度にミックスできる
~out = ~out2 + ~out1 + ~out3;

~out = ~out1 + ~out2;
~out = ~out1;

// 方法2：.addメソッドを使う。既存のプロキシに新しいソースをレイヤーとして追加する
~out = { SinOsc.ar(220, 0, 0.1) };
~out.add({ SinOsc.ar(330, 0, 0.1) });
~out.add({ SinOsc.ar(550, 0, 0.1) });

// 方法3：インデックスを指定して直接アクセスする
// ~out[0]が最初のソース、~out[1]が次のソースというように、スロットとして扱う
// これにより、特定のレイヤーだけを差し替えるといった操作が容易になる
~out[1] = { SinOsc.ar(660 * 1.2, 0, 0.1) };
~out[2] = { SinOsc.ar(880 * 1.2, 0, 0.1) };

/*
 * list-8_10
 */
~out.free; // プロキシが占有しているサーバー上のグループを解放するが、再生モニターは残る
~out.send; // プロキシの状態をサーバーに再送し、音を復元する
~out.free;
~out.send(nil, 1); // インデックス1のスロットにあるシンセのみを再送する
~out.send;

// 構成要素（スロット）の削除
~out.removeLast; // 最後のスロットを削除
~out.removeAt(0); // インデックス0のスロットを削除

// クリーンアップ
// プロキシを中和し、バスを解放する。プロキシ自体は環境に残るが、音は出なくなる
~out.clear;

/*
 * list-8_11
 */
~out.play;
~out = { Pan2.ar(SinOsc.ar(~lfo.kr, 0, 0.2), sin(~lfo.kr / 10)) }; // ~lfoは~outから参照されているので「親」として扱われる
~lfo = { LFNoise2.kr(3, 160, 400) };

p.keysValuesDo { arg key, proxy; [key, proxy.isPlaying].postln }; // 現在のプロキシの状態を確認する
p.reduce; // モニタリング中のプロキシ（~out）とその親（~lfo）だけが保持され、他は解放される
p.keysValuesDo { arg key, proxy; [key, proxy.isPlaying].postln }; // 再度確認する

// 他のすべてを削除
p.clean; // モニタリング中のプロキシは保持される

// モニターを止めると、そのプロキシもクリーンアップの対象になる
~out.stop;
p.clean;
p.postln; // ProxySpaceが空になったことを確認できる

/*
 * list-8_12
 */
~myOut.play; // まだ定義されていないが、オーディオレートと仮定して再生を開始

// ~freqがコントロールレート（.kr）で初めて参照されるため、~freqはコントロールレートのプロキシになる
~myOut = { SinOsc.ar(~freq.kr * 2, 0, 0.1) };
~freq = 900;
~freq = { SinOsc.kr(115, 0, 70, 220) }

// 一方、.arで参照すればオーディオレートのプロキシになる
~myOut = { SinOsc.ar(~otherFreq.ar * 2, 0, 0.1) };
~otherFreq = { SinOsc.ar(115, 0, 70, 220) };

currentEnvironment.clear; // 環境内の全てのプロキシをクリアする

/*
 * list-8_13
 */
~out.play;

// フェード時間を4秒に設定
~out.fadeTime = 4;
~out = { SinOsc.ar(Rand(800, 300.0) * [1,1.1], 0, 0.1) }; // 4秒かけてゆっくりと音色が変化
~out = { SinOsc.ar(Rand(800, 300.0) * [1,1.1], 0, 0.1) };

// フェード時間を0.01秒に設定
~out.fadeTime = 0.01;
~out = { SinOsc.ar(Rand(800, 300.0) * [1,1.1], 0, 0.1) }; // ほとんど瞬時に音色が変化
~out = { SinOsc.ar(Rand(800, 300.0) * [1,1.1], 0, 0.1) };

// .free(time)を使うと、プロキシのfadeTimeを変更せず、指定した時間で解放できる
~out.free(3);
~out.stop;      // モニターを停止

/*
 * list-8_14
 */
~out.play;

// 基本的な設定
~out = { arg freq=500, ffreq=120; SinOsc.ar(freq*[1,1.1], SinOsc.ar(ffreq, 0, pi), 0.2) };
~out.set(\freq, 400 + 100.rand2);
~out.set(\ffreq, 30 + 20.rand2);
~out.set(\ffreq, 30 + 10.rand2, \freq, 500 + 200.rand2);


// 一度設定したパラメータやマッピングは、新しい関数にも引き継がれる
~out = { arg freq=100, ffreq=20; SinOsc.ar(freq, SinOsc.ar(SinOsc.ar(ffreq)*ffreq, 0, pi), 0.2) };

// 他のプロキシへのマッピング
~lfo = { SinOsc.kr(0.3, 0, 80, 100) };
~out.map(\ffreq, ~lfo);

// クロスフェードを伴う設定とマッピング：.xset, .xmap
~out.fadeTime = 2;
~out.xset(\freq, 9000); // 2秒かけて値を変更する
~lfo2 = { LFClipNoise.kr(3, 100, 200) };
~out.xmap(\ffreq, ~lfo2); // 2秒かけてマッピング先を変更する

/*
 * list-8_15
 */
~out.play;

// gate引数を持つSynthDefは、ホットスワップ時に自動的にフェードイン・アウトする
// doneAction: Done.freeSelfは、エンベロープが終了した際にSynthを自動解放するおまじない
(
~out = SynthDef("w", { arg out=0, gate=1.0, fadeTime = 0.1;
  Out.ar(out,
    SinOsc.ar([Rand(430, 800), Rand(430, 800)], 0, 0.2)
    * EnvGen.kr(Env.asr(fadeTime, 1, fadeTime), gate, doneAction: Done.freeSelf)
  )
});
)

// SynthDefを.addでライブラリに追加しておけば、名前（シンボル）で指定できる
(
SynthDef("staub", { arg out, gate=1, fadeTime = 0.1;
  Out.ar(out,
    Ringz.ar(Dust.ar(15), Rand(1, 3) * 3000*[1,1], 0.001)
    * EnvGen.kr(Env.asr(fadeTime, 1, fadeTime), gate, doneAction: Done.freeSelf)
  )
}).add;
)
~out = \staub;

// doneActionを持つSynthDefは、.spawnで個別のイベント（グレイン）を発生させられる
(
~out = SynthDef("w", { arg out, lfo, f0=430;
  Out.ar(out,
    SinOsc.ar([Rand(f0, 800), Rand(f0, 800)]+lfo, 0, 0.2)
    * EnvGen.kr(Env.perc(0.01, 0.03), doneAction: Done.freeSelf)
  )
});
)
~out.spawn; // Synthを一度だけトリガーする
fork { 5.do { ~out.spawn([\f0, 5000 + 1000.0.rand]); 0.1.wait; } }

// プロキシに0やnilを代入すると、それぞれ無音や停止といった操作になる
~out = 0;   // 無音を再生
~out = nil; // プロキシを停止し、オブジェクトを削除

/*
 * list-8_16
 */
(
SynthDef(\who, { arg amp=0.1, freq=440, detune=0, gate=1, out=0, ffreq=800;
  var env = Env.asr(0.01, amp, 0.5);
  Out.ar(out, Pan2.ar(
    Formant.ar(freq + detune, ffreq, 30, EnvGen.kr(env, gate, doneAction: Done.freeSelf)), Rand(-1.0, 1.0))
  )
}).add;
)

~out.play;
~out = Pbind(\instrument, \who, \freq, [600, 601], \ffreq, 800, \legato, 0.02);

// パターンの中にコントロールプロキシを埋め込むこともできる
~lfo = { SinOsc.kr(2, 0, 400, 700) };
~out = Pbind(\instrument, \who, \freq, 500, \ffreq, ~lfo, \legato, 0.02);

// lfoをホットスワップすると、パターンの演奏内容もリアルタイムに変化する
~lfo = { LFNoise1.kr(5, 1300, 1500) };
~lfo = { MouseX.kr(100, 5500, 1) };

// パターンもクロスフェードする
~out.fadeTime = 3.0;
(
~out = Pbind(
  \instrument, \who,
  \freq, Pshuf([500, 380, 200, 510, 390, 300, 300],inf) * rrand(1.0, 2.0),
  \legato, 0.1,
  \ffreq, Pshuf([~lfo, 100, ~lfo, 100, 300, 550], inf),
  \dur, 0.125 * [1, 2, 3, 2/3].choose
);
)

/*
 * list-8_17
 */
p = ProxySpace.push(s.boot);

~out = { SinOsc.ar(~a.kr * Rand(1, 2), 0, 0.1) };
~out.play;

// ~aに数値を代入する。~aは900という定数を出力するコントロールレートのプロキシになる
~a = 900;

// ~aの各インデックスにソースを代入すると、それらが足し合わされる
// ~aの出力は 440 + 220 + 20 = 680 となる
~a[0] = 440;
~a[1] = 220;
~a[2] = 20;

~a.fadeTime = 2;

// インデックス0の値を変更すると、クロスフェードする
~a[0] = 300;
// インデックス1を数値から関数にホットスワップすることもできる
~a[1] = { SinOsc.kr(5, 0, 20) };
~a[2] = { SinOsc.kr(30, 0, 145) };

/*
 * list-8_18
 */
s.boot;// サーバーの起動
p = ProxySpace.push(s);// ProxySpaceの初期化

(
// 楽器 "mySaw" を定義し追加
SynthDef("mySaw", {
  arg out = 0, freq = 440, sustain = 1.0,
  cutoff = 2000, rq = 0.3, pan = 0.0, amp = 1.0;
  var sig;
  sig = LFSaw.ar(
    freq, mul: EnvGen.kr(
      Env.perc(), levelScale: amp, timeScale: sustain, doneAction: 2)
  );
  sig = RLPF.ar(sig,LFNoise1.kr(1, cutoff / 2, cutoff).abs, rq);
  sig = Pan2.ar(sig, pan);
  4.do({ sig = AllpassN.ar(sig, 0.05, [0.05.rand, 0.05.rand], 4) });
  Out.ar(out, sig);
}).add;
)

~out.play(vol:2.0); // 再生の準備（音量2.0）
~out.fadeTime = 8.0; // フェードタイムを8秒に
~out.quant = 4; // 再生タイミングのクオンタイズ（4拍待って変更）

/*
 * list-8_19
 */
// 最初のフレーズ
~out = Pbind(\instrument, \mySaw, \freq, 110)

// 少しずつパラメーターを追加していく
(// シーケンス 0
~out = Pbind(
  \instrument, \mySaw,
  \freq, Pseq([55, 110, 220], inf))
)

/*
 * list-8_20
 */
(// シーケンス 1
~out = Pbind(
  \instrument, \mySaw,
  \freq,
  Prand([55, 110, 220], inf)
  * Prand([[1, 1],[0.5, 1],[1, 1.5]],inf)
  * Prand([1, 2, 3],inf))
)

/*
 * list-8_21
 */
(// シーケンス 2
~out = Pbind(
  \instrument, \mySaw,
  \freq,
  Prand([55, 110, 220], inf)
  * Prand([[1, 1],[0.5, 1],[1, 1.5]],inf)
  * Prand([1, 2, 3],inf),
  \dur, Prand([1/8, 1/4, 1/2], inf),
  \legato, Pexprand(1.0, 3.0, inf))
)

/*
 * list-8_22
 */
(// シーケンス 3
~out = Pbind(
  \instrument, \mySaw,
  \dur, Prand([1/8, 1/8, 1/4, 1/2], inf),
  \scale, Scale.ritusen,
  \degree, Prand([0, 1, 2, 3, 4, 5, 6, 7], inf),
  \root, Prand([[0, 7], [-5, 0], [0, 12]], inf) + 6,
  \octave, Prand([2, 3, 4], inf)
))

/*
 * list-8_23
 */
(// シーケンス 4
~out = Pbind(
  \instrument, \mySaw,
  \dur, Prand([1/8, 1/8, 1/4, 1/2], inf),
  \scale, Scale.ritusen,
  \degree, Prand(
    [0, 1, 2, 3, 4, 5, 6, 7], inf),
  \root, Prand([[0, 7], [-5, 0], [0, 12]], inf) + 6,
  \octave, Prand([2, 3, 4], inf),
  \cutoff, Pexprand(200, 15000, inf),
  \resonance, Prand([0.5, 0.3, 0.2, 0.1], inf),
  \legato, Pexprand(1.0, 3.0, inf),
))

/*
 * list-8_24
 */
(// シーケンス 5
~out = Pbind(
  \instrument, \mySaw,
  \dur, PstepNadd(
    Pseq([1, 0, 0, 1], 2),
    Pshuf([1, 1, 2, 1], 2)
  ).loop * (1/8),
  \pan, Prand([-0.6, -0.2, 0, 0.2, 0.6], inf),
  \scale,
  Pdup(32,
    Prand(
      [
        Scale.ritusen,
        Scale.hirajoshi,
        Scale.iwato,
        Scale.minorPentatonic
    ], inf)
  ),
  \degree,
  Pdup(4,
    Prand(
      [0, 1, 2, 3, 4, 5, 6, 7], inf)
  ),
  \root, Prand([[0, 5, 12],[0, 7, 12],[0, 12],[-5, 0, 12]], inf) + 6,
  \octave, Prand([2, 3, 4], inf),
  \cutoff, Pexprand(1000, 18000, inf),
  \resonance, Prand([0.5, 0.3, 0.2, 0.1], inf),
  \legato, Pexprand(1.0, 4.0, inf),
))

/*
 * list-8_25
 */
(
// 新たな楽器 "myFm"を定義
SynthDef("myFm",
  {
    arg  out = 0, gate = 1, freq = 440, ratio = 1.0, index = 3,
    attk = 0.01, rel = 1.0, idxNoiseRate = 0.2,
    sustain = 1.0, pan = 0, amp = 0.3;
    var modFreq, modDepth, indexNoiseMod, mod, car, sig, env;
    modFreq = freq * ratio;
    indexNoiseMod = LFNoise1.kr(idxNoiseRate).abs;
    modDepth = modFreq * index * indexNoiseMod;
    mod = SinOsc.ar(modFreq, 0.0, modDepth);
    car = SinOsc.ar(freq + mod, 0);
    env = Env.asr(attk, 1.0, rel);
    env = EnvGen.kr(env, gate, amp * 0.5, 0.0, sustain, doneAction:2);
    sig = Pan2.ar((car * env), pan);
    6.do({ sig = AllpassN.ar(sig, 0.05, [0.05.rand, 0.05.rand], 4) });
    Out.ar(out, sig);
  }
).add;
)
// 楽器を切り替え
~out.set(\instrument, \myFm);
// indexを変化させ音色を変化
~out.set(\index, 10);
~out.set(\ratio, (2/3));
~out.set(\index, 50);
~out.set(\ratio, (7/6));
~out.set(\index, 200);
~out.set(\ratio, (3/2));
~out.set(\index, 20);

/*
 * list-8_26
 */
// シーケンス 6
(
~out = Pbind(
  \instrument, \myFm,
  \dur, Prand([1/2, 1, 2], inf),
  \scale, Scale.hexMajor6,
  \degree, Prand([0, 1, 2, 3, 4, 5, 6, 7], inf),
  \root, Prand([[0, 7], [-5, 0], [0, 12]], inf) + 6,
  \octave, Prand([2, 3, 4, 5], inf),
  \index, Prand([0, 1, 10, 40, 200], inf),
  \ratio, Prand([1.0, 1.5, 0.333, 2.0], inf),
  \legato, 1.5
))

// 楽器を元に戻す
~out.set(\instrument, \mySaw);
// 最初のフレーズに
~out = Pbind(\instrument, \mySaw);
// 停止
~out.free;
// Proxyをクリア
~out.clear;
