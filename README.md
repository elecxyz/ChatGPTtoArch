# ChatGPT/Codex desktop for Arch Linux

An unofficial Arch Linux packaging recipe for OpenAI's official ChatGPT/Codex
desktop application. The recipe downloads the pinned Debian package directly
from OpenAI's Linux package repository, verifies its SHA-256 checksum, extracts
only the application payload, and produces a native pacman package.

This repository is not affiliated with or endorsed by OpenAI. It does not
redistribute the OpenAI application binary.

This recipe repackages the Debian
payload for Arch-based systems without running Debian maintainer scripts or
adding an APT repository to the host.

## THIS IS NOT AFFILIATED WITH OPENAI NOR ENDORSED BY OPENAI ALL USE IS AT USER RISK

## Build and install

Install the standard Arch build tools, clone this repository, and run:

```bash
makepkg --syncdeps --install --cleanbuild
```

The build downloads approximately 400 MB and produces an approximately 450 MB
package with an installed size of about 1.3 GB.

## Security model

- The source URL uses OpenAI's `persistent.oaistatic.com` package repository.
- `makepkg` verifies the exact SHA-256 published in OpenAI's signed repository
  metadata.
- Only `data.tar.xz` is extracted. Debian `preinst`, `postinst`, `prerm`, and
  `postrm` scripts are never included or executed.
- The generated package contains no APT sources or pacman install hooks.
- `scripts/update.sh` verifies the repository `InRelease` signature using the
  pinned Codex Linux Repository key before updating the version and checksum.

The committed public key has fingerprint:

```text
3BFA 0E4A E8B8 CC16 A2D9  BA68 4A3B 4A56 6C46 60E4
```

Review `PKGBUILD`, `.SRCINFO`, and the upstream changes before installing a new
version. This repository can verify provenance and packaging mechanics, but it
cannot audit OpenAI's closed-source application binary.

## Updating

Required tools: `curl`, `gnupg`, `makepkg`, `awk`, and `sed`.

```bash
./scripts/update.sh
makepkg --cleanbuild
namcap PKGBUILD ./*.pkg.tar.zst
./scripts/verify-package.sh ./*.pkg.tar.zst
```

The updater verifies the signed upstream metadata, updates `pkgver` and the
SHA-256 checksum, and regenerates `.SRCINFO`. Review and commit those two files.
The upstream binary produces known `namcap` warnings; review
[`docs/namcap-notes.md`](docs/namcap-notes.md) before changing dependencies or
modifying bundled files in response to them.

## Repository policy

Commit the packaging recipe and metadata only. Do not commit or attach OpenAI's
`.deb` file or generated `.pkg.tar.zst` files unless you have explicit
permission to redistribute the application.

The MIT license in this repository applies only to the packaging scripts and
documentation. OpenAI's application and bundled third-party components retain
their respective licenses.
