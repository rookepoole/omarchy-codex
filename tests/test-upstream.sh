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

check_arch amd64 amd64 15cf422a77e8f28a7553d3180b8c72784a994438a141784c82d72cde93efca77
check_arch arm64 arm64 8d5141b299ca593255fa25760895e84375937cc305197528c822dfa71ac2a3bf
printf 'PASS pinned artifacts match OpenAI repository metadata\n'
