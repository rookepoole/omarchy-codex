# Omarchy Codex

The real graphical OpenAI Codex experience on Omarchy—not a terminal UI and not a web-app shortcut.

This project repackages OpenAI's official Linux ChatGPT desktop application, which includes Codex, into a native Arch package and connects it to Omarchy's app launcher and `Super + Shift + A` shortcut.

## Install

```bash
git clone https://github.com/rookepoole/omarchy-codex.git
cd omarchy-codex
./install.sh
```

Each GitHub release also includes a checksumed, payload-free installer bundle. It contains this integration code—not OpenAI's proprietary application—and downloads the pinned official package during installation.

Then open **Codex** from Omarchy's Apps menu or press `Super + Shift + A`. Choose **Continue to sign in** and complete the ChatGPT browser login. No API key is created or required.

To open the current repository directly in the same graphical app, choose **Work** mode and run:

```bash
chatgpt .
```

`omarchy-codex open .` is the explicit equivalent. Both use the app's project deep link; neither opens the terminal Codex interface.

The first build downloads about 390 MB from OpenAI and installs about 1.3 GB. The downloaded `.deb` is checksum-verified by `makepkg` before packaging.

## What it changes

- Installs OpenAI's graphical app as the pacman package `omarchy-codex`.
- Replaces Omarchy's default `Super + Shift + A` ChatGPT web shortcut with the desktop app.
- Adds a native **Codex** application entry.
- Uses native Wayland automatically on Omarchy to avoid current Mesa/XWayland GPU crashes.
- Preserves ChatGPT sign-in data across upgrades and normal uninstall.

It does **not** install Codex CLI, request an API key, modify `~/.codex/auth.json`, or commit/redistribute OpenAI's application binary.

## Maintenance

```bash
omarchy-codex update
omarchy-codex doctor
omarchy-codex version
```

Force native Wayland explicitly with:

```bash
omarchy-codex rendering wayland
```

Return to Omarchy's automatic behavior with:

```bash
omarchy-codex rendering auto
```

Fully quit and reopen Codex after changing rendering mode.

If the app says 100% zoom but the entire native-Wayland interface is oversized, set
the Electron device scale to 1 without returning to XWayland:

```bash
omarchy-codex scale 1
pkill -f '/usr/lib/chatgpt/ChatGPT' 2>/dev/null || true
omarchy-codex launch
```

Other fractional values such as `1.25` and `1.5` are supported. Restore automatic
display scaling with `omarchy-codex scale auto`.

If a previous build crashes during GPU initialization, recover without opening the app first:

```bash
omarchy-codex rendering wayland
pkill -f '/usr/lib/chatgpt/ChatGPT' 2>/dev/null || true
omarchy-codex launch
```

Uninstall while preserving sign-in data:

```bash
./uninstall.sh
```

## Support boundary

OpenAI currently supports the Linux preview on Ubuntu, Debian, and Fedora—not Arch. This is an independent Omarchy compatibility package, not an OpenAI product and not an official Arch package. The app itself is downloaded from OpenAI's versioned package repository during the local build.

- [Official Linux app documentation](https://learn.chatgpt.com/docs/linux/linux-app)
- [Open-source Codex core](https://github.com/openai/codex)
- [Completion audit](docs/completion-audit.md)
- [Core graphical workflow check](docs/core-workflow-check.md)

The packaging and Omarchy integration code in this repository is MIT licensed. OpenAI's downloaded application remains under its own terms.
