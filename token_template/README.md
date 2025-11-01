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

以下のようになればOK!

```json
{
  program_id: private_token_workshop.aleo,
  function_name: mint_public,
  arguments: [
    aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px,
    100u64,
    {
      program_id: workshop_ofac.aleo,
      function_name: address_check,
      arguments: [
        3945141883375476130743366659011577342275372042624438262538757342426909353342field
      ]
    }
  
  ]
}
```

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

```json
{
  owner: aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px.private,
  amount: 50u64.private,
  _nonce: 6248617742400486139301751460470359670298306417478254389280191187544158303746group.public,
  _version: 1u8.public
},
{
  program_id: private_token_workshop.aleo,
  function_name: mint_private,
  arguments: [
    {
      program_id: workshop_ofac.aleo,
      function_name: address_check,
      arguments: [
        3945141883375476130743366659011577342275372042624438262538757342426909353342field
      ]
    }
  
  ]
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

以下のようになればOK!

```json
{
  program_id: private_token_workshop.aleo,
  function_name: transfer_public,
  arguments: [
    aleo1yzxkqudh9at6jjh3d4ffkn3dmu6yfndm0mym6hzj48w6kua0j58sshtfmz,
    aleo1s3ws5tra87fjycnjrwsjcrnw2qxr8jfqqdugnf0xzqqw29q9m5pqem2u4t,
    25u64,
    {
      program_id: workshop_ofac.aleo,
      function_name: address_check,
      arguments: [
        8262976664323574687514719411225956605314326284618329588497599327151503201791field
      ]
    }
  
  ]
}
```

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

## Leo Playground

Leo Playgroundでも実装可能

コントラクトをデプロイしたトランザクション

[at1qxe4rz6z4zu3d7ud9eengk4nypv55v3emzft37ln3usfpah4tspq4c63hx](https://testnet.explorer.provable.com/transaction/at1qxe4rz6z4zu3d7ud9eengk4nypv55v3emzft37ln3usfpah4tspq4c63hx)

修正後のコントラクトをデプロイしたトランザクション

[at1s5y5azyc8dlzyew0k7rmf8cnrnn4p7d3lgdfjxk74tqkqk8hegqsw449xt](https://testnet.aleoscan.io/transaction?id=at1s5y5azyc8dlzyew0k7rmf8cnrnn4p7d3lgdfjxk74tqkqk8hegqsw449xt)

デプロイしたコントラクト

[private_token_workshop.aleo](https://testnet.explorer.provable.com/program/private_token_workshop.aleo)

デプロイした修正後のコントラクト

[private_token_workshop2.aleo](https://testnet.aleoscan.io/program?id=private_token_workshop2.aleo)

トークンのミント(パブリック)

[at1zvm04wa2e9l3xzcrxyjap7v7wjqqk42d7pyxcf92dkaml79jmgrqk9qy9l](https://testnet.explorer.provable.com/transaction/at1zvm04wa2e9l3xzcrxyjap7v7wjqqk42d7pyxcf92dkaml79jmgrqk9qy9l)

修正後のトークンのミント(パブリック)

[au16jsn4528nrr0p9dtwkj00fxwrlkq6wrh35zfuww4lpxqw7v82q9smus45k](https://testnet.aleoscan.io/transition?id=au16jsn4528nrr0p9dtwkj00fxwrlkq6wrh35zfuww4lpxqw7v82q9smus45k)

トークンの送金(パブリック)

[at1csg8rumv8puax23g7uvtpxv2ztrljrqya0lam8rzq7y30qcplc8sv0qwsc](https://testnet.explorer.provable.com/transaction/at1csg8rumv8puax23g7uvtpxv2ztrljrqya0lam8rzq7y30qcplc8sv0qwsc)

修正後のトークンの送金(パブリック)

[]()

トークンのミント(プライベート)

[at1fm02epu6jkhlf075fr0xkahueha86y93pm2mrdkz9kxqxxyujqxqqj7w9z](https://testnet.explorer.provable.com/transaction/at1fm02epu6jkhlf075fr0xkahueha86y93pm2mrdkz9kxqxxyujqxqqj7w9z)

トークンの送金(プライベート)

呼び出し方が少し特徴的

[at1csxxv8njel890n8n28cnz4f44xlxz5rywpy0p4505w9gl2pzmyzsx08kjf](https://testnet.explorer.provable.com/transaction/at1csxxv8njel890n8n28cnz4f44xlxz5rywpy0p4505w9gl2pzmyzsx08kjf)


引数に必要なプライベートレコードは以下のようなデータ

```json
{"type":"execute","id":"at1lssexymxar0s7qwfqlusjszvl74xhfljwlt4vunufd83gqf22vzsdswsm2","execution":{"transitions":[{"id":"au1prfux8tat334zc8mtgmrj5pfdeu6jws63ut0j5drst5l8aujlqrsg6gakf","program":"workshop_ofac.aleo","function":"address_check","inputs":[{"type":"private","id":"5704556651447330545380805671772239846627985102824664334921468497962405747023field","value":"ciphertext1qgqrzazkdl82quhax2f9glx4fknn9lakh435934q40gdqp0fn8yhuynpg9xg677cntcu8nt37ulmlusmjwnm0vh7l7n30esg8j3vwna8pykew9k7"}],"outputs":[{"type":"future","id":"5847367376096340361677016583030518759611698398778460269448793107653640588898field","value":"{\n  program_id: workshop_ofac.aleo,\n  function_name: address_check,\n  arguments: [\n    1251640957263217639013493217773409421597629629071727269236770848286867455063field\n  ]\n}"}],"tpk":"3289834023941010304406458637408431874627596440946201465826644565975407981680group","tcm":"3215983464783433252457812889459296673749326122458021971757928760595965459146field","scm":"3058463153696202626012751084747890130363207417432245085907520574485392088276field"},{"id":"au18ju82pjkwx2h0hku9d0p9g9qt6ky3730wy56a34hhkd5vrstq59qucunjg","program":"private_token_workshop.aleo","function":"mint_private","inputs":[{"type":"private","id":"8076221050345611872143337854308638719814902961945752666358231303832725722426field","value":"ciphertext1qgqw7k3yuf72ewx4u92ckkj0jdxqcdpvdkqtkujw2p6cny5ymjzucqx44dspc5vph49q7khjrf5hdcu3sjum4qy0h99kuyky57ug8uqeqc7l2uwr"},{"type":"private","id":"5447500030499126908641036725933945071852915154976201091617494351360318242599field","value":"ciphertext1qyqdra2625kdct2h88np46xwyxd8jp97k4cp33tqdsx7r30ew7klvpcxegzjs"}],"outputs":[{"type":"record","id":"8025745261126952987613205423714690443005239781247092819961390480364488624546field","checksum":"2599877263784763936758008712110816027538105139492264301344078344229189864531field","value":"record1qvqspx6fsewx2p7zguedulu66hdwjp56hefjxeyuzke6v8sznqsp9vgyqyrxzmt0w4h8ggcqqgqspavyzck00k6h5wqqhcyssy928aqy8q3gm22j5rh7hgktrju4dmggg6l7levv7ft97c56l67rwmdd8cd546stk8puvfmj8tcs7mehzv8qr4klnd","sender_ciphertext":"8166076987858004462579576744297230678867188222137805883866823282788132381716field"},{"type":"future","id":"6760252992770659448570922773215778444734776001604970421588149080999266988952field","value":"{\n  program_id: private_token_workshop.aleo,\n  function_name: mint_private,\n  arguments: [\n    {\n      program_id: workshop_ofac.aleo,\n      function_name: address_check,\n      arguments: [\n        1251640957263217639013493217773409421597629629071727269236770848286867455063field\n      ]\n    }\n  \n  ]\n}"}],"tpk":"6465135873917826230824806795457019547756491075244212127383448298251106478094group","tcm":"6241354246452546197137850361073295094137078814127394012341793654063428477224field","scm":"3058463153696202626012751084747890130363207417432245085907520574485392088276field"}],"global_state_root":"sr1xngn0h9p7vdq6xt0pkd2xsu5agz3s5nm4n20fzlw53hsqg858qzqrhxnxv","proof":"proof1qypqqqqqqqqqqqqpqqqqqqqqqqqqzqqqqqqqqqqqshgn8wau047nt6xl8t93j80w4vzy9jhtgcvf5e4jd2fkalkefcxf830lsardek5ytd3xn0lserccpd82ny5nz05500yd0qscmqhkmutswdnwwcuf08v7wjauwspkv08kmffasr092vw6hh8cl3fxu22xqyq705pdtd9h7dc2ad3l8qlhfsh8l76trghhdm5n63q82m644cy3z0qapd0c37xjnu6jtxc98nhpwe5pffmftdeau3fpejuvhqgts0e7aw435lmq0qh57v5gjjn8l223jwqhtpdezlqjldthvgcvd8k7lyrgqt4y0yxmgjhgvjsesst3k8mxdwl4npdk0j3gpszjspnd2dnjf50l24n3a7vrdxa784yjvy25ketcqz0rfg8a8ufk9elw48xn2vfmc0zplx6nemsrjkrwzp8xpl68sjg2y52fqcdhqfjqrsdan4q47lqfpqfnj8pdhmrajr44esp43c2ea0msnt7jc4jushkvm5vdczt8mm5vkcs6f0zcwwlx5cyjc36zm2nj3sq0uvpgg2kjnyajrdphmtte0a34dpmsapq4nppt3xfy6lldl0vquqz0hcepp6wpsnw738u6vjyhu4gpjlpdjd38qlhd576wpkvxx48va0vluacudrftndc7ww6jw590lucg4ncuteh0tg2fktyeltgq0zugqk93lwcxzc3h8x3fu57wr2gfxa8gjw3huaws83lq9au3z8ex0nx4032ttmky605m2n78k5tnkg30qx84ul3nrxpht2huas8z49phtjgw3u2z7nyk3kfu3ayddhepjcyge5j8laxzfytpydk8cx6cc5wduqydufrjzx8rmxxgqdva8utnupa34efl69esycfrvxecp8sqvghfmncvjpcan3hf269ma50md372fkqqprz69ze30sa3m23jnde744wyl0pq3tafzux9y2wp8mxmulr6gz0auqkh4epaxlmgapjv3crkxeypfgrdt662n2hymfg57hnsaygsk3nsrve3wfd93xnvuwlejujhwgpc3r7kfz3ecvx7cyzuhpllkcdn0n2rrrp2zm0p5v4g7q0qs023sqakad2ce28jh62htyxynye7kjsmct3fqvg9vsdxk4f5c3nfl7l0zplfsx9t2tvkaz23kd5m29kpzmnv00t59n94fld4g3n8va8e9kjs80k3x5rpeen6ug09t4z0375utkqh42ht3jdey5hk66kyvus9k3qg6e0cnry7xlykrkwdy57k5c3pnjsrhlt723danyeslldng65r7qqwfn82uyz9yelqxxm3qcxgqcqjq2hc9szh58hz5mr0hsd00j7hsplfdd4427gd3xdr0qpqvkc3thaunn4j44yvs7fq7qyx8444qnk0zx78l65x9qsnkxpgq33ezk8hj0aumcs0k9ppp38q569q50wywlvqqtxhvk7wumyqm6g6vwrrsnskqxn5ssj2xw02dwh3643vkcyqcjq39z0u9g36h57tgxfejkfp3vx63yuqxa4l58fzzakxcpygctv0kqpvmj0wnqax2hwxchhjgx7xzts7ynj5x2x8q0djrkkstw82lrhzyza2y6zqejpgd3vdwhhasujsjfpjs8qksd89cdfm57nanrsgvdwpqnw7r9fs29qy6fz83y3a40sryppdvwjt4pqgxsc0h0de28093anqqglxs7eh5tjuq07c38yljqrn4asu0dlmr9gvckga22967cvrahs3gjjz20ke4y0ycczrq4snfymcl74usyavxrwndmryk6w3y9nqryruy5yxazv2yx6wn864df3mdf2tedratk5wcehuy63usdadg3pc7phg32q9dyzswmjscfw7dz4c7lulnl4znpclvtvhxzt8mhjf2ahhp0jqzdapvpdpq5nt2anzvludgdaafl33zyt9g5e0npwzd30araeqgqcqqqqqqqqqqp04zfapdn6jyafmgz3nslp7x6pqcs6hyea7rlv2h65nencmkg3dx38w6cpmyre0s2p2h6mq3dcjuqgq6qdht3wfvc3gcl0ctkp20dlsv4faczwhu7qh8xpd9yrmjqntk0kwn0w3y90h2gdulfmy6ywxsfmcqq2uz8cdlezjau4vv72l99qjdwvwdkxvwnzj6055rp74u0v7q54np3fpw8d7tyay979xaxr382uayc9czzm73j4vajldg6vh73gj25z6yhqpsvv8akuqm95r3zmfnnjk9qqq0tq00p"},"fee":{"transition":{"id":"au1e0qx8x8tsrv3t3s3kueqdwlk6qez9zm76ca0du64yfyslfr65sxsqyq9n9","program":"credits.aleo","function":"fee_public","inputs":[{"type":"public","id":"6424656139355079727072686636172212837312528323002997835002737758842054384249field","value":"5872u64"},{"type":"public","id":"5771746316354873561717496658470156090700630167984870737334990789424762793881field","value":"0u64"},{"type":"public","id":"5274907872665473798758719746238980143458886460558473341182345302067584691098field","value":"6697944787605130071403717077629946648164428040264878094238205888281288596173field"}],"outputs":[{"type":"future","id":"8136082946583160894625257261196091508555046388315952387220879349444380460209field","value":"{\n  program_id: credits.aleo,\n  function_name: fee_public,\n  arguments: [\n    aleo1yzxkqudh9at6jjh3d4ffkn3dmu6yfndm0mym6hzj48w6kua0j58sshtfmz,\n    5872u64\n  ]\n}"}],"tpk":"4238489367528996041101168063765611160255193817403600254880182936818356317151group","tcm":"6879707994236674863122513884637965582260208927622406833424310708472018164400field","scm":"1087944874979962712564188533466567477220858559274300529610619744056058778035field"},"global_state_root":"sr19680wcctunfl62thw87wkcmyavd6lwkavhcmcvn4yjh2euuelvgsgeehf0","proof":"proof1qyqsqqqqqqqqqqqpqqqqqqqqqqqgaxh8m0ryfq08we3cnh3wu94typg4f8ylejmx3g7j8nwej2khajsfrrsgxwm8wkyt5m6vac9yjwyqq9zjmhdau8094tqmfstcedsa8c8acwwrmnd5lmklh4clas4amfachgkue37nr96d90d26dt5rjn22qgwxvw3p8jcet2jy2p06m3e7hwsuy2npgjvetzgcdz7t0c0hg798260muyc9g4sm6hs8w87e8tzejqg0nl5e5an2wc0pym6awjgdgd7yl0j3u5xnr43zdfk9cm4g984g64msfvulvtqrwuhld9vtqy7smuq8qt9ee4y9gapgtcdcxxh2pvw05h6sn76gd3dts6gu5zp4y4hjlwlm824zpvcvslnwws9jssy0kdszd2samjl5xk6tdhfdghfr25jqpazx79ez7s48qj7ck3key0tnkzvqdxvj8uzg6gtaeuq2eneuwv3q83s5500qjap7t4s4rmr39lgl2d4gpqmldq4y64xtk76jyqqcrdresaxx6lpxyl32y3dkye7txr8lqwa50t2mezh3khu9hv27eqrwqj6we4dwudh5n89r474apkqd3tnkxecz3fpskl9zhtcdkrf2ga49zqsadupuxyevpmktnuj24juldntnwgcujp0wl692k2ratdsfsztld3q2s2lskelp02fe57tnh69ztyqza80wplja6z9l0zamhavk5e3aslw3q9gvjqd8vevxrch4dpy8cymu3ula7szfst3xj04djysm4j2jh9qtwz2my0cn0xlm2nqkfm67qg4jgmpq3g60dy5rgz2047g3dff8ea8w84jw5a80jjtxcdw79ytzyr3jm0mcvhmrfk9g6cgtrwhqfg7frdu8s3ps4yleqy3yc0f7zvqr0qnuy82j024edm0qe0ut3kzvmrc4gmay769lk582wj9h87dkjs0j94lqq03xht3enfv765j3wkh6f8hg6utzm6zz4lfsyaxvx7q7gg30wypc3um35p4wtncr5dkvvjrk78j9a4qljqt0ca82238ktf37zl8p4ujktm343a6jyxgwrjpw7xh4p5tesrxzp32m7jnr0tsssepp0p4smq690p4ad72lrh36hlucxxk0ca40zg40vhwy9uzses2crwspr4yfm4vgyamufz8kp4uwkpqxev2gxpn4a0v3rnjls748f57pjcrqvqqqqqqqqqqqur5c2uqlzy9wthd08rcpn9jytmzs2s9xsp0jdtw0ty5nfzuquezarcvv72nxv5mpfh7w45mnuumsyqtldwcv7fjsyv6jv2uh9wft9kv2tcmkd7k7g6tj27twurqrrn0l6jdteawcqtj5mkaekz7lx49d9ypq8prd7mxajztvse0sq0cxedua5xqck3ukuzwt8zkf820fdc83q7s9tmjrsmxtz5f84jwe36q2z7dmyggt2sz0f2gj88xy8zmlckmrp5cfa2ty33k65rwp055656tndp4qqqqcgmqnh"}}
```

