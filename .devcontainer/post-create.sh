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
sudo apt-get install -y build-essential pkg-config libssl-dev clang llvm

# Leoのインストール
echo "Installing Leo..."
cd /tmp
if [ -d "leo" ]; then
    rm -rf leo
fi
git clone --recurse-submodules https://github.com/ProvableHQ/leo
cd leo
cargo install --path .
cd /tmp
rm -rf leo

# SnarkOSのインストール
echo "Installing SnarkOS..."
cd /tmp
if [ -d "snarkOS" ]; then
    rm -rf snarkOS
fi
git clone --branch mainnet --single-branch https://github.com/ProvableHQ/snarkOS.git
cd snarkOS
cargo install --locked --path .
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
