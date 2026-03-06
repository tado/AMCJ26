// 第1章

/*
 * list-1_01
 */
// 使用するサーバーを指定、この例ではローカルサーバーを使用
s = Server.local;

// ----- オーディオデバイス設定 -----
// 使用するオーディオデバイスを指定
// デバイス名は、サーバー起動時にPost windowに表示されるリストで確認できる
// 例: "ASIO : ASIO Fireface USB", "ASIO4ALL v2", "Focusrite USB ASIO" など
s.options.device = "オーディオデバイス名";

// 入力チャンネル数を設定
s.options.numInputBusChannels = 2;

// 出力チャンネル数を設定。マルチチャンネルスピーカーシステムの場合はここを変更する
s.options.numOutputBusChannels = 2;


// ----- パフォーマンス設定 -----
// ハードウェアのバッファサイズ（レイテンシーに影響）。nilの場合はデフォルト
s.options.hardwareBufferSize = 256;

// サンプルレート。nilの場合はオーディオデバイスの現在値を使用
s.options.sampleRate = 48000;

/*
 * list-1_02
 */
// ----- サーバーリソース設定 -----
// サンプルを読み込むためのバッファ数。デフォルトは1024
// 大量のサンプルを使用する場合に増やす
s.options.numBuffers = 1024 * 16; // 16384個のバッファを確保

// サーバーがリアルタイム処理（ディレイやリバーブなど）のために確保するメモリ量（KB）
// "alloc failed"エラーが出る場合に増やす。デフォルトは8192（8MB）
s.options.memSize = 8192 * 8; // 65536KB（64MB）を確保

// 同時に存在できるノード（SynthやGroup）の最大数。デフォルトは1024
// "too many nodes"エラーが出る場合に増やす
s.options.maxNodes = 1024 * 4; // 4096個のノードを許容 

/*
 * list-1_03
 */
"Hello SuperCollider!".postln;
