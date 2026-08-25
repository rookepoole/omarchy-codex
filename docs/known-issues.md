# Known issues

## Mesa/XWayland GPU crash

The 0.1.0 and 0.1.1 wrappers left Electron's Linux renderer on its automatic path, which selected XWayland. A real Omarchy test produced repeated Mesa divide-by-zero failures and crashed the previously working app.

Version 0.1.2 reconstructs the default around that evidence: Wayland sessions now launch with `--ozone-platform=wayland`. This matches the established Arch wrapper behavior and avoids the GLX path implicated by current upstream Intel and AMD reports:

- [OpenAI issue #39704: Intel GPU hangs through XWayland](https://github.com/openai/codex/issues/39704)
- [OpenAI issue #39724: AMD Mesa/Gallium crashes through X11](https://github.com/openai/codex/issues/39724)

Recovery:

```bash
omarchy-codex rendering wayland
pkill -f '/usr/lib/chatgpt/ChatGPT' 2>/dev/null || true
omarchy-codex launch
```

Do not use `--no-sandbox`. Full GPU disabling is also not the default workaround because this app build can reject startup when required GPU capabilities are disabled.

## Oversized interface at 100% zoom

Native Wayland can expose a compositor/device-scale mismatch even when the app's own
zoom control says 100%. Keep the safe Wayland renderer and override only Electron's
device scale:

```bash
omarchy-codex scale 1
pkill -f '/usr/lib/chatgpt/ChatGPT' 2>/dev/null || true
omarchy-codex launch
```

Use `omarchy-codex scale auto` to remove the effective override.
