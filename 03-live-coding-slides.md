---
marp: true
paginate: true
---
<style>
:root {
  font-family: 'Noto Sans JP';
  color: #444;
}
:root ol {
  list-style-type: decimal;
}
:root h1, h2, h3, h4, h5, h6{
  font-family: 'Noto Sans JP Black';
  color: #2277cc;
}
pre, code {
  font-family: 'JetBrains Mono Slashed', 'Noto Sans JP';
  line-height: 1.3;
}
th, td {
  font-size: 0.8em;
}
</style>

# AMCJワークショップ<br>共鳴するコード、SuperColliderで創る音の世界<br>- 実践とその先へ

2026年3月14日
田所淳

---

# 03: 「その先」2<br>Strudel + SuperColliderでLive Coding

---

## SuperCollider + Live Coding

**SuperColliderでLive Coding**

- 単体でも可能 → [JITlib](https://doc.sccode.org/Overviews/JITLib.html)
- しかし、今回は「その先」を目指してLive Coding専用の環境とSuperColliderを組み合わせる方法を紹介

---

## SuperCollider + Live Coding

**SuperDirt**

- TidalCycles環境向けに設計されたサンプラー「Dirt」のSuperCollider実装
- Open Sound Control（OSC）プロトコル経由、またはSuperCollider言語から直接操作可能な、サンプル再生やシンセサイザーのための汎用フレームワーク
- 現在ではTidalCycles以外のLive Coding環境からも利用されている
- 今回はWebブラウザベースのLive Coding環境「Strudel」と組み合わせて使用

---

# Strudel + SuperDirt環境設定

---

## Strudel + SuperDirt環境設定

1.   **SuperCollider + sc3 pluginsのインストール**: 詳細はTidalのドキュメント（Install Tidal）を参照
2.   **SuperDirtのインストール**: 通常のSuperDirt、またはStrudelでの使用に最適化された「StrudelDirt fork」をインストール
3.   **node.jsのインストール**
4.   **Strudelリポジトリのダウンロード**
5.   **pnpmのインストール**
6.   **依存関係のインストール**: strudelディレクトリ内で `pnpm i` を実行
7.   **OSCサーバーの起動**: `pnpm run osc` を実行してOSCサーバーを起動

---

## Strudel + SuperDirt環境設定

**SuperCollider + sc3 pluginsのインストール**

以下のGithubのリリースページからダウンロード
- https://github.com/supercollider/sc3-plugins/releases

ダウンロードしたら、SuperColliderのUser Support Directory内の「Extensions」フォルダに解凍して配置する

---

## Strudel + SuperDirt環境設定

**node.jsのインストール**

- 公式サイトにアクセス: Node.jsダウンロードページへ行く
- LTS版を選択: 安定した動作が保証されている「LTS（推奨版）」を選択
- インストーラーを実行: Windowsなら .msi、Macなら .pkg ファイルをダウンロードして開き、画面の指示に従ってインストールを完了させる

---

## Strudel + SuperDirt環境設定

**Strudelリポジトリのダウンロード**

以下のリポジトリからZipファイルをダウンロードして解凍

- https://codeberg.org/uzu/strudel/

---

## Strudel + SuperDirt環境設定

**pnpmのインストール**

以下のページを参照して、pnpmをインストール

- https://pnpm.io/ja/installation

---

## Strudel + SuperDirt環境設定

**SuperDirtのインストール**

SuperColliderを起動し、以下のコードを実行してSuperDirtをインストール

```cpp
Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.4"); thisProcess.recompile()})
```

---

## Strudel + SuperDirt環境設定

**依存関係のインストール**: 

strudelディレクトリ内で `pnpm i` を実行

**OSCサーバーの起動**:

`pnpm run osc` を実行してOSCサーバーを起動

```powershell
> @strudel/osc@1.3.2 server
> node server.js

[Sending OSC] 127.0.0.1:57120
[Listening WS] ws://localhost:8080
```

---

## Strudel + SuperDirt環境設定

**SuperDirtの起動**

SuperColliderを起動し、以下のコードを実行してSuperDirtを起動

```cpp
SuperDirt.start;
```
以下のような出力が表示されれば成功

```powershell
-> SuperDirt.start;
...(中略)...
Shared memory server interface initialized
SuperDirt: listening on port 57120
```
---

## Strudel + SuperDirt環境設定

**StrudelからSuperDirtへの接続確認**

[Strudel REPL](https://strudel.cc/)をブラウザで開きしょう。以下の簡単なコードで動作確認。

```javascript
$: s("bd cp [~ bd] hc*2").osc();

$: s("supersaw(9, 16)")
  .note(irand(8)).scale("C2:pentatonic")
  .lpf(sine.slow(2).range(100, 12000))
  .resonance(0.3).osc();
``` 
末尾の `.osc()` でStrudelからSuperDirtにOSCメッセージを送信している

---

## SuperDirt用のSynthDefの作成

---

## SuperDirt用のSynthDefの作成

それでは、いよいよSuperDirt用のSynthDefを作成してみましょう!

まずは通常のSynthDefでシンプルなsine波のSynthDefを作成してみます

```cpp
(
SynthDef(\mysine, {
  arg out=0, freq=440, amp=0.5;
  var sig = SinOsc.ar(freq).dup(2) * amp;
  Out.ar(out, sig);
}).add;
)

Synth(\mysine);

Synth(\mysine);
```

---

## SuperDirt用のSynthDefの作成

SuperDirtで使用するためには、いくつか変更する必要あり。先程の`\mysine` SynthDefをSuperDirt用に変更してみましょう

```cpp
SuperDirt.start;

(
SynthDef(\mysine, {
  arg out, freq, sustain = 1.0, pan;
  var env = EnvGen.ar(Env.adsr(), timeScale:sustain, doneAction:2);
	var sig = SinOsc.ar(freq);
	Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add
)
```

---

## SuperDirt用のSynthDefの作成

この`\mysine`をStrudelから演奏してみましょう

```javascript
$: s("mysine(9, 16)")
  .note(irand(8)).scale("C4:pentatonic")
  .pan(rand.range(0, 1))
  .osc();
```
このコードは、StrudelからSuperDirtにOSCメッセージを送信して、`\mysine` SynthDefを演奏しています。`note`で音程を指定し、`pan`で左右の定位をランダムに設定しています。

---

## SuperDirt用のSynthDefの作成

シンプルなSynthDefでも、SuperDirtのエフェクトと組み合わせることで、より複雑なサウンドを作り出すことができます。例えば、Saw波のSynthDefを作成してみましょう

```cpp
(
SynthDef(\mysaw, {
  arg out, freq, sustain = 1.0, pan;
  var env = EnvGen.ar(Env.adsr(), timeScale:sustain, doneAction:2);
	var sig = Saw.ar(freq);
	Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add
);
```

----

## SuperDirt用のSynthDefの作成

この`\mysaw`をStrudelから演奏してみましょう

```javascript
$: s("mysaw(9, 16)")
  .note(irand(8)).scale("<C3:pentatonic C3:ritusen>")
  .pan(rand.range(0, 1)).jux(rev)
  .osc();
```

---

## SuperDirt用のSynthDefの作成

ここに、Strudelの様々なエフェクトを組み合わせてみますしょう

```javascript
$: s("mysaw(9, 16)")
  .note(irand(8)).scale("<C3:pentatonic C3:ritusen>")
  .pan(rand.range(0, 1)).jux(rev)
  .lpf(rand.range(100, 1000)).resonance(0.3)
  .delay(0.8).delayfeedback(0.7).delaytime((5/8))
  .osc();
```

このコードは、`\mysaw`に、`lpf`や`resonance`でフィルターをかけたり、`delay`や`delayfeedback`でディレイエフェクトを追加しています。

---

## SuperDirt用のSynthDefの作成

ここに、SuperDirtの様々なサンプルを組み合わせて、ライブコーディングを楽しんでみましょう!

```javascript
$: s("bd cp [~ bd] hc*2").osc();

$: s("ifdrums(5, 8)").n(irand(3)).osc();

$: s("mysaw(9, 16)")
  .note(irand(8)).scale("<C3:pentatonic C3:ritusen>")
  .pan(rand.range(0, 1)).jux(rev)
  .lpf(rand.range(100, 1000)).resonance(0.3)
  .delay(0.8).delayfeedback(0.5).delaytime((5/8))
  .osc();
```  






