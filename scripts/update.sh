#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
repo_url='https://persistent.oaistatic.com/codex-app-prod/linux/deb'
expected_fingerprint='3BFA0E4AE8B8CC16A2D9BA684A3B4A566C4660E4'
key_file="$repo_root/keys/codex-linux-repository.asc"
update_tmp_dir="$(mktemp -d)"

cleanup() {
  rm -r "$update_tmp_dir"
}
trap cleanup EXIT

for command_name in awk curl gpg makepkg sed sha256sum; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  fi
done

actual_fingerprint="$(
  gpg --batch --with-colons --show-keys "$key_file" 2>/dev/null |
    awk -F: '$1 == "fpr" { print $10; exit }'
)"
if [[ "$actual_fingerprint" != "$expected_fingerprint" ]]; then
  printf 'Repository key fingerprint mismatch.\n' >&2
  exit 1
fi

curl -fsSL "$repo_url/dists/stable/InRelease" \
  -o "$update_tmp_dir/InRelease"
curl -fsSL "$repo_url/dists/stable/main/binary-amd64/Packages" \
  -o "$update_tmp_dir/Packages"

mkdir -m 700 "$update_tmp_dir/gnupg"
gpg --batch --homedir "$update_tmp_dir/gnupg" \
  --import "$key_file" >/dev/null 2>&1
gpg --batch --homedir "$update_tmp_dir/gnupg" \
  --verify "$update_tmp_dir/InRelease"

metadata_sha256="$(
  awk '
    $1 == "SHA256:" { in_sha256 = 1; next }
    in_sha256 && $3 == "main/binary-amd64/Packages" { print $1; exit }
  ' "$update_tmp_dir/InRelease"
)"
actual_metadata_sha256="$(sha256sum "$update_tmp_dir/Packages" | awk '{print $1}')"
if [[ -z "$metadata_sha256" || "$actual_metadata_sha256" != "$metadata_sha256" ]]; then
  printf 'Packages metadata checksum mismatch.\n' >&2
  exit 1
fi

version="$(
  awk '
    $1 == "Package:" && $2 == "chatgpt" { in_package = 1; next }
    in_package && $1 == "Version:" { print $2; exit }
  ' "$update_tmp_dir/Packages"
)"
filename="$(
  awk '
    $1 == "Package:" && $2 == "chatgpt" { in_package = 1; next }
    in_package && $1 == "Filename:" { print $2; exit }
  ' "$update_tmp_dir/Packages"
)"
package_sha256="$(
  awk '
    $1 == "Package:" && $2 == "chatgpt" { in_package = 1; next }
    in_package && $1 == "SHA256:" { print $2; exit }
  ' "$update_tmp_dir/Packages"
)"

expected_filename="pool/main/c/chatgpt/chatgpt_${version}_amd64.deb"
if [[ -z "$version" || "$filename" != "$expected_filename" ]]; then
  printf 'Unexpected upstream package filename: %s\n' "$filename" >&2
  exit 1
fi
if [[ ! "$package_sha256" =~ ^[0-9a-f]{64}$ ]]; then
  printf 'Invalid upstream package SHA-256.\n' >&2
  exit 1
fi

sed -i -E \
  -e "s/^pkgver=.*/pkgver=${version}/" \
  -e "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('${package_sha256}')/" \
  "$repo_root/PKGBUILD"

(
  cd "$repo_root"
  makepkg --printsrcinfo > .SRCINFO
)

printf 'Updated packaging metadata:\n'
printf '  Version: %s\n' "$version"
printf '  File:    %s\n' "$filename"
printf '  SHA-256: %s\n' "$package_sha256"
