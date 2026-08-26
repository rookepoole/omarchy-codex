# Physical Omarchy panel verification — 0.1.8

Date: 2026-08-26

The repository-root Quattro plugin was tested on the target Omarchy machine after the source, upstream-package, and official manifest-validator gates passed.

## Confirmed behavior

- **Setup → Plugins → Add** accepted `https://github.com/rookepoole/omarchy-codex`.
- The plugin enabled successfully and appeared in the Omarchy bar.
- The Codex panel opened and displayed the installed integration, pacman package, and OpenAI app versions.
- The panel launched the existing graphical Codex application.
- The independently installed application continued to work after the panel was added.

## Isolation boundary

The panel does not install, remove, or directly reconfigure the application. Static tests reject package-manager, installer, uninstaller, deletion, API-key, and authentication paths in `CodexPanel.qml`. Removing the plugin therefore removes only the optional shell surface.

## Claim boundary

This receipt covers plugin installation through Omarchy's graphical Add flow, panel rendering, version reporting, and graphical launch. The Update and Diagnostics buttons are source-tested delegates to the existing `omarchy-codex` commands; their terminal presentation was not part of this physical confirmation.
