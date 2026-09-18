# Tab budget (Browser Management)

Part of **No Leak Helium**. MIT licensed (`LICENSE` in this folder).

Keeps Helium under a **5 GB RAM** budget by hibernating the oldest unused
background tabs, and optionally clears listed **site caches** at 03:00.
It never deletes cookies, logins, IndexedDB, or sessions.

This is the same product previously published as
[helium-browser-management-system](https://github.com/gokulsvision/helium-browser-management-system).
It now ships inside No Leak Helium so you do not run a second stack.

## RAM

- Cap: 5 GB for the whole Helium process tree
- Oldest unused background tabs sleep first
- Skip: active tab, pinned, audible, `chrome://`, `helium://`
- Sleeping URLs are grouped by topic (Video, Mail, Code, …)
- Native helper talks to the extension over stdio. No network.

## Disk

- Default: `riverside.com` service-worker cache at 03:00
- Skipped if Helium is still running
- Policy file: `~/Library/Application Support/Browser Management System/POLICY.md`

Installed automatically by `overlay/macos/install.sh` (Helium only).
