# No Leak Helium

**A personal software fork of [Helium](https://github.com/imputnet/helium).**  
No-leak and performance-oriented. Not an official Helium product. Not affiliated with [imput](https://github.com/imputnet).

I (Gokul / [GokulsVision](https://github.com/gokulsvision)) use Helium every day and wanted one browser that:

1. **Does not phone home** to Helium, Sparkle, crash servers, or AdBlock.
2. **Stays fast and light** — 5 GB RAM cap, oldest unused tabs hibernate, bloated site caches get cleared on a schedule.
3. **Still blocks ads** without a tracker-filled “AdBlock” extension.

This repo is the public record of that fork. I maintain it for myself. You can read it, copy it, or ignore it. There is no support channel, no company, and no promise that it is right for anyone else.

| | |
|---|---|
| Source fork | this repo (`gokulsvision/no-leak-helium`) |
| macOS packaging fork | [no-leak-helium-macos](https://github.com/gokulsvision/no-leak-helium-macos) |
| Upstream browser | [imputnet/helium](https://github.com/imputnet/helium) (GPL-3.0) |
| What changed and why | [RECORD.md](RECORD.md) |
| How I pull upstream | [MAINTAINING.md](MAINTAINING.md) |

The app on disk is still `Helium.app` until I ship a compiled build from this tree. The overlay in [`overlay/macos`](overlay/macos) is what makes a stock Helium binary behave like No Leak Helium.

---

## What “no leak” means here

**Vendor and extension background channels are off.** The browser does not talk to Helium services, Helium crash reporting, Sparkle auto-update, or getadblock.com unless you deliberately undo the lock.

It does **not** mean:

- Websites you open cannot see you (Gmail is still Gmail).
- You are un-fingerprintable.
- DNS and TLS are magic. Encrypted DNS goes to Mullvad; Apple still does OS certificate checks.

If you type a URL or submit a search, that destination is allowed. The point is that **Helium itself is not an extra destination**.

## What “performance-oriented” means here

Helium is already a thin Chromium. This fork adds a **tab budget** so one long session cannot eat the machine:

- Whole Helium process tree capped at **5 GB RAM**.
- Oldest unused background tabs **hibernate** (sleep, not close). Active, pinned, and audible tabs are left alone.
- Hibernated URLs are grouped by topic so you can reopen them.
- Optional nightly clear of listed **site caches** (default: riverside.com service workers). Cookies and logins are never deleted.

That code lives in [`features/browser-management`](features/browser-management) (MIT). It only installs for Helium, not Chrome or Edge.

## What is in this fork

| Piece | Purpose |
|---|---|
| [`patches/gokul/zero-telemetry-defaults.patch`](patches/gokul/zero-telemetry-defaults.patch) | Helium services default **off**, crash uploads default **off**, Global Privacy Control default **on** |
| [`overlay/macos`](overlay/macos) | Locks a stock Helium.app: Sparkle off, prefs, hosts/policies, uBlock restore, weekly check |
| [`features/browser-management`](features/browser-management) | 5 GB tab budget + nightly cache policy |
| [`overlay/macos/bangs-mirror`](overlay/macos/bangs-mirror) | `!bang` shortcuts served from a loopback-only mirror — no Helium service contact |
| Unpacked [uBlock Origin](https://github.com/gorhill/uBlock) | Ads/trackers blocked without Chrome Web Store AdBlock |

Do not install the Chrome Web Store extension named **AdBlock**. That one carried a tracking id on this machine.

---

## Install on a Mac (no Chromium compile)

1. Install an official Helium build from [imputnet/helium-macos/releases](https://github.com/imputnet/helium-macos/releases).
2. Apply this overlay:

```bash
git clone https://github.com/gokulsvision/no-leak-helium.git
cd no-leak-helium/overlay/macos
chmod +x install.sh helium-privacy-lock helium-privacy-install-system install-browser-management.sh
./install.sh
```

That turns off vendor channels, restores uBlock Origin, and installs the tab budget.

2. Optional — `!bang` shortcuts (GitHub, Wikipedia, etc.) served from a loopback-only mirror:

```bash
cd no-leak-helium/overlay/macos/bangs-mirror
./install-bangs-mirror.sh
```

No Helium service is contacted: the bundle in this repo is served at
`http://127.0.0.1:8317/bangs.json`, the browser is pointed at it via
`helium.services.origin_override`, and `services.helium.imput.net` stays
sinkholed. Remove with `./uninstall-bangs-mirror.sh`.

3. Optional — make Helium services / AdBlock / Sparkle **unblockable from the UI** (macOS password prompt):

```bash
osascript -e 'do shell script "'$HOME'/.local/bin/helium-privacy-install-system" with administrator privileges'
```

Reload `helium://extensions` once if the tab-budget extension still shows the old “RAM Cap” name.

A LaunchAgent re-applies the lock every Sunday at 10:00 and tells you if a new official Helium exists. I update from GitHub by hand; Sparkle stays off.

---

## Building from source

Full Chromium compile: Xcode, tens of GB, hours. Packaging is [no-leak-helium-macos](https://github.com/gokulsvision/no-leak-helium-macos), which points its submodule here instead of `imputnet/helium`. See upstream’s [building notes](https://github.com/imputnet/helium-macos/blob/main/docs/building.md) and [MAINTAINING.md](MAINTAINING.md).

I have not shipped a signed `No Leak Helium.app` yet. Until then, official binary + overlay is the daily driver.

---

## License and credit

Helium, and the patches unique to Helium, are **GPL-3.0**. See [LICENSE](LICENSE).  
Tab budget is **MIT** (`features/browser-management/LICENSE`).  
uBlock Origin is gorhill’s GPL-3.0 project.

This fork would not exist without Helium, ungoogled-chromium, and Chromium. I am not those projects. I am not asking anyone to switch. This is personal software, published so I can maintain it in the open.
