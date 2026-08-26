#!/usr/bin/env bash
set -euo pipefail

package_file="${1:-}"
if [[ -z "$package_file" || ! -f "$package_file" ]]; then
  printf 'Usage: %s /path/to/package.pkg.tar.zst\n' "$0" >&2
  exit 2
fi

contents="$(bsdtar -tf "$package_file")"

required_paths=(
  'etc/apparmor.d/chatgpt'
  'usr/bin/chatgpt'
  'usr/lib/chatgpt/codex-launcher'
  'usr/share/applications/chatgpt.desktop'
  'usr/share/licenses/chatgpt-desktop-bin/LICENSE'
)
for required_path in "${required_paths[@]}"; do
  if ! grep -Fqx "$required_path" <<< "$contents"; then
    printf 'Required package path is missing: %s\n' "$required_path" >&2
    exit 1
  fi
done

if grep -Eq '(^|/)(\.INSTALL|apt/|sources\.list|chatgpt\.sources)' <<< "$contents"; then
  printf 'Forbidden Debian install metadata found in package.\n' >&2
  exit 1
fi

if bsdtar --numeric-owner -tvf "$package_file" |
  awk '$3 != 0 || $4 != 0 { print; invalid = 1 } END { exit invalid }'; then
  :
else
  printf 'Package contains files not owned by numeric UID/GID 0:0.\n' >&2
  exit 1
fi

printf 'Package payload verification passed: %s\n' "$package_file"
