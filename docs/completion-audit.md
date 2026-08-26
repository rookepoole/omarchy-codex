# Completion audit

Audit date: 2026-08-25

This audit separates reproducible evidence from behavior that still requires the target Omarchy machine.

| Requirement | Authoritative evidence | Status |
| --- | --- | --- |
| Correct graphical product boundary | Official Linux ChatGPT package `26.820.60940`; bundled Codex core; `Terminal=false`; no `/usr/bin/codex` replacement | Proven |
| Safe Arch packaging | Versioned OpenAI pool URLs, x86_64/ARM64 SHA-256 pins, clean Arch build/install receipt, conflict and existing-app guards | Proven |
| Omarchy launcher and desktop integration | Current `quattro` shortcut/helper contract test, managed `Super + Shift + A`, desktop entry validation | Proven in source and confirmed launching on the target machine |
| Optional Quattro panel | Marketplace manifest, official plugin-validator pass, and a read-only status boundary around the existing app command | Proven in source; physical panel layout pending |
| Physical rendering | Native Wayland launch and device scale `1` confirmed on the target Omarchy machine | Proven |
| Terminal-to-graphical project opening | `chatgpt .` deep-link encoding tests | Implemented; target-machine Work-mode result pending |
| Secure authentication boundary | Official browser OAuth only; no API-key path; auth files untouched; Omarchy provides GNOME Keyring and libsecret | Implemented; target-machine login and restart persistence pending |
| Update behavior | Repeat install/container upgrade checks and physical update through 0.1.3 | Proven through 0.1.3; latest release update pending |
| Uninstall behavior | End-to-end uninstall removes the package/managed shortcut and preserves auth/configuration | Proven in contained Arch test |
| Versioned source and installer artifact | Git tag/release plus checksumed payload-free installer bundle; OpenAI payload remains downloaded and verified locally | Proven when the latest release workflow succeeds |
| Installation and maintenance documentation | README, security boundary, known issues, verification receipts, core workflow check | Proven |
| End-to-end Codex work | Browser sign-in, repository open, file task, task persistence after restart | Not yet proven on the target machine |

The project is not complete until the final row is confirmed. A green source test cannot substitute for an interactive Codex task.
