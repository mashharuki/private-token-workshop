# 推奨コマンド一覧

## Leo関連コマンド
```bash
# プロジェクトのビルド（token_templateディレクトリで実行）
leo build

# テストの実行
leo test

# プログラムのデプロイ（テストネット）
leo deploy

# プログラムとの対話的実行
leo run <function_name> <args>
```

## Git関連コマンド
```bash
# 変更の確認
git status

# ファイルをステージング
git add .

# コミット（コンベンショナルコミット形式推奨）
git commit -m "feat: implement mint_public function"

# プッシュ
git push origin main
```

## プロジェクト特有コマンド
```bash
# token_templateディレクトリへの移動
cd token_template

# プロジェクトディレクトリ構造の確認
tree

# Leoファイルの構文チェック
leo check
```

## システム関連コマンド
- `ls`, `cd`, `pwd`: ディレクトリ操作
- `grep`, `find`: テキスト検索
- `cat`, `less`: ファイル内容表示
- `tree`: ディレクトリ構造表示