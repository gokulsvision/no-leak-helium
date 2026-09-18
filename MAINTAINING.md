# Maintaining this fork

This repository is a public, GPL-3.0 fork of [imputnet/helium](https://github.com/imputnet/helium).
The extra patch lives in `patches/gokul/` and the macOS runtime lock lives in `overlay/macos/`.

## Weekly (already automated two ways)

1. **On this Mac:** LaunchAgent `net.gokul.helium-privacy` runs Sunday 10:00.
   It re-applies the overlay, restores uBlock Origin if Helium replaced the app bundle, and notifies if a new official Helium binary exists.
2. **On GitHub:** `.github/workflows/upstream-watch.yml` runs Sunday 14:00 UTC and opens an issue if `imputnet/helium` main has moved.

Manual overlay check:

```bash
python3 ~/.local/bin/helium-privacy-lock --weekly
```

## Pulling a new Helium source revision

```bash
cd helium-private
git fetch upstream
git merge upstream/main
# If quilt/build later fails on our patch:
#   edit patches/gokul/zero-telemetry-defaults.patch
git push origin main
```

Then, if you build from source, update the macOS packaging fork:

```bash
cd helium-macos-private
git fetch upstream
git merge upstream/main
# helium-chromium submodule should point at gokulsvision/helium-private
git submodule set-url helium-chromium https://github.com/gokulsvision/helium-private.git
git submodule update --remote helium-chromium
git push origin main
```

Building a signed Helium.app from this fork is a full Chromium compile (Xcode, tens of GB, hours). Until you do that, keep using the official Helium binary plus `overlay/macos`.

## Official binary update (no compile)

1. Download the latest macOS build from [imputnet/helium-macos/releases](https://github.com/imputnet/helium-macos/releases).
2. Replace `/Applications/Helium.app`.
3. Run `python3 ~/.local/bin/helium-privacy-lock`.
   That restores unpacked uBlock Origin into the new bundle and re-locks prefs/Sparkle.

Do **not** turn Sparkle auto-update back on. Sparkle phones `updates.helium.computer` (Cloudflare).

## What this fork changes vs upstream Helium

See [RECORD.md](RECORD.md).
