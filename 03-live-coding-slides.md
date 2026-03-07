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
