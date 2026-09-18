# Notes: what No Leak Helium actually is

**Personal software fork.** Gokul / [GokulsVision](https://github.com/gokulsvision). Not official Helium. Not a company product.

Goal: a Helium that is **no-leak** (no vendor/extension background channel) and **performance-oriented** (hard RAM cap, hibernate old tabs, scheduled cache clear).

Published as [gokulsvision/no-leak-helium](https://github.com/gokulsvision/no-leak-helium), GPL-3.0, forked from [imputnet/helium](https://github.com/imputnet/helium).
Audited against Helium 0.17.1.1 / Chromium 153.0.8010.47 on macOS (2026-09-17).

This is not a claim that browsing is anonymous. Sites you open still see you.
It is a claim that **Helium the vendor, Sparkle, crash uploads, and AdBlock (getadblock.com) do not get a background channel**.

## Findings on stock Helium (this machine)

| Channel | Stock Helium | This fork / overlay |
|---|---|---|
| Helium services (`services.helium.imput.net`) | Opt-in at onboarding; this profile had consented | Default **off**; hosts sinkhole |
| Sparkle auto-update (`updates.helium.computer` via Cloudflare) | On | Off; weekly GitHub check instead |
| Crashpad (`crash.helium.computer`) | Default "ask"; URL always in the handler | Default **disabled**; hosts sinkhole |
| Google Chrome telemetry / Safe Browsing / RLZ | Already compiled out by Helium | Unchanged |
| Default search | Google (user choice, kept) | Kept; **search suggestions off** |
| Ad blocking | Helium-bundled uBlock Origin (files missing in 0.17.1.1 on this Mac) plus leftover **AdBlock 6.46.0** with unique `rcid` | Official **uBlock Origin 1.75.0** unpacked from [gorhill/uBlock](https://github.com/gorhill/uBlock); AdBlock ID blocklisted and sinkholed |
| DNS | System resolver | Browser DoH to `https://dns.mullvad.net/dns-query` |
| WebRTC | Default (can leak LAN IP) | `default_public_interface_only` |
| Global Privacy Control | Off | On |

## Source patch in this repo

`patches/gokul/zero-telemetry-defaults.patch`

- `helium.services.enabled` defaults to **false**
- crash reporting defaults to **kDisabled**
- Global Privacy Control defaults to **true**

## Tab budget (merged in)

Previously a separate repo
([helium-browser-management-system](https://github.com/gokulsvision/helium-browser-management-system)).
Now [`features/browser-management`](features/browser-management) (MIT):

- 5 GB RAM cap for the Helium process tree
- Oldest unused background tabs hibernate (`tabs.discard`)
- URLs filed by topic so you can reopen them
- Nightly site-cache clear from `POLICY.md` (default: riverside.com service-worker)
- Never deletes cookies, logins, IndexedDB, or sessions
- Native helper is local stdio only — no network
- Installed for **Helium only**, not Chrome/Edge/etc.

## Runtime overlay (official binary, no Chromium compile)

`overlay/macos/`

- Disables Sparkle via `defaults`
- Writes Helium prefs only when the browser is not running
- Restores unpacked uBlock Origin into `Helium.app` `Resources/ublock`
- Blocks getadblock.com extension ID
- Optional admin step: `/Library/Managed Preferences/net.imput.helium.plist` + `/etc/hosts` sinkhole so the UI cannot re-enable vendor channels

Sinkholed names:

- `services.helium.imput.net`
- `crash.helium.computer`
- `updates.helium.computer`
- `getadblock.com`, `www.getadblock.com`, `adblockcdn.com`

## Still leaves the machine (accepted)

- Pages you navigate to
- Google search when you submit a query
- uBlock filter-list fetches (GitHub / EasyList see an IP pulling a public list)
- Mullvad DoH (Mullvad sees Helium's domain lookups, not page bodies)
- Apple `trustd` certificate checks (OS, every app)

## What we refused

- Chrome Web Store `.crx` install of uBlock (`CRX_REQUIRED_PROOF_MISSING` on Helium)
- Uninstalling AdBlock via its `uninstall_url` (that URL is a tracking ping)
- Leaving Helium services on as an "anonymizing proxy"
