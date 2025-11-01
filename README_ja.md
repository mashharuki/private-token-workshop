![](./docs/images/aleo-workshop2.png)

# コンプライアント プライベートトークン ワークショップ

このワークショップでは、Aleoブロックチェーン上でコンプライアンスを維持しつつプライバシーを保護するトークンの構築方法を学びます。

# 目標と学習内容

このワークショップを通じて、開発者は以下を学習します：
- Aleoがコンプライアントなプライベート決済・取引を可能にする独自のポジションにある理由

- Leoでの基本的なトークンの作成方法

- そのトークンにパブリック/プライベートの`transfer`と`mint`機能を実装する方法

# はじめに

### Leo Playground
開発が初めての方やLeo言語を試してみたい方は、**[Leo Playground](https://play.leo-lang.org)**をチェックしてください。これはウェブベースのIDEで、ブラウザ内でプログラムの構築、デプロイ、実行が可能です！エディタ、Github統合、プログラム管理やネットワークとのインターフェース用の多数のユーティリティが含まれています。

### VSCode / Sublime Text / IntelliJ
より経験豊富な開発者向けに、Leoチームは様々なエディタ用のプラグインも維持しています。お気に入りのエディタへのインストール方法については、**[開発環境](https://docs.leo-lang.org/getting_started/ide)**ガイドで詳細を確認してください。

また、Leo CLI（およびRust）をローカルにインストールする必要があります。詳細については**[インストール](https://play.leo-lang.org)**ガイドを確認してください。

### テストネットフォーセット
プログラムをオンチェーンにデプロイするために、テストネットトークンが必要です。INSERT_LINK_HEREにアクセスして取得してください。

### 追加リソース：
- [Aleo Developer Docs](https://developer.aleo.org) 
- [Leo Docs](https://docs.leo-lang.org)
- [Aleo Discord](https://discord.gg/aleo)

# リポジトリ概要

### `token_template/`
ここがすべてのコーディングを行うLeoプロジェクトです。プライベート残高用の`record`タイプやパブリック残高を追跡する`mapping`など、いくつかの基本機能が含まれています。

さらに、関数シグネチャ/ヘッダーがすでに提供されており、各関数で実装する必要がある機能のリストも含まれています。

<!-- 最後に、作業をチェックするためのテストケースセットが作成されています。プロジェクトディレクトリで`leo test`をコマンドラインから実行するだけです。 -->

### `workshop_ofac/`
`workshop_ofac.aleo`プログラムは、オンチェーンコンプライアンスチェックを模倣するように設計されています。模擬的な「OFAC制裁対象アドレス」の簡単な`mapping`と、そのマッピングに対してアドレスを検証する`transition`関数が含まれています。

このプログラムはすでにテストネットにデプロイされており、`token_template` Leoプロジェクトにリモートネットワーク依存関係として追加されています。これは純粋に参照用です。`workshop_ofac/`内の何かを編集/使用したり、`token_template/`の依存関係を編集したりする必要は**ありません**。

# 環境構築

VSCodeを立ち上げたら Reopen in DevContainerで開発環境用のコンテナを起動してください。

コンテナがビルドされたら以下のコマンドを順番に実行して

leo CLI と snarkOS CLIをインストールします。

```bash
# Leoのインストール
echo "Installing Leo (this may take 10-20 minutes)..."
cd /tmp
if [ -d "leo" ]; then
    rm -rf leo
fi
git clone --recurse-submodules https://github.com/ProvableHQ/leo
cd leo
# リンカーの設定を明示的に指定
RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo install --path . || {
    echo "Leo installation failed, trying without lld..."
    cargo install --path .
}
cd /tmp
rm -rf leo
```

```bash
# SnarkOSのインストール
echo "Installing SnarkOS (this may take 15-25 minutes)..."
cd /tmp
if [ -d "snarkOS" ]; then
    rm -rf snarkOS
fi
git clone --branch mainnet --single-branch https://github.com/ProvableHQ/snarkOS.git
cd snarkOS
# リンカーの設定を明示的に指定
RUSTFLAGS="-C link-arg=-fuse-ld=lld" cargo install --locked --path . || {
    echo "SnarkOS installation failed with lld, trying default linker..."
    cargo install --locked --path .
}
cd /tmp
rm -rf snarkOS
```

インストール後に元のディレクトリに戻る

```bash
cd /workspaces/private-token-workshop 
```

# ビルド

まず、提供されたテンプレートコードを埋めることで、Leoでトークンプログラムをビルドします。プログラムには以下が含まれます：
- `mint_public`と`mint_private`機能
- `transfer_public`と`transfer_private`機能
- `workshop_ofac.aleo`の`sanctioned`マッピングに対するコンプライアンスチェック

## タスク 0: トークンに名前を付ける
トークンプログラムの名前を選択してください！追加のネットワーク手数料を避けるため、10文字以上にする必要があります。また、ネットワーク上の既存のプログラムと競合しないようにしてください。

名前を決定したら、`main.leo`の上部にあるプログラム名を変更してください。さらに、`program.json`ファイルの"program"フィールドを新しいプログラムの名前に合わせて変更してください。これら2つのフィールドは**一致しなければならず**、そうでないとプログラムが正しくコンパイルされません。

## タスク 1: Mint（パブリック）
この機能は、受取人のパブリックマッピング値を更新することで新しいトークンを発行します。Aleoの`async`モデルに従って、2つの別々の関数に分割されています：

### `mint_public()` 
これは、オフチェーンで実行され、対応するゼロ知識証明がオンチェーンで検証される`async transition`です。
1. まず、`workshop_ofac.aleo`から`address_check()`関数を呼び出す必要があります。これはすでにテンプレートで行われています。

2. 次に、返された`Future`を他の適切なフィールドと一緒に`mint_public_onchain`関数に渡す必要があります。

### `mint_public_onchain()` 
これは、オンチェーンで実行される`async function`です。
1. まず、`address_check : Future`をawaitします。これはすでにテンプレートで行われています。

2. `balances`マッピングの`recipient`の値を現在の値プラス`amount`に設定します。

## タスク 2: Mint（プライベート）
この機能は、受取人に指定された量のトークンを持つ新しいプライベートレコードを初期化することで新しいトークンを発行します。Aleoの`async`モデルに従って、2つの別々の関数に分割されています：
    
### `mint_private`:
これは、オフチェーンで実行され、対応するゼロ知識証明がオンチェーンで検証される`async transition`です。
1. まず、`workshop_ofac.aleo`から`address_check()`関数を呼び出す必要があります。

2. 次に、所有者として`recipient`、金額として`amount`を持つ`Token`レコードを初期化します。

3. `Token`レコードを返し、`Future`を`mint_private_onchain`関数に渡します。

### `mint_private_onchain`:
これは、オンチェーンで実行される`async function`です。
1. `address_check : Future`をawaitします。

## タスク 3: Transfer（パブリック）

この機能は、パブリックマッピングでの送信者の残高から転送量を差し引き、受取人の残高に同じ値を追加することで、2人のユーザー間でトークンをパブリックに転送します。
    
### `transfer_public`:
これは、オフチェーンで実行され、対応するゼロ知識証明がオンチェーンで検証される`async transition`です。
1. まず、`workshop_ofac.aleo`から`address_check()`関数を呼び出す必要があります。

2. 次に、返された`Future`を他の適切なフィールドと一緒に`transfer_public_onchain`関数に渡す必要があります。
    - `sender`フィールドには、関数呼び出しを初期化したアドレスを指定するために`self.signer`を使用できます。

### `transfer_public_onchain`:
これは、オンチェーンで実行される`async function`です。
1. まず、`address_check : Future`をawaitします。

2. 次に、`balances`マッピングの`sender`の値を送信者の現在の値マイナス`amount`に設定します。

3. 最後に、`balances`マッピングの`recipient`の値を受取人の現在の値プラス`amount`に設定します。

## タスク 4: Transfer（プライベート）

この機能は、送信者の`Token`レコードを消費し、2つの新しい`Token`レコードを生成することで、2人のユーザー間でトークンをプライベートに転送します。最初のレコードは送信された金額で受取人が所有し、2番目のレコードは残りの金額で送信者が所有します。

### `transfer_private`:
これは、オフチェーンで実行され、対応するゼロ知識証明がオンチェーンで検証される`async transition`です。
1. まず、`workshop_ofac.aleo`から`address_check()`関数を呼び出す必要があります。

2. 次に、所有者として`recipient`、金額として`amount`を持つ`Token`レコードを初期化します。

3. 所有者として`sender`、金額として残り残高を持つ別の`Token`レコードを初期化します。

4. 両方の`Token`レコードを返し、`Future`を`mint_private_onchain`関数に渡します。

### `transfer_private_onchain`:
これは、オンチェーンで実行される`async function`です。
1. `address_check : Future`をawaitします。

# デプロイとオンチェーンでの操作

プログラムをビルドしてテストしたら、テストネットにプログラムをデプロイする準備が整いました。ここで、前述のテストネットクレジットが必要になります。

デプロイ後、デプロイされたプログラムとオンチェーンで操作できるようになります。
1. あなたのアドレスに100トークンをパブリックにmintする

2. それらのトークンを`<WORKSHOP_ADDRESS>`にパブリックに転送する
   
3. あなたのアドレスに追加で100トークンをプライベートにmintする
   
4. それらのトークンを`<WORKSHOP_ADDRESS>`にプライベートに転送する