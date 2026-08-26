# Namcap notes

`namcap PKGBUILD` should complete without findings. A scan of the generated
binary package reports warnings and dependency errors caused by the contents of
the upstream prebuilt application. They should still be reviewed on every
release, but the following categories are currently expected.

## Prebuilt ELF hardening and stripping

The Debian payload contains Electron, Node native modules, helper binaries, and
third-party tools built by upstream. `namcap` reports missing PIE/FULL RELRO and
unstripped binaries. Repackaging must not rewrite or strip these vendor
binaries because that can break signatures, native modules, or runtime loading.

## ARM and 32-bit dependency detections

Some bundled Node packages contain prebuilds for ARM, ARM64, musl, Android, and
x86_64 in the same private application directory. `namcap` inspects all of them
and may request `lib32-gcc-libs` or other libraries. The application selects the
x86_64 glibc build at runtime, so dependencies for inactive foreign-architecture
artifacts must not be added to the Arch package.

## Python helper scripts

The payload contains Python-based plugins, skills, tests, protobuf helpers, and
native-module rebuild tooling. They are not required to start the desktop app.
`python` is therefore an optional dependency rather than a mandatory runtime
dependency.

## Private npm man pages

The bundled Node runtime includes npm documentation below
`/usr/lib/chatgpt/resources/`. These are application-private resources, not
system man pages, so their non-FHS locations are preserved from upstream.

If a future scan reports a finding outside these categories, investigate it as
a new packaging or upstream issue.
