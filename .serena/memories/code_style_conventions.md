# コードスタイルと規約

## Leo言語の規約
1. **命名規則**:
   - プログラム名: `token.aleo` (10文字以上推奨)
   - 関数名: snake_case (`mint_public`, `transfer_private`)
   - 変数名: snake_case
   - 型名: PascalCase (`Token`)

2. **コードスタイル**:
   - インデント: 4スペース
   - セミコロン: 文末に必須
   - 関数の分離: `async transition`と`async function`を明確に分ける

3. **コメント**:
   - 機能の説明をコメントで記述
   - 複雑なロジックには詳細なコメント

## プロジェクト構造の規約
1. **ファイル配置**:
   - メインプログラム: `src/main.leo`
   - テスト: `tests/`ディレクトリ内
   - 設定: `program.json`

2. **依存関係管理**:
   - `program.json`で依存関係を管理
   - ネットワーク依存関係は`location: "network"`で指定

## Git規約
1. **コンベンショナルコミット**:
   - `feat:` 新機能追加
   - `fix:` バグ修正  
   - `test:` テスト関連
   - `docs:` ドキュメント更新
   - `refactor:` リファクタリング