# カードDB（cards.json）構築と未実装検出 実装計画

**Status**: 計画（実装未着手）
**Date**: 2026-11-13
**親タスク**: `2026-11-13-md-collection-export-research.md`

## 目的

カードマスタDBとして YAML Yugi の `cards.json` を導入し、自己更新できるようにする。
併せて「あるカードが Master Duel に実装済みか未実装か」を高速判定する機能を持たせる。
所持カードCSVの生成は本計画のスコープ外（別タスク）。

## 前提（調査済みで確定）

- 出典: `https://dawnbrandbots.github.io/yaml-yugi/cards.json`（Yugipedia 由来、DawnbrandBots/yaml-yugi が GitHub Pages で配布）。
- 観測値: 約105MB・14,442レコード・トップレベルはJSON配列・Last-Modified は数時間〜1日おき（2026-11-13 09:14 GMT を確認）。
- レコード主なキー: `konami_id`、`password`(8桁ID)、`name.{en,ja,...}`、`text.ja`、`ja_romaji`、`master_duel_rarity`、`yugipedia_page_id`。
- `name.ja` は `<ruby>炎<rt>ほのお</rt></ruby>` のようなfuriganaマークアップを含む。表示時はまず `<rt>.*?</rt>`（DOTALL）で読みブロックごと除去し、その後に残りのタグを `<[^>]+>` で除去する。**タグ除去だけでは `<rt>` の読みが残り誤り**（実測: `青眼の白龍ブルーアイズ・ホワイト・ドラゴン`）。修正版は `青眼の白龍` を確認済み（`docs/ai/tmp/check_ruby_strip.py`）。
- `master_duel_rarity` は実測13,949件に存在（UR 1,638 / SR 2,954 / R 4,038 / N 5,319、nullゼロ）。このフィールドの有無でMaster Duel実装/未実装を判定できる。キー無し約500件（passwordユニークでは426件）はMD未実装または照合漏れの推定。
- 制約: N・Rカードにロイヤル加工は無い（KONAMI公式）。

## フェーズ

### P1: 更新スクリプト（自己更新）
`scripts/Update-CardDB.ps1` を新設し、既存 `scripts/Update-MasterDuelDB.ps1` の方式を踏襲する。
- URLから一時ファイルへダウンロード → JSON妥当性検証 → SHA-256で既存と同なら「変更なし」で既存を保持 → 異なら差し替え。
- 検証ガード: 取得件数が前回比で大きく減少したら差し替え中止・非ゼロ終了（破損・欠損保護）。
- 保存先とgitignoreの扱いを明確化（DB本体は追跡しない）。

### P2: 参照層（読み込みヘルパ）
cards.json を読むだけの薄いモジュール。Python stdlibのみ。
- `load_cards()` → パスワード・konami_id 双方から引ける索引を構築。
- 名前は furigana 剥離済みと原文の両方を保持。
- ロード1.1秒・索引構築0.01秒は実測済みで、追加最適化（キャッシュ・バイナリ化）は要求するまで行わない。

### P3: 未実装検出
- 実装済み password のセットを構築（メモリ常驻で O(1) 判定）。
- 入力なし: cards.json 全件から未実装一覧（426件前後）を CSV 出力。
- 入力あり: password / konami_id / 日本語名 のいずれかを受け取り実装済みか否かを判定。日本語名は furigana 剥離後キーで照合、曖昧一致はせず一致しなかったものを別出力。
- 出力に「キー無し=未実装は推定（未発売・照合漏れを含む）」の注記列またはヘッダ注記。

### P4: 検証
- 更新スクリプト: 更新なし時の冪等、破損JSONの差し替え中止。
- 検出: 実装済み件数が既知値（13,945/426）と一致。既知の未発売カードが未実装側に出ること。既知の有名カード（例: 青眼の白龍）が実装側に出ること。
- 検証コマンドと結果・経過時間を本ファイルに記録。

## 完了基準

- 更新・参照・検出がそれぞれ実行可能で、P4の検証結果が実測で記録されている。
- 未確認・推定（キー無し=未実装の精度）を完了と書かない。

## Verification

- 2026-11-13: `scripts/Update-MasterDuelDB.ps1` を cards.json 基準へ切替（保存先 `masterduel\cards.json`）。あわせて取得件数10,000未満で差し替え中止のガードを追加。実行結果 `pwsh -NoProfile -File scripts\Update-MasterDuelDB.ps1` →「変更なし：最新版を保持しています。」（冪等・JSON妥当性パス、14,442件相当を通過）。
- 残: 破損JSON時の差し替え中止テストは未実施。別エージェント成果物が届いたら本差し替えは成果物側へ寄せる予定。

## 関連


- `master-duel-raw.json` は cards.json の下位集合で不要化。更新対象を cards.json に寄せる（P1で実装）。
- 所持カードCSVとの突合は別タスク（Companion App実出力が確定してから）。
