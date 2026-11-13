# [プロジェクト名]

[プロジェクトの1文説明]

## 共通規約

言語・実装開始ゲート・ターミナル安全・コマンド実行ルール・正典ツール（`bin/`）・コード検証の共通条・Memory Bank 運用・commit message 規約は global 正典 `AGENTS.md`（`C:\Users\fujim\.config\kilo\AGENTS.md`）を参照。このファイルにはプロジェクト固有項目のみ記載する（共通項目をここに書かない）。

## コード検証（本プロジェクト）

- **[言語]変更後**: `[テストコマンド]` で全テスト通過を確認。
- **[フレームワーク]変更後**: `[ビルドコマンド]` でビルド成功を確認。
- テストでの外部 API 呼出し可否は本プロジェクトの決定事項。決定を `docs/ai/decisions/` に記録する。

## Development

- Dev server: `[devコマンド]`
- Build: `[buildコマンド]`

## Code Standards

- [言語] scripts: UTF-8 encoding
- [データ出力パス]
- [生成ファイル出力パス]

## Documentation

- [フレームワーク] docs: [ドキュメントURL]
- Consult guides before: routing, components, framework integration, content collections, styling, i18n

## AI Memory Bank

Memory Bank のファイル構成、更新タイミング、アーカイブルール、Long-running Agent Tasks、Recovery After Interruption は `docs/ai/memory-bank-guide.md` を参照。

## Workflows

Git Workflow、Commit Checklist、Deploy Verification は `docs/ai/workflows.md` を参照。

## Project Structure

```
[プロジェクト名]/
├── [ソースコードディレクトリ]
├── [テストディレクトリ]
├── [データ出力ディレクトリ]
├── [静的アセットディレクトリ]
└── docs/ai/               # AI Memory Bank (changing knowledge)
```
