#!/bin/bash
# Verifies build environment for Lumi Rust core
set -e

if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo not found. Please install Rust toolchain." >&2
  exit 1
fi
if ! command -v rustc >/dev/null 2>&1; then
  echo "rustc not found. Please install Rust toolchain." >&2
  exit 1
fi
echo "Build environment verified."
