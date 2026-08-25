# Changelog

## 0.1.5 — 2026-08-25

- Publish a checksumed installer bundle without redistributing OpenAI's proprietary payload.
- Gate release publication on the source, launcher, keybinding, upstream package, and current Omarchy tests.
- Protect Omarchy's existing `/usr/bin/codex` usage collector integration from package collisions.
- Add a requirement-by-requirement completion audit.

## 0.1.4 — 2026-08-25

- Make `chatgpt .` and `omarchy-codex open .` open the current repository in the graphical Work interface.
- Extend the doctor with privacy-safe Secret Service, shortcut, and live Hyprland checks.
- Record the physical Omarchy rendering and scale confirmation separately from unverified core workflows.

## 0.1.3 — 2026-08-25

- Add persistent device-scale control for oversized native-Wayland windows.
- Report the configured display scale in `omarchy-codex doctor`.
- Preserve automatic scaling by default instead of forcing one value on every display.

## 0.1.2 — 2026-08-25

- Switch automatic Omarchy sessions to native Wayland after real-machine Mesa/XWayland crashes.
- Add a hard preflight guard against replacing an independently installed ChatGPT application.
- Keep XWayland available only as an explicit diagnostic mode.

## 0.1.1 — 2026-08-25

- Fix the published ShellCheck gate by replacing an ambiguous conditional chain.
- Bump the native package release so installed integration metadata updates correctly.

## 0.1.0 — 2026-08-25

- Package OpenAI ChatGPT desktop app 26.818.61809 for x86_64 and ARM64 Omarchy systems.
- Add graphical Codex launcher and `Super + Shift + A` integration.
- Add automatic, native Wayland, and XWayland rendering modes.
- Add update, version, doctor, and sign-in-preserving uninstall workflows.
- Verify the x86_64 package build, pacman install, dynamic linkage, and sandboxed graphical startup in a clean Arch container.
