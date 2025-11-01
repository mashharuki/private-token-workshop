#!/bin/bash
set -e

echo "=== Setting up Aleo Development Environment ==="

# pnpmのインストール
echo "Installing pnpm..."
npm install -g pnpm

# uvのインストール
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Rustのセットアップ(最新版の確保)
echo "Updating Rust..."
rustup update stable
rustup default stable

# 必要な依存関係のインストール
echo "Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    clang \
    llvm \
    lld \
    gcc \
    g++ \
    binutils \
    cmake \
    git-all

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

# バージョン確認
echo ""
echo "=== Installation Complete ==="
echo "Verifying installations..."
echo "Git version: $(git --version)"
echo "Node.js version: $(node --version)"
echo "pnpm version: $(pnpm --version)"
echo "Python version: $(python --version)"
echo "uv version: $(uv --version)"
echo "Rust version: $(rustc --version)"
echo "Cargo version: $(cargo --version)"
echo "Leo version: $(leo --version)"
echo "SnarkOS version: $(snarkos --version)"
echo ""
echo "✅ Development environment is ready!"
