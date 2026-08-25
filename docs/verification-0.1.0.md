# Verification receipt — 0.1.0

Date: 2026-08-25

## Frozen inputs

- OpenAI Linux app: `26.818.61809`
- x86_64 `.deb`: 388,572,198 bytes; SHA-256 `1bba62a6dbd2d49975c62850d8eddaad605da193557b194982225e56b1941891`
- ARM64 `.deb`: 365,446,782 bytes; SHA-256 `a538eab08ff9cb50d8c83471d3b491dd3c44a79953a1f8a80ec54a2bdb25a13a`
- OpenAI Codex source inspected at `ed42068c45c1b0ab92eaf495c2880c63ca06fa09`
- Omarchy source inspected at `23dab9ec4d7179bb1e03a70ae942653f8daa8003`

The application hashes and versioned pool paths were independently matched against OpenAI's `Packages` indexes for both architectures.

## Passing checks

- Bash syntax and ShellCheck
- Desktop entry validation
- No committed `.deb` or pacman payload
- No API-key authentication path
- No Chromium `--no-sandbox` bypass
- Launcher argument preservation and all three rendering modes
- Keybinding idempotence and preservation of unrelated user content
- Refusal of malformed managed markers
- Automatic rollback when a live Hyprland validation error is introduced
- Compatibility with the current Omarchy binding/helper contract
- Clean Arch x86_64 `makepkg` build and SHA-256 validation
- Pacman install and package ownership
- Complete ELF shared-library resolution
- Sandboxed graphical process remained alive for the 20-second Xvfb probe
- End-to-end normal-user installer run with sudo dependency installation
- Repeat install produced one identical managed shortcut and reused the cached verified payload
- Normal uninstall removed only the package and managed shortcut while preserving unrelated user content

The first repeat-install rehearsal exposed an exact-package detection bug caused by pacman's virtual `provides` resolution. The check was rebuilt against the actual installed-name list, then the complete install/reinstall/uninstall sequence passed.

## Claim boundary

This establishes a reproducible Arch package and a successful contained graphical startup. It does not yet establish interactive OAuth, Hyprland window behavior, notifications, file permissions, or long-session stability on a physical Omarchy machine. Those require the real-machine smoke test after installation.

## Later contradictory evidence

The first physical Omarchy launch after 0.1.1 reported repeated Mesa divide-by-zero failures and crashed the app. The contained Xvfb startup therefore did not establish safe XWayland GPU behavior on physical hardware. Version 0.1.2 supersedes the automatic-renderer decision with native Wayland on Omarchy; that repair still requires physical-machine confirmation.
