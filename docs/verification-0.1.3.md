# Physical Omarchy verification — 0.1.3

Date: 2026-08-25

## Confirmed on the target machine

- The packaged graphical ChatGPT/Codex application launches on Omarchy.
- Native Wayland avoids the Mesa/XWayland crash observed with 0.1.1.
- Persistent device scale `1` makes the interface render at the desired physical size.
- The 0.1.3 update path completed far enough for its new scale command to run successfully.

## Not yet claimed

- Browser ChatGPT OAuth completion and persistence after a full app restart.
- Opening a local Git repository in Work mode.
- Reading and modifying files through a Codex task.
- Reopening the completed task after restarting the app.

Those four behaviors are the remaining physical-machine completion gate. Source/container checks do not substitute for them.
