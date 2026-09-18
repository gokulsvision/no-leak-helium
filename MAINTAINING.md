# Maintaining this fork

**No Leak Helium** is a public, GPL-3.0 fork of [imputnet/helium](https://github.com/imputnet/helium).
Repo: [gokulsvision/no-leak-helium](https://github.com/gokulsvision/no-leak-helium).

The extra patch lives in `patches/gokul/`. The macOS runtime lock lives in `overlay/macos/`.
Tab budget lives in `features/browser-management/`.

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
cd no-leak-helium
git fetch upstream
git merge upstream/main
# If quilt/build later fails on our patch:
#   edit patches/gokul/zero-telemetry-defaults.patch
git push origin main
```

Then, if you build from source, update the macOS packaging fork:

```bash
cd no-leak-helium-macos
git fetch upstream
git merge upstream/main
git submodule set-url helium-chromium https://github.com/gokulsvision/no-leak-helium.git
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
