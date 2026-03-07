# AMCJワークショップ: 共鳴するコード、SuperColliderで創る音の世界 - 実践とその先へ

**AMCJ (Ableton and Max Community Japan)** 主催ワークショップの教材リポジトリです。

- **日時**: 2026年3月14日
- **講師**: 田所 淳

---

## 内容

書籍「[共鳴するコード、SuperColliderで創る音の世界](https://bnn.co.jp/products/9784802513456)」をベースに、SuperColliderの基礎から応用までをステップバイステップで解説します。

### ワークショップのトピック

1. **SuperColliderの基本** - Sin波からはじめるサウンドプログラミング
2. **AIコード生成を活用したvibe coding** - Claude / GitHub Copilot などとの連携
3. **Strudel + SuperCollider** - ライブコーディングの実践

---

## ファイル構成

```
AMCJ26/
├── 00-outline.md           # ワークショップ全体のアウトライン（Marpスライド）
├── 01-sc-basic-slides.md   # 「Sin波から始めるSuperColliderの基本」スライド（Marpスライド）
├── 01-sc-basic.scd         # Sin波から始めるSuperColliderチュートリアルのSCDファイル
├── 01-sc-intro.scd         # イントロダクション用SCDファイル
├── img/                    # スライド用画像
└── sc-book-examples/       # 書籍掲載サンプルコード（Chapter01〜08）
```

### sc-book-examples/

書籍「共鳴するコード、SuperColliderで創る音の世界」のサンプルコードです。

| ファイル | 内容 |
|---|---|
| Chapter01.scd | SuperCollider導入・環境設定 |
| Chapter02.scd | sclangの基本言語（データ型・変数・関数・配列） |
| Chapter03.scd | サウンドプログラミングの基本（UGen・波形・ノイズ） |
| Chapter04.scd | 楽器をつくる（ミキシング・エンベロープ・SynthDef） |
| Chapter05.scd | さまざまな音響合成（加算・AM/RM/FM・減算・SuperSaw） |
| Chapter06.scd | サンプリングとプレイバック（Buffer・PlayBuf・グラニュラー） |
| Chapter07.scd | シーケンスとパターン（Routine・TempoClock・Pbind） |
| Chapter08.scd | ライブコーディング（JITLib・ProxySpace・ホットスワップ） |

---

## 環境設定

### 必要なアプリケーション

- [SuperCollider](https://supercollider.github.io/) - SuperCollider本体
- [VSCode](https://code.visualstudio.com/) - エディター
- [supercollider-vscode](https://marketplace.visualstudio.com/items?itemName=rogervila.supercollider-vscode) - VSCode拡張機能

### VSCode拡張機能のセットアップ

VSCodeの拡張機能マーケットプレイスで `supercollider-vscode` を検索してインストールします。

**macOS**: `~/.zshrc` に以下を追加してsclangへのパスを通します

```bash
export PATH="$PATH:/Applications/SuperCollider.app/Contents/MacOS"
```

**Windows**: 環境変数のPATHに以下を追加します

```
C:\Program Files\SuperCollider-3.14.1
```

---

## AIエージェントを活用する

Claude CodeなどのAIエージェントが利用できる場合、以下のプロンプトでサンプルコードを事前学習させておくと、より的確なコード生成が可能になります。

> 「sc-book-examples」フォルダ内のChapter01からChapter08のSuperColliderのファイルの内容を学習してください。

---

## スライドの表示

スライドは [Marp](https://marp.app/) 形式で記述されています。VSCodeに [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode) 拡張機能をインストールすると、プレビューおよびPDF書き出しが可能です。
