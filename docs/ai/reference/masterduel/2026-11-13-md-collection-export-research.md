# マスターデュエル所持カードCSV取得方式の調査（加工列の有無）

**Status**: 進行中
**Date**: 2026-11-13
**Next Action**: ゲーム内コレクション総枚数と output/collection.csv(63,195)照合 ／ 残る欠落デック10件（内容未抽出）は公式DBから再抽出後に同手順で登録（日本語名はサーバに弾かれるため ASCII 名で）

## 意図 / 背景

Steam版マスターデュエルをデータ取得元、Android版を確認用として、所持カードコレクションを構造化データ（card_id / name / quantity / normal / glossy(シャイン) / royal(ロイヤル)）で取得したい。YGOPRODeck Companion App の CSV 出力がその実現手段になるかを、導入前に調査・検討する（実施はまだしない）。

## 調査結果 / 変更内容

### Companion App（YGOPRODeck 公式）
- 機能一覧に "Export your Master Duel card collection to a .csv file" が明記。コレクションCSV出力は公式機能として実在。 https://ygoprodeck.com/master-duel/companion-app/
- **CSVの列構成・加工情報の有無は公式に一切記載なし**。GitHub等の一次情報も出てこず、検索では確認できなかった。→ 加工列があるかは実機出力でのみ判定可能（本タスクの Next Action）。
- 既知の制約（公式ページ記載）: 初回起動時にウィルス対策/信頼アプリ警告の可能性、稀にクラッシュ、MDアップデート直後は再読み込みが必要。

### 加工（ベーシック/シャイン/ロイヤル）データの性質
- MD のデータモデルでは加工は STYLE (Normal/Shine/Royal) としてカード個別に保持される。非公式サーバー実装 YgoMaster のドキュメントがこれを明示（Player.json に保持、`UnlockAllCardsShine` 等の設定あり）。 https://github.com/pixeltris/YgoMaster/blob/master/Docs/Settings.md
- KONAMI公式: N・Rカードにロイヤル加工は存在しない（仕様）。→ 目的スキーマの `royal` は N/R では常に 0。 https://ja-support1.konami.com/hc/ja/articles/52812366125977
- ゲーム内には加工別の合計枚数を一覧する機能はない（フィルタで絞って数えるのみ、というユーザー報告）。
- 分解CP: ベーシック10 / シャイン15 / ロイヤル30、生成CPはレアリティ共通で30。→ 目的の「生成CP計算」への利用はこの3値で換算できる。

### プラットフォーム間データ
- 所持カード・加工情報は KONAMI ID データ転送でプラットフォーム共通。Steam版を取得元・Android版を確認用とする方針は妥当。
- 公式カードデータベース（KONAMI ID連携）で連携できるのは**デッキのみ**でコレクションは取れない（KONAMI FAQ）。よってコレクション取得経路は Companion App かクライアントローカルデータ解析に限る。
- ygomatpro 等の外部デッキビルダーへコレクションを取り込む機能は確認できなかった（検索でヒットせず）。

### 実施済み（2026-11-13）
- Steam版Master Duelを起動・更新（Ver 2.9.0）。タイトル画面→Companion App v1.33（scratch/companion、Net8）の起動とゲーム検出・アタッチまで成功。UIA操作で `File → Load Master Duel Profile and Decks` を実行したが `Substring not found` で失敗（直後に判明：ゲーム側で12.78GBの追加データダウンロード未完了が原因と推定）。ゲームは画面クリック（mouse_event）で GAME START→OK を実施しダウンロード完了後、ユーザー操作で終了。
- 画面確認は CopyFromScreen スクショ＋ローカル視覚認識、操作は UIA Invoke / SetCursorPos+mouse_event で成立することを実証。
- カードDB取得: `masterduel/master-duel-raw.json`（DawnbrandBots/yaml-yugi、81.4MB、13,948件）。検証結果: **`ja_name` は24件のみ（0.2%）でほぼ不在、`ja_text` は100%**。カード名は `title`/`en_name`（英語）基準。Master Duel固有IDフィールドは無し（`yugipedia_page_id` のみ）。→ 所持カードCSVとの照合は英語名 or yugipedia_page_id 経由が必要。
- 更新スクリプト `scripts/Update-MasterDuelDB.ps1` 作成・実行検証済み（SHA-256差分判定で「変更なし」を確認）。`masterduel/` は gitignore 済み。

### 代替DB調査（2026-11-13、要件: 日本語名＋更新頻度）
- **yaml-yugi `cards.json`（OCG/TCG全件・110MB）が第一候補**: 検証済みで `name.ja` あり（例: `{"konami_id":4297,"password":71407486,"name":{"en":"Fireyarou","ja":"<ruby>炎<rt>ほのお</rt></ruby>の魔神",...},"yugipedia_page_id":...}`）。`Last-Modified: 2026-11-13 09:14 GMT`（master-duel-raw.json と同一パイプライン・同日更新）。joinキーは `yugipedia_page_id` / `password` / `konami_id` / 英語名。⚠️ `ja` に `<ruby><rt>` ふりがなマークアップが含まれるため、名前一覧に使うなら剥離処理が必要。
- **YGOPRODeck API v7**（無償・鍵不要・20req/s・リアルタイム）: `misc=yes` で `konami_id`・`md_rarity`・8桁id が取れるが、**言語に日本語なし**（en/fr/de/it/pt/es のみ）。ID橋渡し役として併用価値あり。
- 却下: ocg-card.com（日本語・日次更新だがHTML由来で構造化IDが扱いにくい）、sushicircle TSV（2025-04手動スナップショットで更新低频）、公式DBスクレイピング系（非公式・ToSリスク）。
- 結論: 単一ソースでは「日本語名＋MD実装部分集合＋更新頻度」を全部満たさない。**master-duel-raw.json（MD部分集合・ja_text）＋ cards.json（ja_name辞書）の二枚構え**を推奨。更新頻度は両者同一（Yugipedia 4時間→GH Actions生成。Actions不安定の注意は両方に共通）。

### 外部評価の精査（2026-11-13 夜、全てDL実データで照合）
外部調査（ChatGPT生成）の「cards.json 第一候補」をダウンロード実データで検証した結果、ほぼ正確と確認:
- cards.json（105MB・Last-Modified 2026-11-13 09:14 GMT）: 14,442件（konami_id）。
- **`master_duel_rarity` が13,949件に実在（nullゼロ）、UR 1,638 / SR 2,954 / R 4,038 / N 5,319**。→ 「このフィールドでMD実装部分集合を抽出できる」という主張を実データで実証（master-duel-raw.json の13,948件とほぼ一致、キー無し493件はMD未収録と推定）。
- `ja` キーは1件あたり3つ（name.ja・text.ja・ja_romaji）でほぼ完全。ja_romaji は14,442件=全件。⚠️ name.ja の `<ruby><rt>` ふりがなは剥離が必要。
- **ygocdb cards.zip**（展開13MB）: 14,423件、`jp_name` 14,386件（99.7%・furigana無しで_cleanな形）だが `md_name`/`desc` は中国語（実サンプル: 青眼白龙）。→ 外部評価どおり日本語マスタには不可。日本語名・ID照合のバックアップ止まり。
- YGOJSON 更新停滞・daominah SQLite はスナップショット: 外部評価と一致（再ダウンロードまでは未実施）。
- **改訂結論: cards.json を単一プライマリ採用**（master-duel-raw.json は上位互換として不要化。ja_name無しのため退避）。更新スクリプトの対象URLを cards.json へ変更する（次ステップ・実装指示待ち）。join候補: `konami_id` / `password`（Companion CSV実出力で確定）。

### 結論（暫定）
1. 方式として Companion App → CSV は妥当。ただし目的スキーマの `normal/glossy/royal` 列が出る保証はない。
2. 加工列が出ない場合の代替は (a) Steam版クライアントのローカルデータ（コレクション/STYLE）を直接解析、(b) 加工列なしでカードID+枚数だけ取り、加工はゲーム内スクショ照合で人手補完、の順で検討。
3. スキーマには `royal` は N/R 不存在という制約注記が必要。

### デックアップロード調査（2026-11-13 夜）
- Companion のアップロードはアプリ側ログ上は常に成功: `scratch/companion/Log.txt` に `Storing 40 loaded deck(s)`→`Deck(s) stored successfully!` が **303/302回**（20:40–21:41、約5秒間隔のループ、ログ追記停止で21:41頃に終息）。
- 一方 YGOPRODeck アカウント（bwdsf3104, /author/bwdsf3104-336680）の Uploaded Decks は **21 のまま**（21:42 確認）。300回の再アップロードで新規行は1つも生成されず → サーバ側は同一デックを握り潰す（サイレント）。
- **欠落19デックは300回試行でも再現性ゼロ＝サーバ側での確定的なサイレント破棄**。アプリはHTTP成功のみ見て成功ログを出しており、再試行・「カード未収録」仮説は不要（未収録説はユーザー指摘で撤回）。原因特定には ygoprodeck 側のサーバログが必要 → Discord/サポートへアカウント名を添えて問い合わせる。

### デック復元の実施（2026-11-13 深夜・成功）
- 新規作成エンドポイントをサイト本体 UI の逆探りで特定: `POST /api/decks/submitDeck.php?time=<ms>`（deckbuilder の「Submit Deck」が叩くもの。フィールドは updateDeck.php と同一 + `deckSourceName/deckSourceURL`、`decknumber=null`、reCAPTCHA トークン不要、セッション認証のみ）。ページ内埋め込み JS の `submissionurl` / jQuery.ajax データ部から全フィールドを実コードで確認。
- 原因結論（証拠付き）: サーバ側の deckName バリデーションが非 ASCII を弾く。`updateDeck.php` で日本語名 `雷龍烙印` → 400 `{"error":"Deck Name is not valid!"}` を再現。既存の日本語名デック（744382〜744396）は検証導入前に作成されたもの。Companion は日本語名（19件）のアップロードで 400 を受けても本文を検査せず成功ログしていた → 303回の「成功」ログと0件の矛盾が説明つく。
- 実装: ydk（`scratch/companion/deck17*.ydk`）→ パスコード配列（`docs/ai/tmp/deckdata.json`）→ ログイン済み ygoprodeck タブから `submitDeck.php` へ直接 POST（`maindeckarray`/`maindeckarray_og`/`maindecknamesarray` はパスコード由来でもサーバが解決して表示・価格計算することは確認済み。名寄せ API は使わず namesarray=パスコードでも表示正常）。
- 作成結果（9/9 成功、getDecks.php で表示確認）: 175→744433 / 170→744434 / 171→744435 / 172→744436 / 173→744437 / 174→744438 / 176→744440 / 177→744441 / 178→744442（フォーマット=Master Duel Decks、公開）。
- ⚠️ 重複注意: 新旧で同名デックが生じている（例: 新 `Dragunity Maid` 744435 ≒ 旧 `ドラグニティメイド` 744385、`New Dragunity` 744442 ≒ `新ドラグニティ` 744383、`Ferret Rank4 ADCC` 744438 ≒ `フェレットランク４ADCC` 744387、`Thunder Dragon Branded` 744440 ≒ `雷龍烙印` 744396、`Sunclad Sacred Dragon` 744441 ≒ `聖刻スンクロ竜` 744382）。同一内容かは未照合。整理が必要なら不要側をサイト UI で削除可。
- 残: 内容未抽出の10デックは公式DB（dno）から同手順で追加可。日本語名のままの Companion 再アップロードは同じ 400 で失敗し続けるため不可。

## Verification

- DB精査: `pwsh -NoProfile -File docs\ai\tmp\verify_dbs.ps1` / `verify_dbs2.ps1` / `ygocdb_sample.ps1`（2026-11-13 実行、件数・レアリティ分布・言語サンプルは上記セクションに記載）
- 更新スクリプト変更なしパス: `pwsh -NoProfile -File scripts\Update-MasterDuelDB.ps1` →「変更なし：最新版を保持しています。」
- 2026-11-13 Companion CSV実出力: `scratch/companion/Card-Collection.csv`（12,183行、列=`Id,Name,MasterDuelRarity,Rarities`）。加工列あり（`Basic 4x, Glossy 1x`形式。シャイン4,851・ロイヤル125行）。`Id`はYGOPRODeck内部IDで password/konami_id とは異なる → 突合キーは正規化英文名。
- `scripts/build_collection.py` 実装・実行: NFKC正規化＋中点前後空白吸収で **12,183/12,183 全件一致（不一致0）**。password単位集約で 12,157 行、枚数合計 63,195（normal 55,697 / glossy 7,368 / royal 130）。出力 `output/collection.csv`（card_id=password, name=日本語・furigana剥離, quantity, normal, glossy, royal）。
- 残検証: ゲーム内コレクション総枚数との照合。
- デック復元: `submitDeck.php` 9件 POST 全て HTTP 200 + `success` レスポンス（デッキID上記）。`getDecks.php` の新着ページで 744433〜744442 の9件とカード表示・40/15枚数を確認（deck 744433 のページ HTML にカード名が解決されて出力されていることを直接確認）。

## 完了時 Memory Bank 操作

- [ ] `current-task.tsv` の参照行を削除
- [ ] 解決した `known-issues/` ファイルを `known-issues/archive/` へ `mv`（該当する場合）
- [ ] `backlog.md` の完了項目を削除（該当する場合）
