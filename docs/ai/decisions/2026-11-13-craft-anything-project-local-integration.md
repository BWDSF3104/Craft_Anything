# Craft Anything はプロジェクト内のみ導入（グローバル非インストール）

日付: 2026-11-13

## 背景
Craft Anything を Kilo から MCP 経由で使う。ただしユーザーのグローバル環境（`~/.config/kilo`、グローバル skills、PATH、レジストリ、npm/cargo グローバル等）を一切変更しない制約。

## 決定
1. **配布は公式ポータブル ZIP のみ**: Windows x64 Portable ZIP（v0.6.1）を `.tools/craft-anything/` に展開。MSI / winget / npm -g / `craft-anything-cli setup` 等のグローバル登録は不使用。CLI バナリは ZIP 同梱（別配布は macOS のみ）。
2. **MCP はプロジェクト設定のみ**: `.kilo/kilo.jsonc` に `type=local` で絶対パス起動を登録。グローバル `kilo.jsonc` は非変更。
3. **データはプロジェクト内**: `mcp` に `--project .tools/craft-anything/project.cany` と `--inbox .tools/craft-anything/inbox` を渡す。実測でユーザープロファイルへは一切書き出しなし。
4. **既定は保守的に**: `--clean-room`（原作内部を読まない）既定。`--all-tools` を付けないことで Essentials（30ツール）のみ公開し全ツール一括公開を回避。Kilo 側 permission で `craft-anything_*` を既定 `ask` にし、必要なツールから段階的に許可。
5. **制作エージェントは Kilo 単独**: `rebuild_*` は使わず、Craft Anything 側から別エージェントを起動しない。ACP 連携で Kilo を二重起動しない。制作（Build）は Kilo が実施し、Craft Anything は解析・調査・比較エンジンに限定。

## 検証で確認した事実
- SHA256 一致（`bd370fba...81de54`）、サイズ 69,934,191。exe の Authenticode Valid（署名者 Learning Machines Inc）。
- `doctor` healthy。MCP self-test で protocol 2025-06-18 / 30 tools。
- 設定コマンドをそのまま起動する probes で initialize 成功・`tools/list` 30 件。`--project` で生成物（evidence/unknowns/annotations/project.toml）は全て `.tools` 内。ユーザープロファイル配下にデータなし。

## 元に戻す方法
`.tools/craft-anything/`、`.kilo/kilo.jsonc` の craft-anything 節、`.kilo/skills/craft-anything-workflow/` を削除。`.git/info/exclude` に追記した 2 行（`/.tools/`、`docs/ai/tmp/`）を除去。グローバル環境は元から無変更のため復元不要。
