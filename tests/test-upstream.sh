#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(<"${root}/APP_VERSION")"

check_arch() {
  local repository_arch="$1"
  local deb_arch="$2"
  local expected_sha="$3"
  local packages
  packages="$(curl -fsSL "https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-${repository_arch}/Packages")"
  grep -Fq "Version: ${version}" <<<"${packages}"
  grep -Fq "Filename: pool/main/c/chatgpt/chatgpt_${version}_${deb_arch}.deb" <<<"${packages}"
  grep -Fq "SHA256: ${expected_sha}" <<<"${packages}"
}

check_arch amd64 amd64 31d956a8c6c515f8d87e0b7acd9ec919f7e685ba59331b4b97aa45f853afdfd7
check_arch arm64 arm64 8f4dacbff5f054a4f69c2a021f1396c57976972829a61041febac1b423f27c86
printf 'PASS pinned artifacts match OpenAI repository metadata\n'
