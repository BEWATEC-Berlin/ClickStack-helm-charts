#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="${ROOT_DIR}/.tools"
HELM_DOCS_VERSION="${HELM_DOCS_VERSION:-v1.14.2}"
HELM_DOCS_BIN="${TOOLS_DIR}/helm-docs"

if [[ -x "${HELM_DOCS_BIN}" ]]; then
  echo "helm-docs already installed at ${HELM_DOCS_BIN}"
  exit 0
fi

os="$(uname | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "${arch}" in
  x86_64) arch="x86_64" ;;
  arm64|aarch64) arch="arm64" ;;
  *)
    echo "unsupported architecture for helm-docs: ${arch}" >&2
    exit 1
    ;;
esac

version="${HELM_DOCS_VERSION#v}"
archive="helm-docs_${version}_${os}_${arch}.tar.gz"
url="https://github.com/norwoodj/helm-docs/releases/download/${HELM_DOCS_VERSION}/${archive}"

mkdir -p "${TOOLS_DIR}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

echo "Downloading helm-docs ${HELM_DOCS_VERSION}..."
curl -fsSL "${url}" -o "${tmp_dir}/${archive}"
tar -xzf "${tmp_dir}/${archive}" -C "${tmp_dir}" helm-docs
install -m 0755 "${tmp_dir}/helm-docs" "${HELM_DOCS_BIN}"
echo "Installed helm-docs at ${HELM_DOCS_BIN}"
