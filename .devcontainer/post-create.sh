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
echo ""
echo "✅ Development environment is ready!"
