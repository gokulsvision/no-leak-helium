> **This is a public fork:** [gokulsvision/helium-private](https://github.com/gokulsvision/helium-private)
> of [imputnet/helium](https://github.com/imputnet/helium).
> It is **not** an official Helium release.
>
> Extra patch: [`patches/gokul/zero-telemetry-defaults.patch`](patches/gokul/zero-telemetry-defaults.patch)
> (Helium services off, crash uploads off, GPC on).
>
> macOS overlay for the official binary (no Chromium compile): [`overlay/macos`](overlay/macos).
> What changed and why: [`RECORD.md`](RECORD.md).
> How to pull upstream every week: [`MAINTAINING.md`](MAINTAINING.md).
>
> Packaging fork: [gokulsvision/helium-macos-private](https://github.com/gokulsvision/helium-macos-private).

<div align="center">
    <img src="resources/branding/app_icon/raw.png"
        title="Helium" alt="Helium logo" width="120" />
    <h1>helium-private</h1>
    <p>
        Fork of Helium with first-party vendor channels off by default.
        <br>
        Upstream Helium remains the Chromium-based browser this is built from.
    </p>
    <a href="https://github.com/imputnet/helium">
        upstream: imputnet/helium
    </a>
</div>

## Downloads (upstream binaries + this overlay)

Until this fork is compiled, install an official macOS build from
[imputnet/helium-macos/releases](https://github.com/imputnet/helium-macos/releases),
then apply the overlay:

```bash
git clone https://github.com/gokulsvision/helium-private.git
cd helium-private/overlay/macos
chmod +x install.sh helium-privacy-lock helium-privacy-install-system
./install.sh
# optional, makes vendor hosts unblockable from the UI:
# osascript -e 'do shell script "'$HOME'/.local/bin/helium-privacy-install-system" with administrator privileges'
```

Ad blocking is **uBlock Origin** from [gorhill/uBlock](https://github.com/gorhill/uBlock), unpacked.
Do not install the Chrome Web Store extension named "AdBlock".

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
