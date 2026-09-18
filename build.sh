#!/usr/bin/env bash
# hello-algo 静态站构建：克隆上游源码（版本 tag）→ mkdocs 多语言构建 → site/
# 由 LazyCat GitHub Action 的 buildscript 在每次构建时执行
set -euo pipefail

VERSION="${LAZYCAT_VERSION:-${VERSION:-}}"
echo "==> building hello-algo version: ${VERSION:-<default branch>}"

rm -rf .upstream site
if [ -n "$VERSION" ]; then
  if ! git clone --depth 1 --branch "$VERSION" https://github.com/krahets/hello-algo.git .upstream 2>/dev/null; then
    echo "==> tag $VERSION not found, falling back to default branch"
    git clone --depth 1 https://github.com/krahets/hello-algo.git .upstream
  fi
else
  git clone --depth 1 https://github.com/krahets/hello-algo.git .upstream
fi

python3 -m pip install --user --upgrade pip >/dev/null
python3 -m pip install --user mkdocs-material==9.5.5 mkdocs-glightbox >/dev/null
export PATH="$HOME/.local/bin:$PATH"

cd .upstream
rm -rf build site
mkdir -p build
cp -r overrides build/overrides
cp -r docs build/docs
mkdocs build -f mkdocs.yml
for lang in zh-hant en ja ru; do
  if [ ! -d "$lang/docs" ]; then
    echo "==> skip $lang (not present in this version)"
    continue
  fi
  mkdir -p "build/$lang"
  cp -r "$lang/docs" "build/$lang/docs"
  mkdocs build -f "$lang/mkdocs.yml"
done
cd ..
cp -r .upstream/site site
echo "==> site built: $(du -sh site | cut -f1)"
