# Private Token Workshop - プライベートトークンプログラム

このプロジェクトは、Aleoブロックチェーン上でコンプライアンスを維持しつつプライバシーを保護するトークンプログラムです。

## 📋 プログラム概要

- **プログラム名**: `private_token_workshop.aleo`
- **機能**: パブリック/プライベートでのmintとtransfer機能
- **コンプライアンス**: OFAC制裁リストチェック統合

## 🚀 クイックスタート

### 前提条件

- Leo CLI がインストールされていること
- Rust がインストールされていること
- テストネットクレジット（デプロイ時に必要）

## 🔨 ビルド

プログラムをコンパイルしてAleoインストラクションに変換します。

```bash
cd token_template
leo build
```

**成功時の出力例:**
```
✅ Compiled 'private_token_workshop.aleo' into Aleo instructions.
```

## 🧪 テスト

テストを実行してプログラムの動作を確認します。

```bash
leo test
```

**注意**: 外部プログラム（`workshop_ofac.aleo`）への依存があるため、ローカルテストは制限されます。完全なテストはデプロイ後に行うことを推奨します。

## 📦 デプロイ

### 1. 環境変数の設定

`.env`ファイルを作成して、ネットワークと秘密鍵を設定します。

```bash
echo "NETWORK=testnet" > .env
echo "PRIVATE_KEY=<あなたの秘密鍵>" >> .env
ENDPOINT=https://api.explorer.provable.com/v1
```

### 2. テストネットクレジットの取得

デプロイには手数料が必要です。[テストネットフォーセット](https://faucet.aleo.org/)からクレジットを取得してください。

### 3. デプロイ実行

```bash
source .env
leo deploy --network testnet
```

以下のようになればOK!

```bash
🛠️  Deployment Plan Summary
──────────────────────────────────────────────
🔧 Configuration:
  Private Key:        APrivateKey1zkp2NJQ7JzR6...
  Address:            aleo1yzxkqudh9at6jjh3d4f...
  Endpoint:           https://api.explorer.provable.com/v1
  Network:            testnet
  Consensus Version:  11

📦 Deployment Tasks:
  • private_token_workshop.aleo  │ priority fee: 0  │ fee record: no (public fee)

📊 Deployment Summary for private_token_workshop.aleo
──────────────────────────────────────────────
  Total Variables:      175,388
  Total Constraints:    127,217
  Max Variables:        2,097,152
  Max Constraints:      2,097,152

💰 Cost Breakdown (credits)
  Transaction Storage:  4.287000
  Program Synthesis:    0.302605
  Namespace:            1.000000
  Constructor:          0.002000
  Priority Fee:         0.000000
  Total Fee:            5.591605
──────────────────────────────────────────────
```

## 📖 メソッド呼び出し方法

### 1. mint_public - パブリックトークンの発行

パブリックマッピングに記録される形式でトークンを発行します。

```bash
leo run mint_public <受取人アドレス> <金額>
```

**例:**
```bash
leo run mint_public aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px 100u64
```

**パラメータ:**
- `recipient` (address): トークンを受け取るアドレス
- `amount` (u64): 発行するトークン量

**動作:**
- OFAC制裁リストに対して受取人アドレスをチェック
- `balances`マッピングの受取人残高を更新
- オンチェーンで残高が公開される

---

### 2. mint_private - プライベートトークンの発行

プライベートレコードとしてトークンを発行します。

```bash
leo run mint_private <受取人アドレス> <金額>
```

**例:**
```bash
leo run mint_private aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px 50u64
```

**パラメータ:**
- `recipient` (address): トークンを受け取るアドレス
- `amount` (u64): 発行するトークン量

**動作:**
- OFAC制裁リストに対して受取人アドレスをチェック
- 新しい`Token`レコードを作成
- レコードの内容は受取人のみが知ることができる
- ゼロ知識証明により検証可能

**出力例:**
```
{
  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,
  amount: 50u64.private,
  _nonce: <ランダムなnonce>.public
}
```

---

### 3. transfer_public - パブリックトークンの転送

パブリックマッピング上で送信者から受取人へトークンを転送します。

```bash
leo run transfer_public <受取人アドレス> <金額>
```

**例:**
```bash
leo run transfer_public aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t 25u64
```

**パラメータ:**
- `recipient` (address): トークンを受け取るアドレス
- `amount` (u64): 転送するトークン量

**動作:**
- OFAC制裁リストに対して受取人アドレスをチェック
- `self.signer`（トランザクション開始者）から`amount`を減算
- `recipient`の残高に`amount`を加算
- すべての残高変更がオンチェーンで公開される

**注意:**
- 送信者の残高が不足している場合、トランザクションは失敗します
- 送信者は`self.signer`として自動的に決定されます

---

### 4. transfer_private - プライベートトークンの転送

プライベートレコードを使用してトークンを転送します。

```bash
leo run transfer_private '{sender_token_record}' <受取人アドレス> <金額>
```

**例:**
```bash
leo run transfer_private '{
  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,
  amount: 100u64.private,
  _nonce: 1234567890group.public
}' aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t 40u64
```

**パラメータ:**
- `sender` (Token record): 送信者が所有するトークンレコード
- `recipient` (address): トークンを受け取るアドレス
- `amount` (u64): 転送するトークン量

**動作:**
- OFAC制裁リストに対して受取人アドレスをチェック
- 送信者のレコードを消費
- 2つの新しいレコードを作成:
  1. 受取人用: `amount`のトークン
  2. 送信者用: 残高（元の金額 - `amount`）

**出力例:**
```
// 受取人のレコード
{
  owner: aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t.private,
  amount: 40u64.private,
  _nonce: <新しいnonce>.public
}

// 送信者の新しいレコード（お釣り）
{
  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,
  amount: 60u64.private,
  _nonce: <新しいnonce>.public
}
```

**重要:**
- レコードは一度しか使用できません（UTXO モデル）
- プライベート転送では金額が秘匿されます
- ゼロ知識証明により、金額を明かさずに検証可能

---

## 🔍 実行例のワークフロー

### シナリオ: Alice が Bob にプライベートトークンを送る

```bash
# 1. Alice 用にプライベートトークンを発行（100トークン）
leo run mint_private aleo1alice... 100u64

# 出力されたレコードをコピー
# {
#   owner: aleo1alice....private,
#   amount: 100u64.private,
#   _nonce: 123456group.public
# }

# 2. Alice が Bob に 40トークンを転送
leo run transfer_private '{
  owner: aleo1alice....private,
  amount: 100u64.private,
  _nonce: 123456group.public
}' aleo1bob... 40u64

# 3. 2つのレコードが出力される:
#    - Bob のレコード (40トークン)
#    - Alice の新しいレコード (60トークン)
```

### シナリオ: パブリック転送

```bash
# 1. Alice 用にパブリックトークンを発行（200トークン）
leo run mint_public aleo1alice... 200u64

# 2. Alice が Bob に 75トークンを転送
leo run transfer_public aleo1bob... 75u64

# 3. オンチェーンの残高が更新される:
#    - Alice: 125トークン
#    - Bob: 75トークン
```

---

## 📊 パブリック vs プライベート比較

| 特徴 | パブリック | プライベート |
|------|-----------|------------|
| **残高の可視性** | オンチェーンで全員が見える | 所有者のみが知っている |
| **データ構造** | Mapping（address => u64） | Record（owner, amount） |
| **トランザクション履歴** | 完全に追跡可能 | プライバシー保護 |
| **ガス効率** | より効率的 | ZK証明のため高コスト |
| **使用例** | 監査が必要な場合 | プライバシーが重要な場合 |

---

## 🔐 セキュリティとコンプライアンス

### OFAC制裁チェック

すべてのmintとtransfer操作は、`workshop_ofac.aleo`プログラムを通じて受取人アドレスの制裁チェックを実行します。

```leo
let address_check: Future = workshop_ofac.aleo/address_check(recipient);
```

制裁対象アドレスへの転送は自動的に拒否されます。

---

## 🛠️ トラブルシューティング

### ビルドエラー

**エラー:** プログラム名が一致しない
```
Error: Program name mismatch
```

**解決策:**
- `src/main.leo`の`program private_token_workshop.aleo {`
- `program.json`の`"program": "private_token_workshop.aleo"`

両方が一致していることを確認してください。

### デプロイエラー

**エラー:** クレジット不足
```
Error: Insufficient credits
```

**解決策:**
[テストネットフォーセット](https://faucet.aleo.org/)からクレジットを取得してください。

### 転送エラー

**エラー:** 残高不足（パブリック転送）
```
Error: Mapping operation failed
```

**解決策:**
送信者の残高が十分か確認してください。`balances`マッピングを確認。

**エラー:** 無効なレコード（プライベート転送）
```
Error: Invalid record
```

**解決策:**
- レコードが正しい形式か確認
- レコードが既に使用されていないか確認（レコードは一度のみ使用可能）

---

## 📚 追加リソース

- [Aleo Developer Docs](https://developer.aleo.org)
- [Leo Language Documentation](https://docs.leo-lang.org)
- [Aleo Discord](https://discord.gg/aleo)
- [テストネットエクスプローラー](https://testnet.explorer.provable.com)
- [テストネットフォーセット](https://faucet.aleo.org/)

---

## 📝 プログラム情報

- **バージョン**: 0.1.0
- **ライセンス**: MIT
- **依存関係**: `workshop_ofac.aleo` (ネットワーク依存)

---

## 🎯 次のステップ

1. ✅ プログラムをビルド
2. ✅ テストネットにデプロイ
3. ✅ mint_public/mint_privateでトークンを発行
4. ✅ transfer_public/transfer_privateで転送をテスト
5. 💡 BONUSタスク: `convert_public_to_private`などの追加機能を実装

Happy coding! 🚀