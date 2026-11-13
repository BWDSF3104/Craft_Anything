# Master Duel 参考情報

Common_Operations での作業（2026-11-13）からの転写。詳細は同フォルダのタスクファイル2件を参照。

## カードデータベース（実体は Common_Operations 側・本リポジトリ外）

| ファイル | 実体パス | 内容 |
|---|---|---|
| cards.json (110MB) | `S:\Documents\Kilo_Commons\Common_Operations\masterduel\cards.json` | YAML Yugi 全件。`name.ja` あり（`<ruby>` ふりがな付き）。joinキー: `konami_id` / `password` / `yugipedia_page_id` / 英語名 |
| master-duel-raw.json (83MB) | 同フォルダ | Master Duel 実装部分集合（13,948件）。`ja_name` はほぼ不在（24件）、`ja_text` は100%、名前は英語基準 |

- cards.json ダウンロード元: https://dawnbrandbots.github.io/yaml-yugi/cards.json
- 更新スクリプト: 本フォルダの `Update-MasterDuelDB.ps1`（SHA-256差分判定。対象パスは同スクリプト実行先の `masterduel\cards.json`）

## 成果物

- `output/collection.csv` — 所持カード（card_id, 日本語名, quantity, normal/glossy/royal）63,195件
- `output/unmatched.csv` — カードDBと照合できなかった行
- `output/decks/` — YGOPRODeck 形式のデッキ `.ydk` 10件＋ `manifest.csv`

## 経緯の要点

- コレクション取得は YGOPRODeck Companion App（公式機能）経由。加工（シャイン/ロイヤル）列の有無は Companion 実機出力で判定済み。
- 日本語名は cards.json（辞書）＋ master-duel-raw.json（MD部分集合）の二枚構えで解決。
