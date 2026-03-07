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
</style>

## AMCJワークショップ

# 「共鳴するコード、SuperColliderで創る音の世界」<br>実践とその先へ

2026年3月14日
田所淳

---

![bg left:33%](https://bnn.co.jp/cdn/shop/files/9784802513456.jpg?height=1200&v=1761550726)

## 本日のワークショップの内容

書籍「共鳴するコード、SuperColliderで創る音の世界」のさらに先を紹介!

もちろん、SuperColliderの初歩からカバーしていきます。

---

## 環境設定

必要なアプリケーションをまずはインストールしていきましょう!

![bg right:33%](https://upload.wikimedia.org/wikipedia/commons/6/60/SuperCollider_logo.svg)

macOS / Windows どちらでもOK
- [SuperCollider](https://supercollider.github.io/)
- [VScode](https://code.visualstudio.com/)
- [Google Chrome](https://www.google.co.jp/chrome/)

---

## 環境設定

![bg right:33%](https://img.icons8.com/fluent/1200/github-copilot.jpg)

本日のワークショップでは、コード生成のAIのアカウントがあるとなお便利です!

- [Claude Code](https://code.claude.com/)
- [Github Copilot](https://github.com/features/copilot)
- [Gemini Code Assist](https://codeassist.google/)
- [ChatGPT codex](https://chatgpt.com/codex)

---

## SuperCollider IDEの基本をおさらい

画面を操作しながら解説していきます。

![bg right:66%](./img/scide.jpg)

---

# 本日の「その先」: 1<br>VScodeからSuperColliderを使う

---

## VScodeからSuperColliderを使う

![bg right:33%](https://repository-images.githubusercontent.com/657248114/d3c7b91a-b285-4d1e-8429-5de1acc5f61e)

SC IDEは便利ですが、VScodeを使用するとさらに様々なメリットが

- コード補完
- シンタックスハイライト
- Git連携
- **AIコード生成ツールとの連携 ← !!**

---

## VScodeからSuperColliderを使う

VScode用のSuperColliderの拡張機能、
これまでもいくつか存在していた (ややこしい…)

- [vscode-supercollider](https://marketplace.visualstudio.com/items?itemName=jatinchowdhury18.vscode-supercollider): Language support for the SuperCollider language
- [language-supercollider](https://marketplace.visualstudio.com/items?itemName=salkin-mada.language-supercollider): SuperCollider syntax grammars for VSCode
- [scvsc](https://marketplace.visualstudio.com/items?itemName=scvsc.scvsc): vscode as a supercollider client

しかし、どれも一長一短
更新が止まっていたり、インストールが複雑だったり…


---

## VScodeからSuperColliderを使う

しかし、最近新しい拡張機能が登場! とても便利、かつインストールが (比較的) 簡単!

**[supercollider-vscode](https://marketplace.visualstudio.com/items?itemName=rogervila.supercollider-vscode)**  ([github](https://github.com/rogervila/supercollider-vscode))
SuperCollider language server for Visual Studio Code

![bg left:33%](https://rogervila.gallerycdn.vsassets.io/extensions/rogervila/supercollider-vscode/1.0.1/1767552387579/Microsoft.VisualStudio.Services.Icons.Default)

- コード実行
- シンタックスハイライト
- コード補完
- エディター機能

---

## VScodeからSuperColliderを使う

![bg left:33%](./img/supercollider-vscoder.jpg)

- VScodeの拡張機能
- “supercollider-vscode” で検索
- インストール

---

## VScodeからSuperColliderを使う

環境設定: 以下のように、SuperColliderの言語であるsclangへのパスを通す必要があります。

**macOS**: 以下の記述を ~/.zshrc に追加

```bash
export PATH="$PATH:/Applications/SuperCollider.app/Contents/MacOS"
```

**Windows**: 環境変数のPATHに以下を追加

```powerhsell
C:\Program Files\SuperCollider-3.14.1
```

---

## VScodeからSuperColliderを使う

確認: 以下のコマンドがターミナルで実行できるか確認

**MacOS**: Terminal.appを開いて、以下のコマンドを実行

```bash
% sclang
```

**Windows**: PowerShellを開いて、以下のコマンドを実行

```powershell
> sclang
```

---

## AIコード生成を活用しながらSuperColliderをコーディング!!<br>最強の環境が実現しました!!

![bg](./img/sc-coding-with-ai.jpg)

---

## 本日の「その先」の内容

- SuperColliderの基本をおさらい - 初歩からステップバイステップで
- SuperColliderでvibe coding! - AIコード生成ツールを活用
- Strudel + SuperColliderでライブコーディング