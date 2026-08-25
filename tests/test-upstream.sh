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

check_arch amd64 amd64 1bba62a6dbd2d49975c62850d8eddaad605da193557b194982225e56b1941891
check_arch arm64 arm64 a538eab08ff9cb50d8c83471d3b491dd3c44a79953a1f8a80ec54a2bdb25a13a
printf 'PASS pinned artifacts match OpenAI repository metadata\n'
