# Private Token Workshop - プロジェクト概要

## プロジェクトの目的
このプロジェクトはAleoブロックチェーン上でプライバシーを保護しつつコンプライアンスを維持するトークンを構築するためのワークショップです。

## 主な技術スタック
- **Leo言語**: Aleoブロックチェーン用のDSL（Domain Specific Language）
- **Aleo**: プライベート実行環境を提供するブロックチェーンプラットフォーム
- **Git**: バージョン管理
- **Dev Container**: Docker ベースの開発環境

## プロジェクト構造
- `token_template/`: メインの開発ディレクトリ（トークンプログラムのテンプレート）
  - `src/main.leo`: メインのトークンプログラム
  - `tests/test_token.leo`: テストファイル
  - `program.json`: プログラム設定ファイル
- `workshop_ofac/`: OFAC準拠チェック用プログラム（デプロイ済み、編集不要）
- `docs/`: ドキュメント

## 主な学習目標
1. Aleoでの基本的なトークン作成
2. パブリック/プライベートの`transfer`と`mint`機能の実装
3. コンプライアンスチェックの統合

## 開発フロー
1. トークン名の設定
2. `mint_public` 機能の実装
3. `mint_private` 機能の実装  
4. `transfer_public` 機能の実装
5. `transfer_private` 機能の実装
6. テストネットへのデプロイ