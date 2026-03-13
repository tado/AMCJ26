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

##### AMCJワークショップ<br>共鳴するコード、SuperColliderで創る音の世界 - 実践とその先へ

# 02.<br>その先 1: SuperCollider + VSCodeで<br>Vibe Coding!

2026年3月14日
田所淳

---

# 02: 「その先」1<br>SuperCollider + VSCodeでVibe Coding!

---

## Vibe Codingとは？

**自然言語でAIに話しかけ、コードを生成・改良していく開発スタイル**

```
「FMシンセを作って。ベル的な音色で、
 インデックスがエンベロープで変化するもの」
        ↓ AIがコードを生成
SuperColliderのコードが出力される
        ↓ 実行・試聴・フィードバック
「もっとリバーブを深くして」「Cメジャーで和音で鳴らして」
```

- コードの細部よりも **アイデア・音の設計** に集中できる
- SuperColliderの構文を完全に覚えていなくても試せる
- 試行錯誤のサイクルが速くなる

---

## VSCodeでVibe Coding — 主要ツール

| ツール | 提供元 | 特徴 |
|---|---|---|
| **GitHub Copilot** | GitHub / Microsoft | エディター統合、補完・チャット |
| **Claude Code** | Anthropic | VSCode拡張、高品質コード出力 |
| **Gemini Code Assist** | Google | VSCode拡張、Geminiモデル |
| **ChatGPT Codex** | OpenAI | VSCode拡張 |

→ どれもVSCode上のSuperCollider編集で利用可能
個人的には Claude Code > Copilot > Gemini > ChatGPT

---

## VSCodeでVibe Coding — ツールのインストール

もし、下記のどれかのサービスに課金していたら

**GitHub Copilot**
- VSCode拡張マーケットプレイスで `GitHub Copilot` を検索・インストール

**Claude Code**
- VSCode拡張マーケットプレイスで `Claude Code` を検索・インストール

**Gemini Code Assist**
- VSCode拡張マーケットプレイスで `Gemini Code Assist` を検索・インストール

**ChatGPT Codex**
- VSCode拡張マーケットプレイスで `ChatGPT Codex` を検索・インストール

---

## もし、どのサービスにも課金していない場合は…

WebベースのチャットでClaudeやGemini、ChatGPTを使用してください。

- https://claude.ai/
- https://gemini.google.com/
- https://chatgpt.com/

---

## AIに事前学習させる — sc-book-examples

AIはSuperColliderのコードを書けるが、**文脈を与えるとより的確に**。

まず、参考書のサンプルコードをAIに読ませる:

> 「sc-book-examples」フォルダ内のChapter01からChapter08の
> SuperColliderのファイルの内容を学習してください。

これにより、SuperColliderの慣用的なコードスタイルをAIが把握する。

---

## AIに事前学習させる — 公式ドキュメント

**SuperCollider公式ドキュメント** を参照させることでさらに精度が上がる。

プロンプト例

> https://doc.sccode.org/ を参照してSuperColliderのコードを学習してください。

SuperColliderのコードを熟知したエージェントが爆誕!

---

## プロンプトからコードを生成 — FM合成

**プロンプト例:**

> 学習した成果を生かして、FM音響合成を行う楽器 (SynthDef) を作成してください。

**生成されたコード（例）:**

[fm-instruments.scd](https://github.com/tado/AMCJ26/blob/main/AI-generated-code/fm-instruments.scd)

---

## プロンプトからコードを生成 — 減算合成

**プロンプト例:**

> 同じように、学習した成果を生かして、減算合成を使用した楽器 (SynthDef) を生成してください。

**生成されたコード（例）:**

[subtractive-instruments.scd](https://github.com/tado/AMCJ26/blob/main/AI-generated-code/subtractive-instruments.scd)

---

## プロンプトからコードを生成 — 抽象的なプロンプト

コードを指定せず、**音楽的・感覚的な言葉でも生成できる:**

> SuperColliderで「波が打ち寄せるような環境音」を生成するコードを書いて。
> ゆっくりした音量変化と、フィルターの揺れを使って。

**生成されたコード（例）:**

[ocean-waves.scd](https://github.com/tado/AMCJ26/blob/main/AI-generated-code/ocean-waves.scd)

---

## プロンプトからコードを生成 — 抽象的なプロンプト

> SuperColliderで「ミニマルな反復メロディー」を演奏するPbindを作って。
> 律旋法スケールを使い、音量とリズムをランダムに変化させて。

**生成されたコード（例）:**

[minimal-ritusen.scd](https://github.com/tado/AMCJ26/blob/main/AI-generated-code/minimal-ritusen.scd)

---

## エージェントを活用する — CLAUDE.md

**Claude Code** などのエージェント型AIは、**指示書ファイル**を使って
プロジェクト全体の文脈を永続的に与えられる。

`CLAUDE.md` をプロジェクトのルートに置くと、Claude Codeが自動で読み込む:

例:
```markdown
# プロジェクト: SuperColliderワークショップ教材

## 目的
AMCJ向けSuperColliderチュートリアルの.scdファイルを作成する。

## コーディング規則
- SynthDefには必ず out, amp, gate 引数を含める
- エンベロープ終了後は doneAction: Done.freeSelf を使用
- ステレオ出力には .dup(2) を使う
```

---

## エージェントによる開発実践

エージェントは**複数ファイルをまたいだ開発タスク**に強い:

**タスク例:**
> 「01-sc-basic.scdを読んで、内容をもとにMarp形式のスライドを作成して。
>  1スライドにコードが収まるように分量を調整してください。」

---

## エージェントによる開発実践

**エージェントが行う作業:**
1. `.scd` ファイルを読み込んで内容を把握
2. セクションごとにスライドを分割
3. コードを整形してコードブロックに挿入
4. ページ内に収まるよう内容を調整
5. `.md` ファイルに保存

→ 反復作業・構造化作業をまとめて自動化できる

---

## まとめ

<div style="font-size: 0.85em">

| テーマ | ポイント |
|---|---|
| Vibe Codingとは | 自然言語でAIとやりとりしながらコードを生成・改良 |
| 主要ツール | GitHub Copilot / Claude Code / Gemini Code Assist / Codex |
| 事前学習 | sc-book-examples・公式ドキュメントで文脈を与える |
| コード生成 | FM合成・減算合成・抽象的なプロンプトでも生成可能 |
| エージェント活用 | CLAUDE.md で指示書を与え、複数ファイルの作業を自動化 |

</div>

**次のセッション:** Strudel + SuperCollider でライブコーディング！
