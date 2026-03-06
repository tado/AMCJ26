// 第2章

/*
 * list-2_01
 */
Server.local.boot;

/*
 * list-2_02
 */
{LocalOut.ar(a=CombN.ar(BPF.ar(LocalIn.ar(2)*7.5+Saw.ar([32,33],0.2),2**LFNoise0.kr(4/3,4)*300,0.1).distort,2,2,40));a}.play

/*
 * list-2_03
 */
(
{
  LocalOut.ar(
    a = CombN.ar(
      BPF.ar(
        LocalIn.ar(2) * 7.5 + Saw.ar([32, 33], 0.2),
        2 ** LFNoise0.kr(4/3, 4) * 300, 0.1
      ).distort,
      2, 2, 40
    )
  );
  a
}.play
)


/*
 * list-2_04
 */
(
/*
 * Nathaniel Virgo
 * sc-140プロジェクトより
 * https://supercollider.github.io/sc-140.html
 */

{
  // 変数の宣言
  var in, saw, mix, freq, rq, bpf, out;

  // LocalIn：オーディオ入力を取得するためのUnit Generator (UGen)
  // 2チャンネルのオーディオ入力を取得
  in = LocalIn.ar(2);

  // Saw：ノコギリ波を生成するUGen
  // 周波数32Hzと33Hzのノコギリ波を生成、0.2は位相
  saw = Saw.ar([32, 33], 0.2);

  // 入力信号とノコギリ波を合成
  // 入力信号を7.5倍に増幅し、ノコギリ波と加算
  mix = in * 7.5 + saw;

  // LFNoise0：低周波ノイズを生成するUGen
  // freq：フィルターのカットオフ周波数を計算するための変数
  // 2の(4/3 Hzで変化するノイズ)乗 * 300 で周波数を計算
  freq = 2 ** LFNoise0.kr(4/3, 4) * 300;

  // rq：フィルターのQ値(レゾナンスの強さ)を設定
  rq = 0.1;

  // BPF：バンドパスフィルターを適用するUGen
  // .distort：歪みエフェクトを適用するメソッド
  // 合成した信号にバンドパスフィルターをかけ、歪ませる
  bpf = BPF.ar(mix, freq, rq).distort;

  // CombN：コームフィルターを適用するUGen
  // フィルターと歪みを適用した信号にコームフィルターをかける
  out = CombN.ar(bpf, 2, 2, 40);

  // LocalOut：信号を出力するUGen
  // 最終的な信号を出力
  LocalOut.ar(out);

  // 最後に評価された値を返す (この場合はout)
  out;

}.play
)

/*
 * list-2_05
 */
{Splay.ar(Ringz.ar(Impulse.ar([2, 1, 4], [0.1, 0.11, 0.12]), [0.1, 0.1, 0.5])) * EnvGen.kr(Env([1, 1, 0], [120, 10]), doneAction: 2)}.play

/*
 * list-2_06
 */
(
{
  // 変数の宣言
  var impulse, ring, env;

  // Impulse：インパルス信号（非常に短いパルス）を生成するUGen
  // 周波数2Hz、1Hz、4Hzのインパルスを生成
  impulse = Impulse.ar([2, 1, 4], [0.1, 0.11, 0.12]);

  // Ringz：インパルス応答を元に共鳴音を生成するUGen
  // 共鳴周波数 0.1、0.1、0.5 Hz
  ring = Ringz.ar(impulse, [0.1, 0.1, 0.5]);

  // EnvGen：エンベロープ(時間的な変化の形)を生成するUGen
  // Env：エンベロープの形状を定義
  // doneAction: 2 はエンベロープ終了後にSynthを解放する指示
  // レベル1から始まり、120秒かけて1へ、10秒かけて0へ変化するエンベロープ
  env = EnvGen.kr(Env([1, 1, 0], [120, 10]), doneAction: 2);

  // Splay：ステレオに広げるためのUGen
  // 最後に全体の音量をエンベロープで制御
  Splay.ar(ring) * env;

}.play
)

/*
 * list-2_07
 */
"Hello World".postln;

/*
 * list-2_08
 */
postln("Hello World");

/*
 * list-2_09
 */
"Hello World".reverse.postln;

/*
 * list-2_10
 */
postln(reverse("Hello World"));

/*
 * list-2_11
 */
"Hello World".reverse.toUpper.postln;

/*
 * list-2_12
 */
postln(toUpper(reverse("Hello World")));

/*
 * list-2_13
 */
postln(reverse("Hello World").toUpper);
reverse("Hello World").toUpper.postln;

/*
 * list-2_14
 */
2.squared;

/*
 * list-2_15
 */
2.squared.reciprocal;

/*
 * list-2_16
 */
reciprocal(squared(2));

/*
 * list-2_17
 */
(
// 変数strの宣言
var str;
// strに文字列 "Hello"を代入
str = "Hello";
// strに文字列"World"を結合
str = str + "World";
// strの文字列を反転
str = str.reverse;
// 反転した文字列を全て大文字に
str = str.toUpper;
// ポストウィンドウに出力
str.postln;
)

/*
 * list-2_18
 */
(
// 変数numの宣言
var num;
// numに整数2を代入
num = 2;
// numを二乗
num = num.squared;
// 二乗したnumの逆数を求める
num = num.reciprocal;
// 結果をポストウィンドウに出力
num.postln;
)

/*
 * list-2_19
 */
(
n = 2;
n = n.squared;
n = n.reciprocal;
n.postln;
)

/*
 * list-2_20
 */
(
~num = 2;
~num = ~num.squared;
~num = ~num.reciprocal;
~num.postln;
)

/*
 * list-2_21
 */
// まずこちらを実行
(
~num = 2;
~num = ~num.squared;
~num = ~num.reciprocal;
)

// 上のコードブロックを実行した後に実行
~num.postln;

/*
 * list-2_22
 */
(
num = 2;
num = num.squared;
num = num.reciprocal;
num.postln;
)

/*
 * list-2_23
 */
(
// 変数を宣言
var intNum, floatNum, result;
// 整数（Integer）を代入
intNum = 10;
// 浮動小数点数（Float）を代入
floatNum = 3.14;
// 整数と浮動小数点数の加算
result = intNum + floatNum;
// 結果を出力（13.14）
result.postln;

// 平方根の算出
// √13.14
result = result.sqrt;
// 結果を出力
// 3.6249137920784
result.postln;
)

/*
 * list-2_24
 */
(
// 変数の宣言
var char, string, newString;
// 文字'a'の代入
char = $a;
// 文字列"SuperCollider"の代入
string = "SuperCollider";
// Charの表示 -> a
char.postln;
// Stringの表示 -> SuperCollider
string.postln;
// 97（$aのASCIIコード）
(char.ascii).postln;
// SuperColliderの文字数 -> 13
string.size.postln;
)

/*
 * list-2_25
 */
(
// 変数の宣言
var symbol1, symbol2;
// シンボル'aSynbol'の代入
symbol1 = 'aSymbol';
symbol2 = \anotherSymbol;
// シンボルの内容を表示
symbol1.postln;
symbol2.postln;
)

/*
 * list-2_26
 */
(
// 変数の宣言
var bool1, bool2, result;
// ブール値を代入
bool1 = true;
bool2 = false;
// 論理積（AND）
result = bool1 && bool2; // false
result.postln;
// 論理和 （OR）
result = bool1 || bool2; // true
result.postln;
)

/*
 * list-2_27
 */
(
// 配列を宣言
var myArray;
// 配列に5つの値を代入
myArray = [0, 10, 100, 1000, 10000];
// 配列全体を表示
myArray.postln;
// 最初の値を取得
myArray[0].postln; // 0
// 3番目の値を取得
myArray[2].postln; // 100
)

/*
 * list-2_28
 */
(
var myArray;
// さまざまなデータ型の値をひとつの配列に
myArray = [1, 2.0, "three", $f, \five];
myArray.postln;
)

/*
 * list-2_29
 */
(
var myArray;
myArray = [1, 2, 3];
// 配列を表示
myArray.postln; // [1, 2, 3]
// 2番目の要素を10に変更
myArray[1] = 10;
// 要素を変更した配列を表示
myArray.postln; // [ 1, 10, 3 ]
)

/*
 * list-2_30
 */
(
var myArray, size;

// 配列の初期化
myArray = [1, 2, 3];

// .sizeを使って要素数を取得し、変数sizeに代入
size = myArray.size;

// size（要素数）とmyArrayの内容を出力
size.postln; // 3
myArray.postln; // [ 1, 2, 3 ]

// .addを使って配列の末尾に4を追加
myArray = myArray.add(4);
myArray.postln; // [ 1, 2, 3, 4 ]

// .insertを使ってインデックス1の位置に10を挿入
myArray = myArray.insert(1, 10);
myArray.postln; // [ 1, 10, 2, 3, 4 ]

// .doを使って各要素を2倍して出力
myArray.do({ arg item; (item * 2).postln; });
// 2
// 20
// 4
// 6
// 8
)

/*
 * list-2_31
 */
(
var myArray;
// 5つの要素すべてを1で初期化
myArray = Array.fill(5, 1);
myArray.postln; // [ 1, 1, 1, 1, 1 ]
)

/*
 * list-2_32
 */
(
var myArray;
// 2次元の配列を生成
myArray = [[1, 2], [3, 4], [5, 6]];
// 配列全体の表示
myArray.postln;
// 2番目の配列の1番目の要素
myArray[1][0].postln; // 3
)

/*
 * list-2_33
 */
// 関数~funcの定義
(
~func = {
  var num;
  num = 2;
  num = num.squared;
  num = num.reciprocal;
  num.postln;
}
)

/*
 * list-2_34
 */
// ~funcを実行（評価）して結果を出力
~func.value;

/*
 * list-2_35
 */
// 関数~funcの定義2
(
~func = {
  // 引数numの宣言
  arg num;
  num = num.squared;
  num = num.reciprocal;
  num.postln;
}
)

/*
 * list-2_36
 */
// 引数を指定しないとエラーになる
~func.value;

/*
 * list-2_37
 */
// 引数2を指定して~funcを実行
~func.value(2);

/*
 * list-2_38
 */
// 引数5を指定して~funcを実行
~func.value(5);

/*
 * list-2_39
 */
// 関数~funcの定義
// 引数の初期値を2に
(
~func = {
  // 引数numの宣言して初期値を2に
  arg num = 2;
  num = num.squared;
  num = num.reciprocal;
  num.postln;
}
)

// 今度は引数を指定しなくても2を初期値として動作する
// -> 0.25
~func.value;

// 引数5を指定して初期値を上書きする
// -> 0.04
~func.value(5);

/*
 * list-2_40
 */
// 複数の引数を関数に入力
(
~func = {
  // 2つの文字列の引数を受けとる
  arg msg1, msg2;
  // 連結した文字列を格納する変数bindMsgを宣言
  var bindMsg;
  // 引数として入力された文字列を連結
  bindMsg = msg1 + msg2;
  // 連結された文字列を出力
  bindMsg.postln;
}
)

// 2つの引数を指定して関数を評価
~func.value("Hello", "World");

// 引数を変更
~func.value("I love", "SuperCollider");

/*
 * list-2_41
 */
"Hello World".postln;
// -> Hello World

"Hello World".reverse.postln;
//-> dlroW olleH

"This is a String".class.postln;
// -> String

/*
 * list-2_42
 */
'symbolName'.postln;
// -> symbolName

\symbolName.postln; // バックスラッシュを使ったシンボル定義
// -> symbolName

'symbolName'.class.postln;
// -> Symbol

(\freq: 440, \amp: 0.1).postln; // 環境リテラル（Environment Literal）のキーとしてシンボルを使用
// -> ('freq': 440, 'amp': 0.1)

/*
 * list-2_43
 */
(1 + 2) * 3; // 演算の優先順位: zuerst 1 + 2, dann * 3 -> 9
1 + (2 * 3); // 演算の優先順位: zuerst 2 * 3, dann 1 + -> 7

1.max(5).postln; // メソッド呼び出しの引数：1と5の大きい方 -> 5

f = { |a, b| a + b }; // Function 定義（詳細は後述）
f.value(10, 20).postln; // Function 実行時の引数 -> 30

e = (a: 10, b: "hello", c: [1, 2, 3]); // 環境リテラル
e.postln;
// -> ('a': 10, 'c': [1, 2, 3], 'b': hello)
e[\a].postln; // 環境内の値へのアクセス（キーはシンボル）-> 10
e.class.postln;
// -> Event

/*
 * list-2_44
 */
~myArray = [1, 2.0, "three", \four, [5, 6], { "Hello World".postln }];
~myArray.postln;
// -> [ 1, 2.0, three, four, [ 5, 6 ], a Function ]

~myArray[0].postln; // 最初の要素（インデックス 0）-> 1
~myArray[2].postln; // 3番目の要素（インデックス 2）-> three
~myArray[4][1].postln; // 配列内の配列の要素にアクセス -> 6
~myArray[5].value; // 配列内の関数を実行 -> Hello World

~myArray.size.postln; // 配列の要素数 -> 6
~myArray.class.postln; // -> Array

/*
 * list-2_45
 */
f = { "Hello from Function!".postln }; // 引数なしの関数
f.postln;
// -> a Function
f.value; // 関数を実行
// -> Hello from Function!

~add = { |a, b| a + b }; // 2つの引数を取る関数
~add.value(5, 3).postln; // 引数を渡して実行 -> 8

(
~result = if (1 > 0) { // if文の条件が真の場合に実行される関数
  "Condition is true".postln;
  100 // この関数が返す値
} { // 条件が偽の場合に実行される関数
  "Condition is false".postln;
  0 // この関数が返す値
};
)
// -> Condition is true
~result.postln; // if文全体が返した値 -> 100

{ SinOsc.ar(440, 0, 0.1) }.play; // 関数を直接 play メソッドに渡して音を鳴らす
