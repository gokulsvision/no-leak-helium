<div align="center">
    <img src="resources/branding/app_icon/raw.png"
        title="No Leak Helium" alt="Helium logo" width="120" />
    <h1>No Leak Helium</h1>
    <p>
        A version of <a href="https://github.com/imputnet/helium">Helium</a> that is built so
        <strong>nothing phones home unless you sent it there</strong>.
        <br>
        No Helium telemetry. No Sparkle auto-update pings. No crash uploads.
        No AdBlock (getadblock.com). Ads blocked with uBlock Origin.
        RAM capped by hibernating old tabs.
    </p>
</div>

This is **not** an official Helium release. It is a public fork of
[imputnet/helium](https://github.com/imputnet/helium) (GPL-3.0) plus the
features we actually run on a daily driver.

| What | How |
|---|---|
| No Helium services / crash / Sparkle | [`patches/gokul/zero-telemetry-defaults.patch`](patches/gokul/zero-telemetry-defaults.patch) + macOS overlay |
| Ads without telemetry | Unpacked [uBlock Origin](https://github.com/gorhill/uBlock) (not Chrome Web Store “AdBlock”) |
| RAM / tab budget | [`features/browser-management`](features/browser-management) — 5 GB cap, oldest tabs hibernate, nightly site-cache policy |
| Public record of the audit | [`RECORD.md`](RECORD.md) |
| Weekly upstream sync | [`MAINTAINING.md`](MAINTAINING.md) |

macOS packaging fork: [no-leak-helium-macos](https://github.com/gokulsvision/no-leak-helium-macos).

## Install on a Mac (no Chromium compile)

Use an official Helium build, then apply this overlay. The app stays `Helium.app`;
the lock is what makes it No Leak Helium.

```bash
git clone https://github.com/gokulsvision/no-leak-helium.git
cd no-leak-helium/overlay/macos
chmod +x install.sh helium-privacy-lock helium-privacy-install-system install-browser-management.sh
./install.sh
```

That turns off vendor channels, installs uBlock Origin, and installs the tab
budget (Helium only — it does not touch Chrome/Edge).

To make Helium services / AdBlock / Sparkle **unblockable from the UI** (password prompt):

```bash
osascript -e 'do shell script "'$HOME'/.local/bin/helium-privacy-install-system" with administrator privileges'
```

Do **not** install the Chrome Web Store extension named “AdBlock”. That one had a tracking id.

## Upstream Helium downloads
> [!NOTE]
> Helium is currently in beta, so unexpected issues may occur.
> Please report them if they haven't already been reported.

The easiest way to download Helium is [helium.computer](https://helium.computer/).
It'll pick a compatible binary for your platform automatically.

The same releases can also be downloaded from source on GitHub:

- [Latest macOS release](https://github.com/imputnet/helium-macos/releases/latest)
- [Latest Linux release](https://github.com/imputnet/helium-linux/releases/latest)
- [Latest Windows release](https://github.com/imputnet/helium-windows/releases/latest)

## Helium repos
All Helium packaging, tooling, services, and components are open source
and published on GitHub.

### Platform packaging and tooling
- [Helium for macOS](https://github.com/imputnet/helium-macos)
- [Helium for Linux](https://github.com/imputnet/helium-linux)
- [Helium for Windows](https://github.com/imputnet/helium-windows)

### Web services and Helium components
- [Helium services](https://github.com/imputnet/helium-services)
- [Helium onboarding](https://github.com/imputnet/helium-onboarding)
- [Helium fork of uBlock Origin](https://github.com/imputnet/uBlock)

## Development
macOS is our primary development platform, so it's the recommended
development environment for community contributions.

Linux packaging includes a similar development script, so the same guide
can be applied there too.

[> See development docs in macOS repo](https://github.com/imputnet/helium-macos/blob/main/docs/building.md#development-build-and-environment)

## Contributing
Before contributing to Helium, please read the guidelines in
[CONTRIBUTING.md](CONTRIBUTING.md).

## Credits

### The Chromium project
[The Chromium Project](https://www.chromium.org/) is at the core of Helium,
making it possible in the first place.

### ungoogled-chromium
This repo is based on [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium),
but heavily modified for Helium. Special thanks to everyone behind ungoogled-chromium,
they made working with Chromium way easier.

### Other Chromium browsers

Helium includes some patches from other open source Chromium browsers:

- [Inox patchset](https://github.com/gcarq/inox-patchset)
- [Debian](https://tracker.debian.org/pkg/chromium-browser)
- [Bromite](https://github.com/bromite/bromite)
- [Iridium Browser](https://iridiumbrowser.de/)
- [Brave](https://github.com/brave/brave-core)

All patches are sorted by vendor in the [patches](patches/) directory of this repo.

## License
All code, patches, modified portions of imported code or patches, and
any other content that is unique to Helium and not imported from other
repositories is licensed under GPL-3.0. See [LICENSE](LICENSE).

Any content imported from other projects retains its original license (for
example, any original unmodified code imported from ungoogled-chromium remains
licensed under their [BSD 3-Clause license](LICENSE.ungoogled_chromium)).
