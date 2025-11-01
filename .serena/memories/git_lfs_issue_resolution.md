# Git LFS問題と解決策

## 現在の問題
- リポジトリがGit LFS用に設定されているが、git-lfsコマンドがシステムにインストールされていない
- pushを実行すると以下のエラーが発生：
  "This repository is configured for Git LFS but 'git-lfs' was not found on your path"

## 解決策オプション

### オプション1: Git LFSをインストール（推奨）
```bash
# Debian/Ubuntu系の場合
sudo apt update
sudo apt install git-lfs

# インストール後の初期化
git lfs install
```

### オプション2: Git LFSフックを削除（LFS不要の場合）
```bash
# pre-pushフックを削除
rm .git/hooks/pre-push

# またはフックを無効化
chmod -x .git/hooks/pre-push
```

## 現在のプロジェクトでの推奨
- プロジェクトに大きなファイル（>10MB）が存在しない
- 主にテキストファイル（.leo, .json, .md）で構成
- **推奨**: オプション2（Git LFSフックの削除）

## 実装の影響
- 既存のファイルには影響なし
- 将来大きなファイルを扱う場合は改めてGit LFSの設定を検討