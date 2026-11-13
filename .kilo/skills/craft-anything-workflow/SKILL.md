---
name: craft-anything-workflow
description: Craft Anything を解析・調査・比較エンジンとして使い、Kilo 自身が唯一の制作エージェントとして Study→Specification→Build→Check→Refine→Ready を回すとき使う。Webサイト・アプリ・ゲームなどの原作を観測して調べ、Kilo が作り、Kilo が原作と突き合わせて検証するワークフローで使う。
---

# Craft Anything ワークフロー

Kilo が**唯一の制作エージェント**。Craft Anything は MCP サーバー `craft-anything`（このプロジェクト内のポータブルバイナリ）経由で**解析・調査・比較エンジン**としてのみ使う。Kilo 以外、または Craft Anything 側から別の制作エージェントを起動しない。ACP 連携で Kilo を二重起動しない。`rebuild_*` などの「代わりに作らせる」機能は使わない。

接続設定はすでにプロジェクトの `.kilo/kilo.jsonc` にある。既定はクリーンルーム（原作の内部＝コード・ファイル・page source は読まない）。全ツールは公開せず、必要なものから段階的に許可する（未許可のツールは実行時に承認が要る）。

## 原則
- 進捗・調査結果・判断・最終報告は日本語で書く。ツール名・パスなど正確な技術表記は原文のまま。
- 未検証の項目を完成扱いにしない。ある段階の合格条件を満たすまで次の段階に進まない。
- Craft Anything に「作らせない」。書く・直す・実行するのは Kilo。Craft Anything は「測る・比べる・証拠を残す」。

## 段階

### Study — 仕様と証拠を収集
- 対象を開いて overview / evidence / unknowns を集め、finding・hypothesis・brief・plan に記録する。
- 集めた証拠は project の journal に残す。不確実点は unknown に登録し、得た答えは verify する。
- 原作の内部は読まない（クリーンルーム）。外側から観測して仕様を推定する。

### Specification — 実装範囲と合格条件を決める
- brief と plan で、作るもの／作らないもの／合格条件（検査項目とその合否判定）を確定する。
- 合格条件は Check で機械的に確かめられる形（画面比較・機能・数値など）で書く。
- ユーザーの判断が要る点は person ask に投函して回答を待ち、勝手に決めない。

### Build — Kilo 自身が実施
- 実装・編集・実行は Kilo が行う。Craft Anything にビルドや制作を依頼しない。
- project の journal に変更内容と根拠を記録する。

### Check — 原作と制作物を比較
- 制作物と原作を、画面キャプチャ・ピクセル比較・状態比較・機能 tracing で突き合わせる。
- 差分を evidence / finding に記録する。クリーンルーム制約のため原作の内部は見ていない、という前提を明記する。

### Refine — 問題点を修正し、再検証する
- Check の差分から修正点を出し、Kilo が直す → Check を再実行して解消を確認する。
- 再検証していない修正を「完了」と書かない。

### Ready — 合格条件を確認し、残課題を明示
- Specification の合格条件を 1 つずつ Check 結果で確認し、合否を書く。
- 未検証・未達・既知の問題を「残課題」として明示する。すべて満たすまで Ready にしない。

## 使うツール（サーバー `craft-anything`、既定は Essentials）
- 対象・証拠・計画: `core_target_open` / `core_target_close` / `core_evidence_show` / `core_unknowns_show` / `core_brief_write` / `core_plan_update` / `core_finding_record` / `core_journal_read`
- 人への確認: `core_person_ask`（inbox に投函され、回答を待つ）
- 比較・観測: 画面キャプチャやピクセル比較などの観測系ツール（Check 用）
- 制作系（`rebuild_*` など）は使わない。必要なツールが出てきたら、その都度それを許可する。
