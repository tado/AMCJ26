# AMCJワークショップのための教材作成

## 目的

AMCJ (Ableton and Max Community Japan) 主催のSuperColliderをテーマにしたワークショップ「共鳴するコード、SuperColliderで創る音の世界 - 実践とその先へ」のためのスライド教材を作成します。手順に沿ってステップ・バイ・ステップで進めます。

## 手順

### ステップ 1: サンプルの学習

sc-book-example内の.scdファイルソースにしてSuperCollierについて学習してください。

### ステップ 2: 導入部のアウトライン

以下の内容で、導入部のアウトライン「Sin波から始めるSuperColiderの基本」と題したチュートリアルを作成します。以下のアウトラインに沿って、サンプルの.scdとコード内のコメントでその解説を作成していってください。

Sin波を演奏、以下のコードから始める

```scd
{SinOsc.ar()}.play
```
ここから発展させていく

- ステレオ再生に
- 音量の変更
- 周波数の変更
- 変数による指定
- SinOscのパラメータを他のコントロール信号で変化させる
- 音を混ぜる
- エンベロープ
- SynthDefによる楽器の作成
- 単純な加算合成からKlang、DynKlangによる加算合成へ
- 変調合成、AM、RM、FM
- 本格的な楽器をデザインする、FM、SuerSawなど

コードサンプルを交えながら解説する教材を、.scd形式とコメントで作成してください。作成したファイルを、ファイル「01-sc-basic.scd」に保存してください。

### ステップ 3: スライド作成

作成したチュートリアルの.scdファイルの内容を元に、Marp形式のスライドを作成してください。ただし以下の点に注意してください。

- コードは以下のようにコードブロックに入れる
```scd
...(code)
```

- 1ページのスライドに内容が収まるように。内容を盛り込みすぎてはみ出さないように。
- コード内のコメントはあまり多過ぎないように、かつ最低限の説明は入れるように
- ヘッダーとスタイルシートは以下のものを使用
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
  font-family: 'Roboto mono', 'Noto Sans JP';
  line-height: 1.5;
}
</style>
